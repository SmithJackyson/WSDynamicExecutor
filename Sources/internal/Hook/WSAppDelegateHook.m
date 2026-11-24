//
//  WSAppDelegateHook.m
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/16.
//

#import "WSAppDelegateHook.h"
#import "WSRuntimeUtils.h"
#import "../WSDynamicExecutorManager.h"

NS_ASSUME_NONNULL_BEGIN

static NSMutableSet<NSString *> *addMethods = NULL;

@implementation WSAppDelegateHook

+ (void)hookAppDelegateMethods:(id<UIApplicationDelegate>)delegate {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    addMethods = [[NSMutableSet alloc] init];
    Class targetClass = delegate.class;
    [self hookMethod:targetClass selector:@selector(application:willFinishLaunchingWithOptions:)];
    [self hookMethod:targetClass selector:@selector(application:didFinishLaunchingWithOptions:)];
    [self hookMethod:targetClass selector:@selector(applicationDidBecomeActive:)];
    [self hookMethod:targetClass selector:@selector(applicationWillResignActive:)];
    [self hookMethod:targetClass selector:@selector(applicationDidEnterBackground:)];
    [self hookMethod:targetClass selector:@selector(applicationWillEnterForeground:)];
    [self hookMethod:targetClass selector:@selector(applicationDidReceiveMemoryWarning:)];
    [self hookMethod:targetClass selector:@selector(applicationWillTerminate:)];
  });
}

+ (void)hookMethod:(Class)originalClass selector:(SEL)selector {
  NSString *string = NSStringFromSelector(selector);
  NSString *targetString = [@"ws_" stringByAppendingString:string];
  SEL targetSelector = NSSelectorFromString(targetString);
  
  if (![WSRuntimeUtils hasInstanceMethod:originalClass selector:selector]) {
    BOOL success = [WSRuntimeUtils addMethod:originalClass selector:selector implClass:self implSEL:targetSelector];
    if (success) {
      [addMethods addObject:NSStringFromSelector(selector)];
    }
    return;
  }
  
  [WSRuntimeUtils hookMethod:originalClass originalSEL:selector implClass:self implSEL:targetSelector];
}

#pragma mark - Hook

- (BOOL)ws_application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
  NSString *selector = NSStringFromSelector(@selector(application:willFinishLaunchingWithOptions:));
  BOOL result = YES;
  if (![addMethods containsObject:selector]) {
    result = [self ws_application:application willFinishLaunchingWithOptions:launchOptions];
  }
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorWillFinishLaunchPeriod
                                                 target:application];
  return result;
}

- (BOOL)ws_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSString *selector = NSStringFromSelector(@selector(application:didFinishLaunchingWithOptions:));
  BOOL result = YES;
  if (![addMethods containsObject:selector]) {
    result = [self ws_application:application didFinishLaunchingWithOptions:launchOptions];
  }
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorDidFinishLaunchPeriod
                                                 target:application];
  return result;
}

- (void)ws_applicationDidBecomeActive:(UIApplication *)application {
  NSString *selector = NSStringFromSelector(@selector(applicationDidBecomeActive:));
  if (![addMethods containsObject:selector]) {
    [self ws_applicationDidBecomeActive:application];
  }
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorDidBecomeActivePeriod
                                                 target:application];
}

- (void)ws_applicationWillResignActive:(UIApplication *)application {
  NSString *selector = NSStringFromSelector(@selector(applicationWillResignActive:));
  if (![addMethods containsObject:selector]) {
    [self ws_applicationWillResignActive:application];
  }
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorWillResignActivePeriod
                                                 target:application];
}

- (void)ws_applicationDidEnterBackground:(UIApplication *)application {
  NSString *selector = NSStringFromSelector(@selector(applicationDidEnterBackground:));
  if (![addMethods containsObject:selector]) {
    [self ws_applicationDidEnterBackground:application];
  }
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorDidEnterBackgroundPeriod
                                                 target:application];
}

- (void)ws_applicationWillEnterForeground:(UIApplication *)application {
  NSString *selector = NSStringFromSelector(@selector(applicationWillEnterForeground:));
  if (![addMethods containsObject:selector]) {
    [self ws_applicationWillEnterForeground:application];
  }
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorWillEnterForegroundPeriod
                                                 target:application];
}

- (void)ws_applicationDidReceiveMemoryWarning:(UIApplication *)application {
  NSString *selector = NSStringFromSelector(@selector(applicationDidReceiveMemoryWarning:));
  if (![addMethods containsObject:selector]) {
    [self ws_applicationDidReceiveMemoryWarning:application];
  }
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorReceiveMemoryWarningPeriod
                                                 target:application];
}

- (void)ws_applicationWillTerminate:(UIApplication *)application {
  NSString *selector = NSStringFromSelector(@selector(applicationWillTerminate:));
  if (![addMethods containsObject:selector]) {
    [self ws_applicationWillTerminate:application];
  }
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorWillTerminatePeriod
                                                 target:application];
}

@end

NS_ASSUME_NONNULL_END
