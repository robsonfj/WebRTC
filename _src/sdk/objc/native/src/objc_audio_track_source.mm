/*
 *  Copyright 2023 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#include "sdk/objc/native/src/objc_audio_track_source.h"

#import "base/RTCAudioFrame.h"

#include <algorithm>
#include <vector>
#include "rtc_base/logging.h"

@interface RTCObjCAudioSourceAdapter ()
@property(nonatomic) webrtc::ObjCAudioTrackSource *objCAudioTrackSource;
@end

@implementation RTCObjCAudioSourceAdapter

@synthesize objCAudioTrackSource = _objCAudioTrackSource;

- (void)capturer:(RTC_OBJC_TYPE(RTCAudioCapturer) *)capturer
    didCaptureAudioFrame:(RTC_OBJC_TYPE(RTCAudioFrame) *)frame {
  if (_objCAudioTrackSource) {
    _objCAudioTrackSource->OnCapturedFrame(frame);
  }
}

@end

namespace webrtc {

ObjCAudioTrackSource::ObjCAudioTrackSource()
    : ObjCAudioTrackSource(nullptr) {}

ObjCAudioTrackSource::ObjCAudioTrackSource(RTCObjCAudioSourceAdapter* adapter)
    : ObjCAudioTrackSource(adapter, nullptr, nullptr) {}

ObjCAudioTrackSource::ObjCAudioTrackSource(RTCObjCAudioSourceAdapter* adapter,
                                           webrtc::Thread* signaling_thread,
                                           webrtc::Thread* worker_thread)
    : state_(kLive), 
      volume_(1.0), 
      adapter_(adapter),
      signaling_thread_(signaling_thread),
      worker_thread_(worker_thread) {
  if (adapter_) {
    webrtc::MutexLock lock(&mutex_);
    adapter_.objCAudioTrackSource = this;
  }
  
  // Log thread information for debugging
  RTC_LOG(LS_INFO) << "ObjCAudioTrackSource created with threads: "
                   << "signaling=" << (signaling_thread_ ? "yes" : "no")
                   << ", worker=" << (worker_thread_ ? "yes" : "no");
}

AudioSourceInterface::SourceState ObjCAudioTrackSource::state() const {
  webrtc::MutexLock lock(&mutex_);
  return state_;
}

bool ObjCAudioTrackSource::remote() const {
  return false;
}

void ObjCAudioTrackSource::SetVolume(double volume) {
  webrtc::MutexLock lock(&mutex_);
  volume_ = volume;
}

void ObjCAudioTrackSource::RegisterObserver(ObserverInterface* observer) {
  webrtc::MutexLock lock(&mutex_);
  if (observer) {
    observers_.push_back(observer);
  }
}

void ObjCAudioTrackSource::UnregisterObserver(ObserverInterface* observer) {
  webrtc::MutexLock lock(&mutex_);
  auto it = std::find(observers_.begin(), observers_.end(), observer);
  if (it != observers_.end()) {
    observers_.erase(it);
  }
}

void ObjCAudioTrackSource::AddSink(AudioTrackSinkInterface* sink) {
  webrtc::MutexLock lock(&mutex_);
  if (sink && std::find(sinks_.begin(), sinks_.end(), sink) == sinks_.end()) {
    sinks_.push_back(sink);
  }
}

void ObjCAudioTrackSource::RemoveSink(AudioTrackSinkInterface* sink) {
  webrtc::MutexLock lock(&mutex_);
  auto it = std::find(sinks_.begin(), sinks_.end(), sink);
  if (it != sinks_.end()) {
    sinks_.erase(it);
  }
}

void ObjCAudioTrackSource::OnCapturedFrame(RTC_OBJC_TYPE(RTCAudioFrame) * frame) {
  // Convert Objective-C audio frame to WebRTC native format and process
  
  // Extract audio data from RTCAudioFrame
  NSData *audioData = frame.audioData;
  const int16_t *samples = static_cast<const int16_t*>(audioData.bytes);
  size_t num_samples = audioData.length / sizeof(int16_t);
  
  // Get audio parameters
  int sample_rate = frame.sampleRate;
  int channels = frame.channels;
  int samples_per_channel = frame.samplesPerChannel;
  
  // Validate the audio data consistency
  if (num_samples != static_cast<size_t>(channels * samples_per_channel)) {
    RTC_LOG(LS_ERROR) << "Audio data size mismatch: expected " 
                      << (channels * samples_per_channel) 
                      << " samples, got " << num_samples;
    return;
  }
  
  // Validate audio parameters
  if (sample_rate <= 0 || channels <= 0 || samples_per_channel <= 0) {
    RTC_LOG(LS_ERROR) << "Invalid audio parameters: rate=" << sample_rate
                      << ", channels=" << channels 
                      << ", samples_per_channel=" << samples_per_channel;
    return;
  }
  
  // Apply volume scaling if needed
  std::vector<int16_t> processed_samples;
  double current_volume;
  {
    webrtc::MutexLock lock(&mutex_);
    current_volume = volume_;
  }
  
  if (current_volume != 1.0) {
    processed_samples.resize(num_samples);
    for (size_t i = 0; i < num_samples; ++i) {
      // Apply volume and clamp to int16_t range
      double scaled = samples[i] * current_volume;
      processed_samples[i] = static_cast<int16_t>(
          std::max(-32768.0, std::min(32767.0, scaled)));
    }
    samples = processed_samples.data();
  }
  
  // Deliver audio data to all registered sinks
  DeliverPCMToSinks(samples, sample_rate, channels, samples_per_channel);
  
  // Notify observers that new audio data is available
  {
    webrtc::MutexLock lock(&mutex_);
    for (auto* observer : observers_) {
      observer->OnChanged();
    }
  }
}

void ObjCAudioTrackSource::DeliverPCMToSinks(const void* audio_data,
                                           int sample_rate,
                                           int channels,
                                           int samples_per_channel) {
  webrtc::MutexLock lock(&mutex_);
  
  // Deliver to all registered sinks
  for (auto* sink : sinks_) {
    if (sink) {
      // Convert to the format expected by AudioTrackSinkInterface
      // This typically expects interleaved 16-bit PCM data
      sink->OnData(audio_data, 
                   sizeof(int16_t) * 8,  // bits_per_sample
                   sample_rate,
                   channels,
                   samples_per_channel);
    }
  }
}

} // namespace webrtc
