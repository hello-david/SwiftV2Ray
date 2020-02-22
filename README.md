在真机上运行这个工程需要拥有解锁NetworkExtension能力的证书（Provisioning Profile），而这里我所使用的方法是在越狱机器上绕开Apple的限制，具体方法可以参考[这篇文章](https://hello-david.github.io/archives/61787736.html)。

1. 这个项目仅作为个人学习用途（SwiftUI/NetworkExtension）。
2. 使用[这个issue](https://github.com/v2ray/v2ray-core/issues/1341)中讨论的[Tun2socks](https://github.com/eycorsican/go-tun2socks/tree/keepalive) + [V2RayCore](https://github.com/v2ray/v2ray-core/tree/v4.22.1)进行代理。
3. 由于NetworkExtension 15MB运行内存的限制，对于使用Go编写的V2Ray-Core和Tun2socks运行内存都有比较苛刻的需求。导致目前容易PacketTunnel超过15MB崩溃掉线，但发现用Instruments调试PacketTunnel时候内存竟然才几兆而且再也不会崩溃😓。

4. 数据流大概是这么一个样子：OtherApp <---> PacketTunnel <---IP Packet---> Tun2socks <---Socks Packet---> V2RayCore_Outbounds
 
### Tun2socks + V2RayCore 修改和使用
```
package tun2socks

import (
	"context"
	"runtime"
	"runtime/debug"
	"strings"
	"time"

	"github.com/eycorsican/go-tun2socks/common/log"
	"github.com/eycorsican/go-tun2socks/core"
	"github.com/eycorsican/go-tun2socks/proxy/v2ray"
	vcore "v2ray.com/core"
	vproxyman "v2ray.com/core/app/proxyman"
)

type PacketFlow interface {
	WritePacket(packet []byte)
}

func InputPacket(data []byte) {
	lwipStack.Write(data)
}

var lwipStack core.LWIPStack

func StartV2Ray(packetFlow PacketFlow, configBytes []byte) {
	if packetFlow == nil {
		return
	}

	lwipStack = core.NewLWIPStack()
	v, err := vcore.StartInstance("json", configBytes)
	if err != nil {
		log.Fatalf("start V instance failed: %v", err)
	}

	sniffingConfig := &vproxyman.SniffingConfig{
		Enabled:             true,
		DestinationOverride: strings.Split("tls,http", ","),
	}

	debug.SetGCPercent(5)
	ctx := vproxyman.ContextWithSniffingConfig(context.Background(), sniffingConfig)
	core.RegisterTCPConnHandler(v2ray.NewTCPHandler(ctx, v))
	core.RegisterUDPConnHandler(v2ray.NewUDPHandler(ctx, v, 30*time.Second))
	core.RegisterOutputFn(func(data []byte) (int, error) {
		packetFlow.WritePacket(data)
		runtime.GC()
		debug.FreeOSMemory()
		return len(data), nil
	})
}
```
