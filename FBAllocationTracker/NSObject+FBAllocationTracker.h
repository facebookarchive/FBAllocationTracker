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

/**
 This category will expose methods to swizzle allocs
 for NSObject. The allocs and deallocs will be registered
 by FBObjectTracker so we can easily track the changes in
 allocations.
 */

#if _INTERNAL_FBAT_ENABLED

@interface NSObject (FBAllocationTracker)

+ (nonnull id)fb_originalAlloc;
- (void)fb_originalDealloc;

+ (nonnull id)fb_newAlloc;
- (void)fb_newDealloc;

@end

#endif // _INTERNAL_FBAT_ENABLED
