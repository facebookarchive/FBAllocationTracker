/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import "FBAllocationTrackerGeneration.h"
#import "FBAllocationTrackerGenerationManager.h"
#include "FBAllocationTrackerNSZombieSupport.h"

@interface _FBATTestClass : NSObject
@end
@implementation _FBATTestClass
@end

@interface FBAllocationTrackerGenerationsTests : XCTestCase
@end

@implementation FBAllocationTrackerGenerationsTests
{
  FB::AllocationTracker::GenerationManager *_manager;
}

- (void)setUp
{
  [super setUp];

  _manager = new FB::AllocationTracker::GenerationManager();
}

- (void)tearDown
{
  delete _manager;
  _manager = nil;

  [super tearDown];
}

- (void)testThatMarkGenerationWillCreateNewGeneration
{
  for (NSInteger i = 0; i < 10; ++i) {
    _manager->markGeneration();
  }

  XCTAssertEqual(_manager->summary().size(), 10);
}

- (void)testThatManagerWillAddObjectToTheLastGeneration
{
  NSInteger numberOfGenerations = 3;
  NSInteger numberOfObjectsInGeneration = 100;

  NSMutableArray *holdingArray = [NSMutableArray new];

  for (NSInteger i = 0; i < numberOfGenerations; ++i) {
    _manager->markGeneration();
    for (NSInteger j = 0; j < numberOfObjectsInGeneration; ++j) {
      _FBATTestClass *object = [_FBATTestClass new];
      [holdingArray addObject:object];
      _manager->addObject(object);
    }
  }

  FB::AllocationTracker::FullGenerationSummary summary = _manager->summary();
  XCTAssertEqual(summary.size(), numberOfGenerations);

  for (NSInteger i = 0; i < numberOfGenerations; ++i) {
    XCTAssertEqual(summary[i].count([_FBATTestClass class]), 1);
    XCTAssertEqual(summary[i][[_FBATTestClass class]], numberOfObjectsInGeneration);
  }
}

- (void)testThatManagerWillAlwaysAddObjectToMostRecentGeneration
{
  // First generation
  _manager->markGeneration();

  _FBATTestClass *object1 = [_FBATTestClass new];
  _manager->addObject(object1);

  // Second generation
  _manager->markGeneration();

  _FBATTestClass *object2 = [_FBATTestClass new];
  _manager->addObject(object2);

  FB::AllocationTracker::FullGenerationSummary summary = _manager->summary();
  XCTAssertEqual(summary[0][[_FBATTestClass class]], 1);
}

- (void)testThatManagerWillProperlyRemoveObject
{
  _manager->markGeneration();
  NSMutableArray *objects = [NSMutableArray new];

  for (NSInteger i = 0; i < 100; ++i) {
    _FBATTestClass *object = [_FBATTestClass new];
    [objects addObject:object];
    _manager->addObject(object);
  }

  FB::AllocationTracker::FullGenerationSummary summary = _manager->summary();
  XCTAssertEqual(summary[0][[_FBATTestClass class]], 100);

  [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    _manager->removeObject(obj);
  }];

  summary = _manager->summary();
  XCTAssertEqual(summary[0][[_FBATTestClass class]], 0);
}

- (void)testThatManagerWillRemoveObjectIfItIsNotInLastGeneration
{
  _manager->markGeneration();
  _manager->markGeneration();
  NSMutableArray *objects = [NSMutableArray new];

  for (NSInteger i = 0; i < 100; ++i) {
    _FBATTestClass *object = [_FBATTestClass new];
    [objects addObject:object];
    _manager->addObject(object);
  }
  _manager->markGeneration();
  _manager->markGeneration();

  FB::AllocationTracker::FullGenerationSummary summary = _manager->summary();
  XCTAssertEqual(summary[1][[_FBATTestClass class]], 100);

  [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    _manager->removeObject(obj);
  }];

  summary = _manager->summary();
  XCTAssertEqual(summary[1][[_FBATTestClass class]], 0);
}

- (void)testThatManagerWillFetchInstancesOfGivenClassFromGivenGeneration
{
  _manager->markGeneration();
  _manager->markGeneration();

  NSMutableArray *objects = [NSMutableArray new];

  for (NSInteger i = 0; i < 100; ++i) {
    _FBATTestClass *object = [_FBATTestClass new];
    [objects addObject:object];
    _manager->addObject(object);
  }

  std::vector<__weak id> returnedInstances = _manager->instancesOfClassInGeneration([_FBATTestClass class], 1);
  NSMutableArray *instances = [NSMutableArray new];
  for (id obj: returnedInstances) {
    [instances addObject:obj];
  }
  XCTAssertEqual([instances count], 100);
  for (id object in objects) {
    XCTAssertTrue([instances containsObject:object]);
  }
}

- (void)testThatNSZobmieClassDetectionWorks {
  if (!fb_isNSZombieEnabled()) { return; }
  
  __unsafe_unretained id deallocatedObject = nil;
  @autoreleasepool {
    id testObject = [NSObject new];
    deallocatedObject = testObject;
  }
  
  XCTAssertTrue(fb_isZombieObject(deallocatedObject));
}

@end
