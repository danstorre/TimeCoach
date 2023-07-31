//
//  InstanceHelper.h
//  TimeCoach Watch AppTests
//
//  Created by Daniel Torres on 7/31/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InstanceHelper : NSObject
+ (id)createInstance:(Class)clazz;
+ (id)createInstance:(Class)clazz properties:(NSDictionary *)properties;
@end

NS_ASSUME_NONNULL_END
