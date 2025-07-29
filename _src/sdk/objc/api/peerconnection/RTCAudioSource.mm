/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "RTCAudioSource+Private.h"

#import "base/RTCAudioFrame.h"
#import "base/RTCAudioCapturer.h"

#include "rtc_base/checks.h"
#include "rtc_base/ref_counted_object.h"
#include "sdk/objc/native/src/objc_audio_track_source.h"

static webrtc::ObjCAudioTrackSource *getObjCAudioSource(
    const webrtc::scoped_refptr<webrtc::AudioSourceInterface> nativeSource) {
  // Cast the AudioSourceInterface to ObjCAudioTrackSource
  return static_cast<webrtc::ObjCAudioTrackSource *>(nativeSource.get());
}

// Forward declaration of the adapter class
@class RTCObjCAudioSourceAdapter;

@implementation RTC_OBJC_TYPE (RTCAudioSource) {
}

@synthesize volume = _volume;
@synthesize nativeAudioSource = _nativeAudioSource;

- (instancetype)
      initWithFactory:(RTC_OBJC_TYPE(RTCPeerConnectionFactory) *)factory
    nativeAudioSource:
        (webrtc::scoped_refptr<webrtc::AudioSourceInterface>)nativeAudioSource {
  RTC_DCHECK(factory);
  RTC_DCHECK(nativeAudioSource);

  self = [super initWithFactory:factory
              nativeMediaSource:nativeAudioSource
                           type:RTCMediaSourceTypeAudio];
  if (self) {
    _nativeAudioSource = nativeAudioSource;
  }
  return self;
}

- (instancetype)
      initWithFactory:(RTC_OBJC_TYPE(RTCPeerConnectionFactory) *)factory
    nativeMediaSource:
        (webrtc::scoped_refptr<webrtc::MediaSourceInterface>)nativeMediaSource
                 type:(RTCMediaSourceType)type {
  RTC_DCHECK_NOTREACHED();
  return nil;
}

- (instancetype)initWithFactory:(RTC_OBJC_TYPE(RTCPeerConnectionFactory) *)factory
                signalingThread:(webrtc::Thread *)signalingThread
                   workerThread:(webrtc::Thread *)workerThread {
  // Create adapter for bridging Objective-C to C++
  RTCObjCAudioSourceAdapter *adapter = [[RTCObjCAudioSourceAdapter alloc] init];
  
  // Create our custom audio track source with thread references
  // The threads are used for:
  // - signalingThread: State management, observer notifications
  // - workerThread: Audio processing, sink delivery
  webrtc::scoped_refptr<webrtc::ObjCAudioTrackSource> objCAudioTrackSource =
      webrtc::make_ref_counted<webrtc::ObjCAudioTrackSource>(adapter, 
                                                             signalingThread,
                                                             workerThread);

  return [self initWithFactory:factory
               nativeAudioSource:objCAudioTrackSource];
}

- (NSString *)description {
  NSString *stateString = [[self class] stringForState:self.state];
  return [NSString stringWithFormat:@"RTC_OBJC_TYPE(RTCAudioSource)( %p ): %@",
                                    self,
                                    stateString];
}

- (void)setVolume:(double)volume {
  _volume = volume;
  _nativeAudioSource->SetVolume(volume);
}

- (void)capturer:(RTC_OBJC_TYPE(RTCAudioCapturer) *)capturer 
    didCaptureAudioFrame:(RTC_OBJC_TYPE(RTCAudioFrame) *)frame {
  webrtc::ObjCAudioTrackSource *objcAudioSource = getObjCAudioSource(_nativeAudioSource);
  if (objcAudioSource) {
    objcAudioSource->OnCapturedFrame(frame);
  }
}

@end
