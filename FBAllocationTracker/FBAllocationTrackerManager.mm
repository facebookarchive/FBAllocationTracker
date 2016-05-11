/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBAllocationTrackerManager.h"

#import <objc/runtime.h>

#import "FBAllocationTrackerDefines.h"
#import "FBAllocationTrackerImpl.h"
#import "FBAllocationTrackerSummary.h"

BOOL FBIsFBATEnabledInThisBuild(void)
{
#if _INTERNAL_FBAT_ENABLED
  return YES;
#endif
  return NO;
}

#if _INTERNAL_FBAT_ENABLED
@implementation FBAllocationTrackerManager {
  dispatch_queue_t _queue;
  NSUInteger _generationsClients;
}

- (instancetype)init
{
  if (self = [super init]) {
    _queue = dispatch_queue_create("com.facebook.fbat.manager", DISPATCH_QUEUE_SERIAL);
  }
  
  return self;
}

+ (instancetype)sharedManager
{
  static FBAllocationTrackerManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [FBAllocationTrackerManager new];
  });
  return sharedManager;
}


- (BOOL)isAllocationTrackerEnabled
{
  return FB::AllocationTracker::isTracking();
}

- (void)stopTrackingAllocations
{
  FB::AllocationTracker::endTracking();
}

- (void)startTrackingAllocations
{
  FB::AllocationTracker::beginTracking();
}

- (void)enableGenerations
{
  dispatch_async(_queue, ^{
    if (_generationsClients == 0) {
      FB::AllocationTracker::enableGenerations();
      FB::AllocationTracker::markGeneration();
    }
    _generationsClients += 1;
  });
}

- (void)disableGenerations
{
  dispatch_async(_queue, ^{
    _generationsClients -= 1;
    if (_generationsClients <= 0) {
      FB::AllocationTracker::disableGenerations();
    }
  });
}

- (void)markGeneration
{
  FB::AllocationTracker::markGeneration();
}

- (NSArray<FBAllocationTrackerSummary *> *)currentAllocationSummary
{
  FB::AllocationTracker::AllocationSummary summary = FB::AllocationTracker::allocationTrackerSummary();
  NSMutableArray<FBAllocationTrackerSummary *> *array = [NSMutableArray new];

  for (const auto &item: summary) {
    FB::AllocationTracker::SingleClassSummary singleSummary = item.second;
    Class aCls = item.first;
    NSString *className = NSStringFromClass(aCls);

    FBAllocationTrackerSummary *summaryObject =
    [[FBAllocationTrackerSummary alloc] initWithAllocations:singleSummary.allocations
                                              deallocations:singleSummary.deallocations
                                               aliveObjects:singleSummary.allocations - singleSummary.deallocations
                                                  className:className
                                               instanceSize:singleSummary.instanceSize];
    [array addObject:summaryObject];
  }

  return array;
}

- (NSArray<FBAllocationTrackerSummary *> *)_getSingleGenerationSummary:(const FB::AllocationTracker::GenerationSummary &)summary
{
  NSMutableArray *array = [NSMutableArray new];

  for (const auto &kv: summary) {
    FBAllocationTrackerSummary *summaryObject =
    [[FBAllocationTrackerSummary alloc] initWithAllocations:0
                                              deallocations:0
                                               aliveObjects:kv.second
                                                  className:NSStringFromClass(kv.first)
                                               instanceSize:class_getInstanceSize(kv.first)];

    [array addObject:summaryObject];
  }

  return array;
}
- (NSArray<NSArray<FBAllocationTrackerSummary *> *> *)currentSummaryForGenerations
{
  FB::AllocationTracker::FullGenerationSummary summary = FB::AllocationTracker::generationSummary();
  
  if (summary.size() == 0) {
    return nil;
  }
  
  NSMutableArray *array = [NSMutableArray new];

  for (const auto &generation: summary) {
    [array addObject:[self _getSingleGenerationSummary:generation]];
  }

  return array;
}


- (NSArray *)instancesForClass:(__unsafe_unretained Class)aCls
                  inGeneration:(NSInteger)generation
{
  std::vector<__weak id> objects = FB::AllocationTracker::instancesOfClassForGeneration(aCls, generation);
  
  if (objects.size() == 0) {
    return nil;
  }
  
  NSMutableArray *objectArray = [NSMutableArray new];
  for (id obj: objects) {
    if (obj) {
      [objectArray addObject:obj];
    }
  }
  return objectArray;
}

- (NSArray *)instancesOfClasses:(NSArray *)classes
{
  return FB::AllocationTracker::instancesOfClasses(classes);
}

- (NSSet *)trackedClasses
{
  std::vector<__unsafe_unretained Class> classes = FB::AllocationTracker::trackedClasses();
  return [NSSet setWithObjects:classes.data() count:classes.size()];
}

@end

#else

@implementation FBAllocationTrackerManager

+ (instancetype)sharedManager
{
  return nil;
}

- (BOOL)isAllocationTrackerEnabled
{
  return NO;
}

- (void)startTrackingAllocations {}
- (void)stopTrackingAllocations {}

- (void)enableGenerations {}
- (void)disableGenerations {}
- (void)markGeneration {}

- (NSArray *)currentAllocationSummary
{
  return nil;
}

- (NSArray *)currentSummaryForGenerations
{
  return nil;
}

- (NSArray *)instancesForClass:(__unsafe_unretained Class)aCls
                  inGeneration:(NSInteger)generation
{
  return nil;
}

- (NSArray *)instancesOfClasses:(NSArray *)classes
{
  return nil;
}

- (NSSet *)trackedClasses
{
  return nil;
}

@end

#endif
