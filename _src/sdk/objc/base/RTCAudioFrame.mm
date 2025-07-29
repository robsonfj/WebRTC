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

@implementation RTC_OBJC_TYPE (RTCAudioFrame)

@synthesize sampleRate = _sampleRate;
@synthesize channels = _channels;
@synthesize samplesPerChannel = _samplesPerChannel;
@synthesize timeStampNs = _timeStampNs;
@synthesize audioData = _audioData;

- (instancetype)initWithAudioData:(NSData *)audioData
                       sampleRate:(int)sampleRate
                         channels:(int)channels
                samplesPerChannel:(int)samplesPerChannel
                      timeStampNs:(int64_t)timeStampNs {
  if (self = [super init]) {
    NSParameterAssert(audioData);
    NSParameterAssert(sampleRate > 0);
    NSParameterAssert(channels > 0);
    NSParameterAssert(samplesPerChannel > 0);
    
    _audioData = [audioData copy];
    _sampleRate = sampleRate;
    _channels = channels;
    _samplesPerChannel = samplesPerChannel;
    _timeStampNs = timeStampNs;
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"RTCAudioFrame: %dHz %dch %d samples, timestamp: %lldns",
                                    _sampleRate, _channels, _samplesPerChannel, _timeStampNs];
}

@end
