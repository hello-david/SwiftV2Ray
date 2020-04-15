//
//  tun2socks.h
//  tun2socks
//
//  Created by LEI on 7/24/16.
//  Copyright © 2016 TouchingApp. All rights reserved.
//

#ifndef tun2socks_h
#define tun2socks_h

#include <stdio.h>

typedef void (*tun_cb)(char *data, int data_len);

void start_tun2socks(uint32_t ip4_addr, uint32_t ip4_netmask, tun_cb tun_write_cb);

extern void stop_tun2socks();

extern void tun_input(char *data, int data_len);

#endif /* tun2socks_h */
