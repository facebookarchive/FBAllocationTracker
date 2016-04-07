/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBAllocationTrackerSummary.h"

@implementation FBAllocationTrackerSummary

- (instancetype)initWithAllocations:(NSUInteger)allocations
                      deallocations:(NSUInteger)deallocations
                       aliveObjects:(NSInteger)aliveObjects
                          className:(NSString *)className
                       instanceSize:(NSUInteger)instanceSize
{
  if ((self = [super init])) {
    _allocations = allocations;
    _deallocations = deallocations;
    _aliveObjects = aliveObjects;
    _className = className;
    _instanceSize = instanceSize;
  }

  return self;
}

@end
