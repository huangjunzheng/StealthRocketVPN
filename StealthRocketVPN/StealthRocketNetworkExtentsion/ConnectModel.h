//
//  ConnectModel.h
//  StealthRocketNetworkExtentsion
//
//  Created by Kuntal Sheth on 12/26/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConnectModel : NSObject

@property (nonatomic, strong) NSString *port;

@property (nonatomic, strong) NSString *ip;

@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSString *encrypProtocol;


- (instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
