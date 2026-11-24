//
//  WSAppDelegateHook.h
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIApplication.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSAppDelegateHook : NSObject

+ (void)hookAppDelegateMethods:(id<UIApplicationDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
