/**
 * Copyright (c) 2017-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import "FBAllocationTrackerManager.h"

@interface _FBATMTestClass : NSObject
@end
@implementation _FBATMTestClass
@end

@interface FBAllocationTrackerManagerTests : XCTestCase
@end

@implementation FBAllocationTrackerManagerTests

- (void)setUp
{
  [super setUp];
  
  [[FBAllocationTrackerManager sharedManager] startTrackingAllocations];
  [[FBAllocationTrackerManager sharedManager] enableGenerations];
}

- (void)tearDown
{
  [[FBAllocationTrackerManager sharedManager] disableGenerations];
  [[FBAllocationTrackerManager sharedManager] stopTrackingAllocations];
  
  [super tearDown];
}

- (void)testAllocWithZoneIsTracked {
    XCTAssertEqualObjects(@[], [[FBAllocationTrackerManager sharedManager] instancesOfClasses:@[[_FBATMTestClass class]]]);
    id object = [[_FBATMTestClass allocWithZone:nil] init];
    XCTAssertEqualObjects(@[object], [[FBAllocationTrackerManager sharedManager] instancesOfClasses:@[[_FBATMTestClass class]]]);
}

@end
