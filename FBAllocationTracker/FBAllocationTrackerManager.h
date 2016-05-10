/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import "FBAllocationTrackerDefines.h"

#ifdef __cplusplus
extern "C" {
#endif

BOOL FBIsFBATEnabledInThisBuild(void);

#ifdef __cplusplus
}
#endif

@class FBAllocationTrackerSummary;

/**
 FBAllocationTrackerManager is a wrapper around C++ Allocation Tracker API.
 This will let you interact with FBAllocationTracker using just Objective-C.
 Because FBAllocationTracker is guarded by compilation flag, all calls in this
 API are nullable.
 */
@interface FBAllocationTrackerManager : NSObject

+ (nullable instancetype)sharedManager;

/**
 Enable tracking allocations.
 */
- (void)startTrackingAllocations;

/**
 Disable tracking allocations. It will clear all data gathered so far.
 */
- (void)stopTrackingAllocations;

- (BOOL)isAllocationTrackerEnabled;

/**
 Grab summary snapshot for current moment. Every object in this array will have a quick
 snapshot containing how many instances were allocated/deallocated and few more.
 Check FBAllocationTrackerSummary.h.
 */
- (nullable NSArray<FBAllocationTrackerSummary *> *)currentAllocationSummary;

/**
 Enable generations. If generations were already enabled, it won't do anything.
 
 The number of enables and disables must match.
 */
- (void)enableGenerations;

/**
 Disable generations. It will remove all generations data.
 */
- (void)disableGenerations;

/**
 Marks generation. Every allocation is attributed to just one generation. After you mark
 generation - all new allocations will be dropped to the new generation bucket.
 */
- (void)markGeneration;

/**
 Creates summary for all generations. Every element will be a summary for one generation.
 In every generation the summary for given class will be described inside FBAllocationTrackerSummary
 object.
 Returns nil if generations are not enabled.
 */
- (nullable NSArray<NSArray<FBAllocationTrackerSummary *> *> *)currentSummaryForGenerations;

/**
 Accessor to browse objects inside Allocation Tracker. You can browse objects only if generations
 are enabled (otherwise you are just tracking counters).
 Returns nil if generations are not enabled.
 */
- (nullable NSArray *)instancesForClass:(nonnull __unsafe_unretained Class)aCls
                           inGeneration:(NSInteger)generation;


/**
 Grab all instances of given classes across all generations.
 Returns nil if generations are not enabled.
 */
- (nullable NSArray *)instancesOfClasses:(nonnull NSArray *)classes;

/**
 Gets all classes that were used in allocation tracker. Basically if any instance of given
 class was created when Allocation Tracker was enabled - this class will be there.
 */
- (nullable NSSet<Class> *)trackedClasses;

@end
