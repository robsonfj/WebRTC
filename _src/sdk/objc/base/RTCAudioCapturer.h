/*
 *  Copyright 2023 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "RTCAudioFrame.h"

#import "sdk/objc/base/RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class RTC_OBJC_TYPE(RTCAudioCapturer);

RTC_OBJC_EXPORT
@protocol RTC_OBJC_TYPE
(RTCAudioCapturerDelegate)<NSObject>

/** Called when the audio capturer has captured a new audio frame. */
- (void)capturer:(RTC_OBJC_TYPE(RTCAudioCapturer) *)capturer 
    didCaptureAudioFrame:(RTC_OBJC_TYPE(RTCAudioFrame) *)frame;

@end

RTC_OBJC_EXPORT
@interface RTC_OBJC_TYPE (RTCAudioCapturer) : NSObject

@property(nonatomic, weak) id<RTC_OBJC_TYPE(RTCAudioCapturerDelegate)> delegate;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

/** Manually capture an audio frame and send it to the delegate. */
- (void)captureAudioFrame:(RTC_OBJC_TYPE(RTCAudioFrame) *)frame;

@end

NS_ASSUME_NONNULL_END
