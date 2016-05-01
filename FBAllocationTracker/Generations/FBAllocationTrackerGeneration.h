/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <mutex>
#import <unordered_map>
#import <unordered_set>
#import <vector>

#import <Foundation/Foundation.h>

#import "FBAllocationTrackerFunctors.h"

/**
 Not thread-safe class, needs to be synchronized

 Generation is supposed to simulate Instruments Generation tool for allocations that let's
 you mark objects that were allocated in a given time span. Generation is simply a map keyed by
 Classes that point to vector of object pointers. In any given time you can look into generation to
 check what objects are still allocated that were created in that time span.
 */

namespace FB { namespace AllocationTracker {
  // Types
  typedef std::unordered_set<__unsafe_unretained id, ObjectHashFunctor, ObjectEqualFunctor> GenerationList;

  typedef std::unordered_map<Class, GenerationList, ClassHashFunctor, ClassEqualFunctor> GenerationMap;

  typedef std::unordered_map<Class, NSInteger, ClassHashFunctor, ClassEqualFunctor> GenerationSummary;

  class Generation {
  public:
    /**
     Attributes object to given generation.
     */
    void add(__unsafe_unretained id object);

    /**
     Removes object on dealloc. The pointers are not self-zeroing so we have to remove them
     by ourselves.
     */
    void remove(__unsafe_unretained id object);

    /**
     Provides summary for given generation, where summary is a map Class -> Count
     */
    GenerationSummary getSummary() const;

    /**
     Returns objects of given class that live in this generation.

     @param aCls - class that caller is interested in
     @return vector of instances of class aCls
     */
    std::vector<__weak id> instancesForClass(__unsafe_unretained Class aCls) const;

    /**
     We do not want Generation to copy, blocking.
     */
    Generation() = default;
    Generation(Generation&&) = default;
    Generation &operator=(Generation&&) = default;

    Generation(const Generation&) = delete;
    Generation &operator=(const Generation&) = delete;

  private:
    GenerationMap objects;
  };
} }
