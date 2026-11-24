//
//  WSDynamicExecutorManager.h
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/14.
//

#import <Foundation/Foundation.h>
#import "WSExecutorConditionDelegate.h"
@import WSExecutorCommon;

NS_ASSUME_NONNULL_BEGIN

@interface WSDynamicExecutorManager : NSObject

@property (nonatomic, strong) id<WSExecutorConditionDelegate> condDelegate;

+ (instancetype)shared;
- (void)runExecutorsInPeriod:(WSExecutorPeriod)period target:(nullable NSObject *)target;

@end

NS_ASSUME_NONNULL_END
