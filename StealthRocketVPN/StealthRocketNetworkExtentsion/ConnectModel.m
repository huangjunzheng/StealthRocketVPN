//
//  ConnectModel.m
//  StealthRocketNetworkExtentsion
//
//  Created by Kuntal Sheth on 12/26/23.
//

#import "ConnectModel.h"

@implementation ConnectModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    
    self = [super init];
    if (self) {
        
        self.port = dic[@"port"];
        self.ip = dic[@"ip"];
        self.password = dic[@"password"];
        self.encrypProtocol = dic[@"encrypProtocol"];
    }
    return self;
}

@end
