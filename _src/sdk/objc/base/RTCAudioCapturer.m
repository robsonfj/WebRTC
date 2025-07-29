/*
 *  Copyright 2023 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "RTCAudioCapturer.h"

@implementation RTC_OBJC_TYPE (RTCAudioCapturer)

@synthesize delegate = _delegate;

- (instancetype)init {
  return [super init];
}

- (void)captureAudioFrame:(RTC_OBJC_TYPE(RTCAudioFrame) *)frame {
  if (_delegate) {
    [_delegate capturer:self didCaptureAudioFrame:frame];
  }
}

@end
