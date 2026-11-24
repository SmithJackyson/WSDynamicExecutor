//
//  WSDynamicExecutorService.m
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/19.
//

#import "WSDynamicExecutorService.h"
#import "WSDynamicExecutorManager.h"

NS_ASSUME_NONNULL_BEGIN

@implementation WSDynamicExecutorService

+ (void)setConditionDelegate:(id<WSExecutorConditionDelegate>)condDelegate {
  WSDynamicExecutorManager.shared.condDelegate = condDelegate;
}

@end

NS_ASSUME_NONNULL_END
