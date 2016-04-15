# FBAllocationTracker
[![Build Status](https://travis-ci.org/facebook/FBAllocationTracker.svg?branch=master)](https://travis-ci.org/facebook/FBAllocationTracker)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/FBAllocationTracker.svg?maxAge=2592000)]()
[![License](https://img.shields.io/cocoapods/l/FBAllocationTracker.svg)](https://github.com/facebook/FBallocationTracker/blob/master/LICENSE)


An iOS library for introspecting Objective-C objects that are currently alive.

# About

`FBAllocationTracker` is a tool that can be used as an interface to Objective-C objects allocated in memory. It can be used to query all instances of given class, or you can (as in Instruments) mark generations and query for objects created only in scope of one generation.

## Installation

### Carthage

To your Cartfile add: 

    github "facebook/FBAllocationTracker"

`FBAllocationTracker` is built out from non-debug builds, so when you want to test it, use 

    carthage update --configuration Debug

### CocoaPods

To your podspec add:

    pod 'FBAllocationTracker'

You'll be able to use `FBAllocationTracker` fully only in `Debug` builds. This is controlled by [compilation flag](https://github.com/facebook/FBAllocationTracker/blob/master/FBAllocationTracker/FBAllocationTrackerImpl.h#L17) that can be provided to the build to make it work in other configurations.

## Usage

`FBAllocationTracker` can run in two modes: tracking objects, and just counting allocs/deallocs. The first one is more interesting and we will jump right to it. The second one can be considered useful for some statistics when you don't want to impact performance.

First of all, we want to enable `FBAllocationTracker` in our run. We can do it at any time. For example in `main.m`! 
```objc
#import <FBAllocationTracker/FBAllocationTrackerManager.h>

int main(int argc, char * argv[]) {
  [[FBAllocationTrackerManager sharedManager] startTrackingAllocations];
  [[FBAllocationTrackerManager sharedManager] enableGenerations];
  @autoreleasepool {
      return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
```

In the code above `startTrackingAllocations` will take care of swizzling `NSObject`'s `+alloc` and `-dealloc` methods, while `enableGenerations` will start tracking actual *instances* of objects.

We can grab summaries of all classes allocations:
```objc
NSArray<FBAllocationTrackerSummary *> *summaries = [[FBAllocationTrackerManager sharedManager] currentAllocationSummary];
```

[FBAllocationTrackerSummary](https://github.com/facebook/FBAllocationTracker/blob/master/FBAllocationTracker/FBAllocationTrackerSummary.h) will tell you, for given class, how many instances of this class are still alive.

With generations enabled (explained in details below) you can also get all instances of given class

```objc
NSArray *instances =[[FBAllocationTrackerManager sharedManager] instancesOfClasses:@[[ViewController class]]];
```

Check out [FBAllocationTrackerManager API](https://github.com/facebook/FBAllocationTracker/blob/master/FBAllocationTracker/FBAllocationTrackerManager.h) to see what else you can do.

## Generations

Generations is an idea inspired by Allocations tool in Instruments. With generations enabled we can call `[[FBAllocationTrackerManager sharedManager] markGeneration]` to mark generation. All objects that are allocated after given `markGeneration` call will be kept in new generation. We can see it in a very simple example:

```objc
- (void)someFunction {
  // Enable generations (if not already enabled in main.m)
  [[FBAllocationTrackerManager sharedManager] enableGenerations];
 
  // Object a will be kept in generation with index 0
  NSObject *a = [NSObject new];
  
  // We are marking new generation
  [[FBAllocationTrackerManager sharedManager] markGeneration];
  
  // Objects b and c will be kept in second generation at index 1
  NSObject *b = [NSObject new];
  NSObject *c = [NSObject new];
  
  [[FBAllocationTrackerManager sharedManager] markGeneration];
  
  // Object d will be kept in third generation at index 2
  NSObject *d = [NSObject new];
}
```

`FBAllocationTrackerManager` has API to get all instances of given class in given generation.

```objc
NSArray *instances =[[FBAllocationTrackerManager sharedManager] instancesForClass:[NSObject class]
                                                                     inGeneration:1];
```

This can be used to analyze allocations, for example by performing common tasks a user might do. Between each task we can mark a new generation, and then verify which objects are kept in given generations.

## Other use cases

`FBAllocationTracker` is heavily used in [FBMemoryProfiler](https://github.com/facebook/FBMemoryProfiler). It provides data for `FBMemoryProfiler`. It also is a great source of candidates for [FBRetainCycleDetector](https://github.com/facebook/FBRetainCycleDetector).

## Contributing
See the [CONTRIBUTING](CONTRIBUTING) file for how to help out.

## License
[`FBAllocationTracker` is BSD-licensed](LICENSE). We also provide an additional [patent grant](PATENTS).
