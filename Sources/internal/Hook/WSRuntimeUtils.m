//
//  WSRuntimeUtils.m
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/16.
//

#import "WSRuntimeUtils.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@implementation WSRuntimeUtils

+ (BOOL)hasInstanceMethod:(Class)className
                 selector:(SEL)selector {
  Method method = class_getInstanceMethod(className, selector);
  return method != NULL;
}

+ (BOOL)hookMethod:(Class)originalClass
       originalSEL:(SEL)originalSEL
         implClass:(Class)implClass
           implSEL:(SEL)implSEL {
  if (originalSEL == implSEL) { return NO; }
  if (originalClass != implClass && [self hasInstanceMethod:originalClass selector:implSEL]) {
    NSAssert(false, @"original class has same method(%@)", NSStringFromSelector(implSEL));
    return NO;
  }
  Method originalMethod = class_getInstanceMethod(originalClass, originalSEL);
  Method implMethod = class_getInstanceMethod(implClass, implSEL);
  if (!originalMethod || !implMethod) {
    NSAssert(false, @"selector of original class or impl class has no implementation");
    return NO;
  }
  
  if (originalClass != implClass) {
    [self addMethod:originalClass selector:implSEL implClass:implClass];
  }
  implMethod = class_getInstanceMethod(originalClass, implSEL);
  if (!implMethod) {
    NSAssert(false, @"original class has no implSEL method");
    return NO;
  }
  method_exchangeImplementations(originalMethod, implMethod);
  return YES;
}

+ (BOOL)addMethod:(Class)className
         selector:(SEL)selector
        implClass:(Class)implClass {
  return [self addMethod:className
                selector:selector
               implClass:implClass
                 implSEL:selector];
}

+ (BOOL)addMethod:(Class)className
         selector:(SEL)selector
        implClass:(Class)implClass
          implSEL:(SEL)implSEL {
  Method implMethod = class_getInstanceMethod(implClass, implSEL);
  if (!implMethod) {
    NSAssert(false, @"impl class has no implSEL method");
    return NO;
  }
  
  BOOL success = class_addMethod(className,
                                 selector,
                                 method_getImplementation(implMethod),
                                 method_getTypeEncoding(implMethod));
  return success;
}

@end

NS_ASSUME_NONNULL_END
