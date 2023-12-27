//
//  Shadowsocks.m
//  StealthRocketNetworkExtentsion
//
//  Created by Kuntal Sheth on 12/26/23.
//

#import "Shadowsocks.h"
#import "ConnectModel.h"
#import <pthread/pthread.h>
#import <Shadowsocks_iOS/shadowsocks.h>

@interface Shadowsocks ()

@property (nonatomic, assign) pthread_t ssLocalThreadId;

@property (nonatomic, strong) ConnectModel *model;

@property (nonatomic, copy) void (^startCompletion)(BOOL);

@property (nonatomic, copy) void (^stopCompletion)(void);

@end


@implementation Shadowsocks

- (void)startWithModel:(ConnectModel *)model completion:(void (^)(BOOL))completion {
    
    NSLog(@"extentsion - startWithModel model:%@", model);
    if (_ssLocalThreadId != 0) {
        return completion(false);
    }
    self.model = model;
    dispatch_async(dispatch_get_main_queue(), ^{
      
        self.startCompletion = completion;
        [self startShadowsocksThread];
    });
}

- (void)stop:(void (^)(void))completion {
    
    NSLog(@"extentsion - stop");
    if (self.ssLocalThreadId == 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.stopCompletion = completion;
        pthread_kill(self.ssLocalThreadId, SIGUSR1);
        self.ssLocalThreadId = 0;
    });
}

void *startShadowsocks(void *udata) {
    
    NSLog(@"extentsion - *startShadowsocks");
    Shadowsocks *ss = (__bridge Shadowsocks *)udata;
    [ss startShadowsocks];
    return NULL;
}

void shadowsocksCallback(int socks_fd, int udp_fd, void *udata) {
    
    NSLog(@"extentsion - shadowsocksCallback");
    if (socks_fd <= 0 || udp_fd <= 0) {
        return;
    }
    Shadowsocks *ss = (__bridge Shadowsocks *)udata;
    ss.startCompletion(YES);
}

- (void)startShadowsocksThread {
    
    NSLog(@"extentsion - startShadowsocksThread");
    pthread_attr_t attr;
    int err = pthread_attr_init(&attr);
    if (err) {
        
        self.startCompletion(false);
        return;
    }
    err = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    if (err) {
        
        self.startCompletion(false);
        return;
    }
    err = pthread_create(&_ssLocalThreadId, &attr, &startShadowsocks, (__bridge void *)self);
    if (err) {
        
        self.startCompletion(false);
    }
    err = pthread_attr_destroy(&attr);
    if (err) {
        self.startCompletion(false);
        return;
    }
}

- (void)startShadowsocks {
    
    NSLog(@"extentsion - startShadowsocks");
    if (self.model == nil) {
        self.startCompletion(false);
        return;
    }
    int port = [self.model.port intValue];
    char *host = (char *)[self.model.ip UTF8String];
    char *password = (char *)[self.model.password UTF8String];
    char *method = (char *)[self.model.encrypProtocol UTF8String];
    const profile_t profile = {
        .remote_host = host,
        .local_addr = "127.0.0.1",
        .method = method,
        .password = password,
        .remote_port = port,
        .local_port = 9999,
        .timeout = 20,
        .acl = NULL,
        .log = NULL,
        .fast_open = 0,
        .mode = 1,
        .verbose = 0
    };
    int success = start_ss_local_server_with_callback(profile, shadowsocksCallback, (__bridge void *)self);
    NSLog(@"extentsion - start_ss_local_server_with_callback success: %d", success);
    if (success < 0) {
        
        self.startCompletion(NO);
        return;
    }
    if (self.stopCompletion) {
        
        self.stopCompletion();
        self.stopCompletion = nil;
    }
}

@end
