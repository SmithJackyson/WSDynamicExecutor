//
//  WSRuntimeUtils.h
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSRuntimeUtils : NSObject

+ (BOOL)hasInstanceMethod:(Class)className
                 selector:(SEL)selector;

+ (BOOL)hookMethod:(Class)originalClass
       originalSEL:(SEL)originalSEL
         implClass:(Class)implClass
           implSEL:(SEL)implSEL;

+ (BOOL)addMethod:(Class)className
         selector:(SEL)selector
        implClass:(Class)implClass;
+ (BOOL)addMethod:(Class)className
         selector:(SEL)selector
        implClass:(Class)implClass
          implSEL:(SEL)implSEL;

@end

NS_ASSUME_NONNULL_END
