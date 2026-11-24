//
//  UIApplication+WSHook.m
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/16.
//

#import "UIApplication+WSHook.h"
#import "WSRuntimeUtils.h"
#import "WSAppDelegateHook.h"

@implementation UIApplication (WSHook)

+ (void)load {
  [WSRuntimeUtils hookMethod:self originalSEL:@selector(setDelegate:) implClass:self implSEL:@selector(ws_setDelegate:)];
}

- (void)ws_setDelegate:(id<UIApplicationDelegate>)delegate {
  [self ws_setDelegate:delegate];
  [WSAppDelegateHook hookAppDelegateMethods:delegate];
}

@end
