/*
 *  Copyright 2023 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#ifndef SDK_OBJC_CLASSES_AUDIO_OBJC_AUDIO_TRACK_SOURCE_H_
#define SDK_OBJC_CLASSES_AUDIO_OBJC_AUDIO_TRACK_SOURCE_H_

#import "base/RTCAudioCapturer.h"

#include "api/media_stream_interface.h"
#include "rtc_base/synchronization/mutex.h"
#include "sdk/objc/base/RTCMacros.h"

RTC_FWD_DECL_OBJC_CLASS(RTC_OBJC_TYPE(RTCAudioFrame));

@interface RTCObjCAudioSourceAdapter
    : NSObject <RTC_OBJC_TYPE (RTCAudioCapturerDelegate)>
@end

namespace webrtc {

class ObjCAudioTrackSource : public webrtc::AudioSourceInterface {
 public:
  ObjCAudioTrackSource();
  explicit ObjCAudioTrackSource(RTCObjCAudioSourceAdapter* adapter);
  ObjCAudioTrackSource(RTCObjCAudioSourceAdapter* adapter,
                       webrtc::Thread* signaling_thread,
                       webrtc::Thread* worker_thread);

  // AudioSourceInterface implementation
  SourceState state() const override;
  bool remote() const override;
  void SetVolume(double volume) override;
  void RegisterObserver(ObserverInterface* observer) override;
  void UnregisterObserver(ObserverInterface* observer) override;

  // Called when audio frame is captured
  void OnCapturedFrame(RTC_OBJC_TYPE(RTCAudioFrame) * frame);

  // Add sink for audio data (similar to video tracks)
  void AddSink(AudioTrackSinkInterface* sink) override;
  void RemoveSink(AudioTrackSinkInterface* sink) override;

 private:
  void DeliverPCMToSinks(const void* audio_data,
                        int sample_rate,
                        int channels,
                        int samples_per_channel);

  mutable webrtc::Mutex mutex_;
  SourceState state_ RTC_GUARDED_BY(&mutex_);
  double volume_ RTC_GUARDED_BY(&mutex_);
  RTCObjCAudioSourceAdapter* adapter_ RTC_GUARDED_BY(&mutex_);
  std::vector<ObserverInterface*> observers_ RTC_GUARDED_BY(&mutex_);
  std::vector<AudioTrackSinkInterface*> sinks_ RTC_GUARDED_BY(&mutex_);
  
  // Threads for future use (consistency with video API)
  webrtc::Thread* signaling_thread_;  // For state management
  webrtc::Thread* worker_thread_;     // For audio processing
};

} // namespace webrtc

#endif  // SDK_OBJC_CLASSES_AUDIO_OBJC_AUDIO_TRACK_SOURCE_H_
