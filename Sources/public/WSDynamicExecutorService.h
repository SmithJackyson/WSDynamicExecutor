//
//  WSDynamicExecutorService.h
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/19.
//

#import <Foundation/Foundation.h>
#import "WSExecutorConditionDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSDynamicExecutorService : NSObject

+ (void)setConditionDelegate:(id<WSExecutorConditionDelegate>)condDelegate;

@end

NS_ASSUME_NONNULL_END
