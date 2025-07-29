/*
 *  Copyright 2023 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>

#import "sdk/objc/base/RTCMacros.h"

NS_ASSUME_NONNULL_BEGIN

// RTCAudioFrame represents audio data for one audio frame.
RTC_OBJC_EXPORT
@interface RTC_OBJC_TYPE (RTCAudioFrame) : NSObject

/** Sample rate in Hz. */
@property(nonatomic, readonly) int sampleRate;

/** Number of audio channels. */
@property(nonatomic, readonly) int channels;

/** Number of samples per channel. */
@property(nonatomic, readonly) int samplesPerChannel;

/** Timestamp in nanoseconds. */
@property(nonatomic, readonly) int64_t timeStampNs;

/** Audio data as 16-bit signed integer samples. */
@property(nonatomic, readonly) NSData *audioData;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

/** Initialize an RTCAudioFrame with audio data and parameters.
 *  @param audioData      Raw audio data as 16-bit signed integer samples.
 *  @param sampleRate     Sample rate in Hz (e.g., 44100, 48000).
 *  @param channels       Number of audio channels (1 for mono, 2 for stereo).
 *  @param samplesPerChannel Number of samples per channel.
 *  @param timeStampNs    Timestamp in nanoseconds.
 */
- (instancetype)initWithAudioData:(NSData *)audioData
                       sampleRate:(int)sampleRate
                         channels:(int)channels
                samplesPerChannel:(int)samplesPerChannel
                      timeStampNs:(int64_t)timeStampNs NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
