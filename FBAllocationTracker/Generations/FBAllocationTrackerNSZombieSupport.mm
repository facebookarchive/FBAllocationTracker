/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#if __has_feature(objc_arc)
#error This file must be compiled with MRR. Use -fno-objc-arc flag.
#endif

#include "FBAllocationTrackerNSZombieSupport.h"

bool fb_isZombieObject(_Nullable id object) {
  if (object == nil) { return true; }
  if (!fb_isNSZombieEnabled()) { return false; }

  const char *className = object_getClassName(object);
  static const char zombiePrefix[] = "_NSZombie";
  return strncmp(className, zombiePrefix, sizeof(zombiePrefix) - 1) == 0;
}

bool fb_isNSZombieEnabled(void) {
  static bool zombieEnabled = false;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    char *NSZombieEnabledEnv = getenv("NSZombieEnabled");

    if (NSZombieEnabledEnv != NULL) {
      zombieEnabled = strcmp(NSZombieEnabledEnv, "YES") == 0;
    }
    else {
      zombieEnabled = false;
    }
  });

  return zombieEnabled;
}
