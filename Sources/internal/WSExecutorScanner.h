//
//  WSExecutorScanner.h
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSExecutorScanner : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<NSValue *> *> *groupExecutors;

- (void)loadExecutors;

@end

NS_ASSUME_NONNULL_END
