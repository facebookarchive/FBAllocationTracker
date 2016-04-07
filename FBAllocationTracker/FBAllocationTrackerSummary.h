/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

@interface FBAllocationTrackerSummary : NSObject

@property (nonatomic, readonly) NSUInteger allocations;
@property (nonatomic, readonly) NSUInteger deallocations;
@property (nonatomic, readonly) NSInteger aliveObjects;
@property (nonatomic, copy, readonly, nonnull) NSString *className;
@property (nonatomic, readonly) NSUInteger instanceSize;

- (nonnull instancetype)initWithAllocations:(NSUInteger)allocations
                              deallocations:(NSUInteger)deallocations
                               aliveObjects:(NSInteger)aliveObjects
                                  className:(nonnull NSString *)className
                               instanceSize:(NSUInteger)instanceSize;

@end
