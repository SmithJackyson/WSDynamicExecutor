//
//  UIScene+WSHook.m
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/18.
//

#import "UIScene+WSHook.h"
#import "WSRuntimeUtils.h"
#import "../WSDynamicExecutorManager.h"
#import <objc/runtime.h>

static NSMutableSet<NSString *> *hookedSet = NULL;

@implementation UIScene (WSHook)

+ (void)load {
  hookedSet = [[NSMutableSet alloc] init];
  [WSRuntimeUtils hookMethod:self originalSEL:@selector(initWithSession:connectionOptions:) implClass:self implSEL:@selector(ws_initWithSession:connectionOptions:)];
  [WSRuntimeUtils hookMethod:self originalSEL:@selector(setDelegate:) implClass:self implSEL:@selector(ws_setDelegate:)];
}

- (instancetype)ws_initWithSession:(UISceneSession *)session connectionOptions:(UISceneConnectionOptions *)connectionOptions {
  UIScene *scene = [self ws_initWithSession:session connectionOptions:connectionOptions];
  [UIScene ws_installHook:scene.delegate];
  return scene;
}

- (void)ws_setDelegate:(nullable id<UISceneDelegate>)delegate {
  [self ws_setDelegate:delegate];
  [UIScene ws_installHook:delegate];
}

+ (void)ws_installHook:(nullable id<UISceneDelegate>)delegate {
  if (delegate == nil) { return; }
  Class delegateClass = object_getClass(delegate);
  NSString *className = NSStringFromClass(delegateClass);
  if ([hookedSet containsObject:className]) { return; }
  
  [hookedSet addObject:className];
  [WSRuntimeUtils hookMethod:delegateClass originalSEL:@selector(scene:willConnectToSession:options:) implClass:self implSEL:@selector(ws_scene:willConnectToSession:options:)];
  [WSRuntimeUtils hookMethod:delegateClass originalSEL:@selector(sceneDidBecomeActive:) implClass:self implSEL:@selector(ws_sceneDidBecomeActive:)];
  [WSRuntimeUtils hookMethod:delegateClass originalSEL:@selector(sceneWillResignActive:) implClass:self implSEL:@selector(ws_sceneWillResignActive:)];
  [WSRuntimeUtils hookMethod:delegateClass originalSEL:@selector(sceneWillEnterForeground:) implClass:self implSEL:@selector(ws_sceneWillEnterForeground:)];
  [WSRuntimeUtils hookMethod:delegateClass originalSEL:@selector(sceneDidEnterBackground:) implClass:self implSEL:@selector(ws_sceneDidEnterBackground:)];
  [WSRuntimeUtils hookMethod:delegateClass originalSEL:@selector(sceneDidDisconnect:) implClass:self implSEL:@selector(ws_sceneDidDisconnect:)];
}

- (void)ws_scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
  [self ws_scene:scene willConnectToSession:session options:connectionOptions];
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorSceneWillConnectPeriod target:scene];
}

- (void)ws_sceneDidBecomeActive:(UIScene *)scene {
  [self ws_sceneDidBecomeActive:scene];
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorSceneDidBecomeActivePeriod target:scene];
}

- (void)ws_sceneWillResignActive:(UIScene *)scene {
  [self ws_sceneWillResignActive:scene];
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorSceneWillResignActivePeriod target:scene];
}

- (void)ws_sceneWillEnterForeground:(UIScene *)scene {
  [self ws_sceneWillEnterForeground:scene];
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorSceneWillEnterForegroundPeriod target:scene];
}

- (void)ws_sceneDidEnterBackground:(UIScene *)scene {
  [self ws_sceneDidEnterBackground:scene];
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorSceneDidEnterBackgroundPeriod target:scene];
}

- (void)ws_sceneDidDisconnect:(UIScene *)scene {
  [self ws_sceneDidDisconnect:scene];
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorSceneDidDisconnectPeriod target:scene];
}

@end
