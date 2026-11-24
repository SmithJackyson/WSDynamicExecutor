//
//  UIViewController+WSHook.m
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/17.
//

#import "UIViewController+WSHook.h"
#import "WSRuntimeUtils.h"
#import "../WSDynamicExecutorManager.h"

@implementation UIViewController (WSHook)

+ (void)load {
  [WSRuntimeUtils hookMethod:self originalSEL:@selector(loadView) implClass:self implSEL:@selector(ws_loadView)];
  [WSRuntimeUtils hookMethod:self originalSEL:@selector(viewDidLoad) implClass:self implSEL:@selector(ws_viewDidLoad)];
  [WSRuntimeUtils hookMethod:self originalSEL:@selector(viewWillAppear:) implClass:self implSEL:@selector(ws_viewWillAppear:)];
  [WSRuntimeUtils hookMethod:self originalSEL:@selector(viewIsAppearing:) implClass:self implSEL:@selector(ws_viewIsAppearing:)];
  [WSRuntimeUtils hookMethod:self originalSEL:@selector(viewDidAppear:) implClass:self implSEL:@selector(ws_viewDidAppear:)];
  [WSRuntimeUtils hookMethod:self originalSEL:@selector(viewWillDisappear:) implClass:self implSEL:@selector(ws_viewWillDisappear:)];
  [WSRuntimeUtils hookMethod:self originalSEL:@selector(viewDidDisappear:) implClass:self implSEL:@selector(ws_viewDidDisappear:)];
}

- (void)ws_loadView {
  [self ws_loadView];
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorLoadViewPeriod target:self];
}

- (void)ws_viewDidLoad {
  [self ws_viewDidLoad];
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorViewDidLoadPeriod target:self];
}

- (void)ws_viewWillAppear:(BOOL)animated {
  [self ws_viewWillAppear:animated];
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorViewWillAppearPeriod target:self];
}

- (void)ws_viewIsAppearing:(BOOL)animated {
  [self ws_viewIsAppearing:animated];
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorViewIsAppearingPeriod target:self];
}

- (void)ws_viewDidAppear:(BOOL)animated {
  [self ws_viewDidAppear:animated];
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorViewDidAppearPeriod target:self];
}

- (void)ws_viewWillDisappear:(BOOL)animated {
  [self ws_viewWillDisappear:animated];
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorViewWillDisappearPeriod target:self];
}

- (void)ws_viewDidDisappear:(BOOL)animated {
  [self ws_viewDidDisappear:animated];
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorViewDidDisappearPeriod target:self];
}

@end
