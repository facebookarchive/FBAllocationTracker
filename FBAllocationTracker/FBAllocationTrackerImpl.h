/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <unordered_map>

#import <Foundation/Foundation.h>

#import "FBAllocationTrackerDefines.h"
#import "FBAllocationTrackerFunctors.h"
#import "FBAllocationTrackerGenerationManager.h"

/**
 FBAllocationTracker is a simple tool that's only purpose is to be able to track
 allocated objects that are subclasses of NSObject (so mostly Objective-C objects).

 It should be able to track all allocations/deallocations, mark generations in time
 (snapshots of allocations similar to what Instruments offer) and grab instances for
 given classes.

 It should be enabled preferably as early in the application's lifetime as possible.
 Preferably in main.m

 Check FBAllocationTrackerManager.h for Objective-C accessors.
 */


#if _INTERNAL_FBAT_ENABLED

namespace FB { namespace AllocationTracker {

  struct SingleClassSummary {
    NSUInteger allocations;
    NSUInteger deallocations;
    NSUInteger instanceSize;
  };

  typedef std::unordered_map<Class, SingleClassSummary, ClassHashFunctor, ClassEqualFunctor> AllocationSummary;

  /**
   Generate summary snapshot for all allocations.

   @return unordered_map of Class->SingleClassSummary describing current snapshot of allocations
   */
  AllocationSummary allocationTrackerSummary();

  /**
   Swizzles NSObject's alloc and dealloc and starts tracking all Objective-C allocations.
   
   beginTracking() and endTracking() should be matched and shouldn't be nested.
   */
  void beginTracking();

  /**
   Swizzles back NSObject's alloc and dealloc, stops tracking allocations and clears out the data.
   */
  void endTracking();

  /**
   Is the tracker currently running?
   */
  bool isTracking();

  /**
   Enables generations. By default generations are not enabled, because they are additional
   hit to performance. (We are not tracking just counters, but objects itself)

   If the generation existed, it will do nothing
   */
  void enableGenerations();

  /**
   Disable generation tracking, clean all the generation data gathered so far.
   */
  void disableGenerations();

  /**
   Mark generation. Every generation keeps objects from between generation markers (two calls
   of markGeneration()) or beginning/now, respectively.
   */
  void markGeneration();

  /**
   Summary for all generations. It will be similar to allocations summary, but grouped by generations.
   */
  FullGenerationSummary generationSummary();

  /**
   Yields all classes that are being tracked by Allocation Tracker (all classes that's instances
   were created since enabling Allocation Tracker).
   */
  std::vector<__unsafe_unretained Class> trackedClasses();

  NSArray *instancesOfClasses(NSArray *classes);

  /**
   Tries to obtain instances of given class. This method might not be safe to use, proceed
   with caution. It will try to obtain strong reference of object (that will be of type
   __unsafe_unretained). If the object was scheduled to deletion, but was not yet dealloced,
   we will try to retain dangling pointer and crash.

   @param aCls - Class we are interested in
   @param generationIndex - from which generation we would like to get the objects
   @return vector of id types
   */
  std::vector<__weak id> instancesOfClassForGeneration(__unsafe_unretained Class aCls,
                                                       NSInteger generationIndex);

} }

#endif // _INTERNAL_FBAT_ENABLED
