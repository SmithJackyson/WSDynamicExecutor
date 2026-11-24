//
//  WSExecutorScanner.m
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/23.
//

#import "WSExecutorScanner.h"
#import <mach-o/getsect.h>
#import <mach-o/dyld.h>
#import <mach-o/loader.h>
@import WSExecutorCommon;
@import WSDynamicExecutorInternal;

NS_ASSUME_NONNULL_BEGIN

@interface WSExecutorScanner ()

@end

@implementation WSExecutorScanner

- (instancetype)init {
  self = [super init];
  if (self) {
    self.groupExecutors = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)loadExecutors {
  uint32_t image_count = _dyld_image_count();
  for (uint32_t i = 0; i < image_count; i++) {
    const struct mach_header_64 *header = (const struct mach_header_64 *)_dyld_get_image_header(i);
    [self loadExecutorsInImage:header];
    [self loadSwiftExecutorsInImage:header];
  }
}

- (void)loadExecutorsInImage:(const struct mach_header_64 *)header {
  if (!header) { return; }
  
  unsigned long sectionSize = 0;
  uint8_t *sectionData = getsectiondata(header, "__DATA", "__ws_executors", &sectionSize);
  if (!sectionData || sectionSize == 0) { return; }
  
  if (sectionSize % sizeof(WSExecutorDescriptor) != 0) {
    NSCAssert(false, @"[WSDynamicExecutor]: section data is missing");
    return;
  }
  
  size_t count = sectionSize / sizeof(WSExecutorDescriptor);
  WSExecutorDescriptor *descriptor = (WSExecutorDescriptor *)sectionData;
  for (size_t i = 0; i < count; i++) {
    WSExecutorPeriod period = descriptor->options.period;
    NSMutableArray<NSValue *> *array = [self.groupExecutors objectForKey:[NSNumber numberWithUnsignedChar:period]];
    if (!array) {
      array = [[NSMutableArray alloc] init];
      [self.groupExecutors setObject:array forKey:[NSNumber numberWithUnsignedChar:period]];
    }
    [array addObject:[NSValue valueWithPointer:descriptor]];
    descriptor++;
  }
}

- (void)loadSwiftExecutorsInImage:(const struct mach_header_64 *)header {
  NSDictionary<NSNumber *, NSArray<NSValue *> *> *swiftDescriptors = [WSSwiftExecutorScanner loadExecutorsInImage:header];
  NSArray<NSNumber *> *keys = swiftDescriptors.allKeys;
  for (int i = 0; i < keys.count; i++) {
    NSArray<NSValue *> *swiftArray = swiftDescriptors[keys[i]];
    NSMutableArray<NSValue *> *array = [self.groupExecutors objectForKey:keys[i]];
    if (!array) {
      array = [[NSMutableArray alloc] init];
      [self.groupExecutors setObject:array forKey:keys[i]];
    }
    [array addObjectsFromArray:swiftArray];
  }
}

@end

NS_ASSUME_NONNULL_END
