//
//  Shadowsocks.h
//  StealthRocketNetworkExtentsion
//
//  Created by Kuntal Sheth on 12/26/23.
//

#import <Foundation/Foundation.h>
@class ConnectModel;

NS_ASSUME_NONNULL_BEGIN

@interface Shadowsocks : NSObject

- (void)startWithModel:(ConnectModel *)model completion:(void (^)(BOOL))completion;

- (void)stop:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
