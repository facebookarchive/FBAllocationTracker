/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBAllocationTrackerGeneration.h"

namespace FB { namespace AllocationTracker {
  void Generation::add(__unsafe_unretained id object) {
    Class aCls = [object class];
    objects[aCls].insert(object);
  }

  void Generation::remove(__unsafe_unretained id object) {
    Class aCls = [object class];
    objects[aCls].erase(object);
  }

  GenerationSummary Generation::getSummary() const {
    GenerationSummary summary;

    for (const auto &kv: objects) {
      Class aCls = kv.first;
      const GenerationList &list = kv.second;

      NSInteger count = list.size();

      summary[aCls] = count;
    }

    return summary;
  }

  std::vector<id> Generation::instancesForClass(__unsafe_unretained Class aCls) const {
    std::vector<id> returnValue;

    const GenerationMap::const_iterator obj = objects.find(aCls);
    if (obj != objects.end()) {
      const GenerationList &list = obj->second;
      for (const auto &object: list) {
        /**
         Retain object and add it to returnValue.
         This operation can be unsafe since we are retaining object that could
         be deallocated on other thread.
         */
        returnValue.push_back(object);
      }
    }

    return returnValue;
  }
} }
