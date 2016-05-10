/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBAllocationTrackerDefines.h"

#if _INTERNAL_FBAT_ENABLED

namespace FB { namespace AllocationTracker {

  /**
   Helper function that NSObject swizzles will use to increment on alloc
   */
  void incrementAllocations(__unsafe_unretained id obj);

  /**
   Helper function that NSObject swizzles will use to decrement on dealloc
   */
  void incrementDeallocations(__unsafe_unretained id obj);

} }

#endif
