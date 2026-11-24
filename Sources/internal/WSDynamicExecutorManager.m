//
//  WSDynamicExecutorManager.m
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/14.
//

#import "WSDynamicExecutorManager.h"
#import "WSDynamicExecutorDefine.h"
#import "WSExecutorScanner.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSDynamicExecutorManager ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<NSValue *> *> *groupExecutors;
@property (nonatomic, strong) NSMutableSet<NSString *> *executedTask;

@end

@implementation WSDynamicExecutorManager

+ (void)load {
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorLoadPeriod target:nil];
}

+ (instancetype)shared {
  static dispatch_once_t onceToken;
  static WSDynamicExecutorManager *manager = NULL;
  dispatch_once(&onceToken, ^{
    manager = [[WSDynamicExecutorManager alloc] init];
  });
  return manager;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.executedTask = [[NSMutableSet alloc] init];
    [self loadExecutors];
    [self sortExecutors];
  }
  return self;
}

- (void)loadExecutors {
  WSExecutorScanner *scanner = [[WSExecutorScanner alloc] init];
  [scanner loadExecutors];
  self.groupExecutors = scanner.groupExecutors;
}

- (void)sortExecutors {
  NSArray<NSMutableArray<NSValue*> *> *groupArray = self.groupExecutors.allValues;
  for (size_t i = 0; i < groupArray.count; i++) {
    NSMutableArray *executors = groupArray[i];
    [executors sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
      WSExecutorDescriptor *descriptor1 = [obj1 pointerValue];
      WSExecutorDescriptor *descriptor2 = [obj2 pointerValue];
      if (descriptor1->options.priority > descriptor2->options.priority) {
        return NSOrderedAscending;
      } else if (descriptor1->options.priority == descriptor2->options.priority) {
        return NSOrderedSame;
      } else {
        return NSOrderedDescending;
      }
    }];
  }
}

#pragma mark - public methods

- (void)runExecutorsInPeriod:(WSExecutorPeriod)period target:(nullable NSObject *)target {
  NSMutableArray<NSValue*> *array = [self.groupExecutors objectForKey:[NSNumber numberWithUnsignedChar:period]];
  for (NSUInteger i = 0; i < array.count; i++) {
    NSValue *value = [array objectAtIndex:i];
    WSExecutorDescriptor *descriptor = [value pointerValue];
    WSExecutorFlags flags = descriptor->options.flags;
    NSString *taskName = [NSString stringWithCString:descriptor->name encoding:NSUTF8StringEncoding];
    if ((flags & WSExecutorFlagsOnce) && [self.executedTask containsObject:taskName]) { continue; }
    
    if (descriptor->options.period > WSExecutorWillTerminatePeriod && target != nil && descriptor->options.targetClass != NULL) {
      NSObject *object = (NSObject *)target;
      Class objectClass = object_getClass(target);
      Class targetClass = objc_getClass(descriptor->options.targetClass);
      BOOL isTarget = NO;
      if (flags & WSExecutorFlagsInherit) {
        isTarget = [object isKindOfClass:targetClass];
      } else {
        isTarget = (objectClass == targetClass);
      }
      if (isTarget) {
        [self doExecutor:descriptor target:target];
      }
    } else {
      [self doExecutor:descriptor target:target];
    }
  }
}

- (void)doExecutor:(WSExecutorDescriptor *)descriptor target:(nullable NSObject *)target {
  dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
  NSString *taskName = [NSString stringWithCString:descriptor->name encoding:NSUTF8StringEncoding];
  WSExecutorFlags flags = descriptor->options.flags;
  if (flags & WSExecutorFlagsAsync) {
    NSDate *date = [NSDate date];
    WSWeakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, descriptor->options.delayTime), queue, ^{
      WSStrongify(self);
      NSDate *date1 = [NSDate date];
      NSLog(@"%f", [date1 timeIntervalSinceDate:date]);
      [strongself.executedTask addObject:taskName];
      WSExecutorContext context = { .target = target };
      descriptor->executor(context);
    });
  } else {
    [self.executedTask addObject:taskName];
    WSExecutorContext context = { .target = target };
    descriptor->executor(context);
  }
}

@end

__attribute__((constructor(101)))
static void WSRunConstructorExecutors(void) {
  [WSDynamicExecutorManager.shared runExecutorsInPeriod:WSExecutorConstructorPeriod target:nil];
}

NS_ASSUME_NONNULL_END
