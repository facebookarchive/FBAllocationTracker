/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#if __has_feature(objc_arc)
#error This file must be compiled with MRR. Use -fno-objc-arc flag.
#endif

#import "NSObject+FBAllocationTracker.h"

#import "FBAllocationTrackerDefines.h"
#import "FBAllocationTrackerHelpers.h"

#if _INTERNAL_FBAT_ENABLED

@implementation NSObject (FBAllocationTracker)

+ (id)fb_originalAlloc
{
  // Placeholder for original alloc
  return nil;
}

- (void)fb_originalDealloc
{
  // Placeholder for original dealloc
}

+ (id)fb_newAlloc
{
  id object = [self fb_originalAlloc];
  FB::AllocationTracker::incrementAllocations(object);
  return object;
}

- (void)fb_newDealloc
{
  FB::AllocationTracker::incrementDeallocations(self);
  [self fb_originalDealloc];
}

@end

#endif // _INTERNAL_FBAT_ENABLED
