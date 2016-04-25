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
#import <vector>

#import <Foundation/Foundation.h>

#import "FBAllocationTrackerGeneration.h"

/**
 GenerationManager is a class responsible for managing generations. It especially can point in O(1)
 from which generation the pointer comes from thus reducing the complexity.
 */

namespace FB { namespace AllocationTracker {
  // Types
  typedef std::vector<GenerationSummary> FullGenerationSummary;

  class GenerationManager {
  public:

    /**
     Creates new generations. Every new object that will be added to manager will
     be attributed to newest generation created.
     */
    void markGeneration();

    /**
     Adds object to most recent generation.
     */
    void addObject(__unsafe_unretained id object);

    /**
     Removes object from generation. It will grab reference from generationMapping
     (it holds mapping object -> generation for performance) and then ask this generation
     to remove the reference.
     */
    void removeObject(__unsafe_unretained id object);

    /**
     Grab all instances of class aCls in generation at generationIndex.

     @param aCls Class to query
     @param generationIndex index of generation from which the instances should be obtained
     @return vector of instances of class aCls
     */
    std::vector<__weak id> instancesOfClassInGeneration(__unsafe_unretained Class aCls,
                                                 size_t generationIndex);

    /**
     Grab all instances of class aCls in last generation.
     @param aCls Class to query
     @return vector of instances of class aCls
     */
    std::vector<__weak id> instancesOfClassInLastGeneration(__unsafe_unretained Class aCls);

    /**
     Summarize all generations. For every generation it will summarize how many instances of each
     class this generation holds.
     */
    FullGenerationSummary summary() const;

  private:
    std::vector<__weak id> unsafeInstancesOfClassInGeneration(__unsafe_unretained Class aCls,
                                                              size_t generationIndex);
    std::unordered_map<__unsafe_unretained id, NSInteger, ObjectHashFunctor, ObjectEqualFunctor> generationMapping;
    std::vector<Generation> generations;
  };
} }
