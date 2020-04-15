//
//  tun.h
//  tun2socks
//
//  Created by LEI on 7/26/16.
//  Copyright © 2016 TouchingApp. All rights reserved.
//

#ifndef tun_h
#define tun_h

#include <stdio.h>

typedef void (*tun_cb)(char *data, int data_len);

int tun_init(int mtu);

void tun_start(tun_cb read_cb, tun_cb write_cb);

void tun_stop();

void tun_input(char *data, int data_len);

void tun_write(char *data, int data_len);

int tun_mtu();

char* tun_buf();

#endif /* tun_h */
