/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

/**
 Returns whether `object` is the zombie object.
 
 @return `true` if `object` is nil.
 @return `false` if `object` is not nil and NSZombieEnabled = NO.
 */
bool fb_isZombieObject(_Nullable id object);

/**
 Returns whether runtime has NSZombie detection enabled.
 */
bool fb_isNSZombieEnabled(void);