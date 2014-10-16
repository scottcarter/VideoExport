//
//  README.h
//  VideoExport
//
//  Created by Scott Carter on 9/19/14.
//  Copyright (c) 2014 Scott Carter. All rights reserved.
//

#ifndef VideoExport_README_h
#define VideoExport_README_h



 /*

  Project created and tested with Xcode Version 6.0.1 (6A317)
  
  
  Table of Contents
  +++++++++++++++++
  
  Overview
  
  Criteria Discussion
    Support for MPMoviePlayerController
    Support for Dropbox
    Android Support
    Bitrate considerations
    Container
  
  Meeting project criteria
    AVAssetExportSession
    AVAssetReader/AVAssetWriter
    SDAVAssetExportSession
  
  Misc. Project Notes
  
  Portrait Example
  
  Preferred transform
  
  Contrasting preferred transform with video composition transform
    Method 1
    Method 2
    Comparison of methods
  
  Additional References
    General
    Temp directory
    Adding & Retrieving Metadata
    MPMoviePlayerController
    UIRequiredDeviceCapabilities
    Reducing file size
    Video settings
  
  
 
  Overview
  ++++++++++++
  This project is intended to show how various video formats and orientations can be
  read and exported for maximum compatibility across clients and reduced size
  according to the following criteria:
 
  1. Dimensions reduced to no greater than 512 x 288 (16:9) or 480 x 360 (4:3)
  2. Rotation (preferred transform) of container set to 0 degrees (CGAffineTransformIdentity).
  3. Video profile level set to AVVideoProfileLevelH264Baseline30 (Baseline@L3.0)
  4. Video bitrate reduced to average of 725,000 bps
  5. MP4 container
  
 
 
  Criteria Discussion
  +++++++++++++++++++++++

  The following is some information that was used in establishing the criteria for video export
  mentioned in the Overview.
  
  The dimensions were chosen not to exceed 640 x 480 (support MPMoviePlayerController, Dropbox). I chose
  something a little smaller to reduce the file size.
  
  The video profile level was chosen to be Baseline@L3.0 (support Android, MPMoviePlayerController, Dropbox).
  
  The video bitrate of 725,000 bps was chosen to be in the range of the recommendations listed 
  in the Bitrate considerations section below.
  
  MP4 was chosen as the container for the widest possible client support.
  
  
  Support for MPMoviePlayerController
  ===================================
  According to docs the MPMoviePlayerController supports:
  - H.264 Baseline Profile Level 3.0 video, up to 640 x 480 at 30 fps. (The Baseline profile does not support B frames.)
  - MPEG-4 Part 2 video (Simple Profile)
  
  
  Support for Dropbox
  ===================
  How can I get my movie to play on my phone or tablet?
  https://www.dropbox.com/help/83/en
  
  H.264 video, up to 2.5 Mbps, 640 by 480 pixels, 30 frames per second, Baseline Profile up to Level 3.0 with AAC-LC stereo audio up to 160 Kbps, 48kHz, in .mov, .mp4 and .m4v file formats
  
  
  Android Support
  ===============
  Mobile Encoding Guidelines for Android Powered Devices
  http://download.macromedia.com/flashmediaserver/mobile-encoding-android-v2_7.pdf
  
  Lots of great information.  
  A 16:9 ratio, 16x16 macroblock division is best (ex: 512 x 288)
  A 4:3 ratio, 8x8 macroblock division is good (ex: 480 x 360)
  
  
  Supported Media Formats
  http://developer.android.com/guide/appendix/media-formats.html
  (Need to use Baseline Profile)
  
  
  Compatibility Program Overview
  http://source.android.com/compatibility/overview.html
  
  Links to Compatibility Definition Document:
  http://static.googleusercontent.com/media/source.android.com/en/us/compatibility/android-cdd.pdf
  Android device implementations that include a rear-facing camera and declare android.hardware.camera
  SHOULD support the following H.264 video encoding profiles:
  SD (High quality)
  500 Kbps or higher   Note the "or higher" which is not present in the Supported Media Formats link above.
  
  
  Must Use H.264 in Baseline Profile
  http://stackoverflow.com/questions/13451180/android-videoview-cannot-play-video-mp4?rq=1
  

  
  Bitrate considerations
  =======================
  Note: Overall bitrate is sum of video & audio.
  
  AVAssetExportSession, presetName=AVAssetExportPresetMediumQuality
  Video: 713kbps, 30fps.
  Audio: Bit rate=64.0kbps, Sampling rate=44.1khz, 1 channel
  Overall bitrate = 780kbps.
  
  http://www.ezs3.com/public/What_bitrate_should_I_use_when_encoding_my_video_How_do_I_optimize_my_video_for_the_web.cfm
  Video: 480 x 360 x 30fps x 2(average motion) x .07 = 725kps (video bitrate)
  Audio: Mono, 16 - 24 kbps rate, 22.05 kHz acceptable for speech.
  Overall bitrate = ~749kbps.
  
  http://www.adobe.com/devnet/flash/apps/flv_bitrate_calculator.html
  For 480 x 360:
  Video: 753kbps,
  Audio: Mono, Medium quality = 48.0kbps, 44.1khz
  Overall bitrate=801kbps
  

  Container
  =========
  Difference Between MOV and MP4
  http://www.differencebetween.net/technology/difference-between-mov-and-mp4/
 
  MP4 is more widely supported.
  

 
 
  
  Meeting project criteria
  ++++++++++++++++++++++++++
  I evaluated 3 approaches to meeting the criteria set forth in the Overview section, eventually
  settling on using SDAVAssetExportSession.
 
 
  AVAssetExportSession
  =====================
 
  Using AVAssetExportSession I can:
 
  - Use a videoComposition
   a.  Set the rotation to 0
   b.  Scale width/height as needed.
 
  - Set a preset which allows me some control over the resolution, profile level and bit rate.
      AVAssetExportPresetHighestQuality (26.087 fps, 2,753 Kbps video data rate, 360 x 480, Profile=Baseline@L2.1)
      AVAssetExportPresetMediumQuality  (26.087 fps, 706 Kbps video data rate,   360 x 480, Profile=Main@L2.1)
      AVAssetExportPresetLowQuality     (15.000 fps, 135 Kbps video data rate,   144 x 192, Profile=Baseline@L1.1)

  - Specify MPEG4 output format.
 
  - Add metadata.


  What I can't do is:

  - Specify the exact frame rate I want (30 fps).  The preset apparently overrides the videoComposition.frameDuration
  - Specify the video bitrate I want (AVAssetExportPresetMediumQuality comes closest)
  - Specify an Android compatible profile level with medium quality preset (the preset which comes closest to requirements).


  AVAssetReader/AVAssetWriter
  ===========================
 
  Using a combination of AVAssetReader/AVAssetWriter with AVAssetReaderTrackOutput instead 
  of AVAssetReaderVideoCompositionOutput  I can:
 
  - Set the video average bit rate.
  - Set my profile level which allows me to be compatible with Android.
  - Specify the width and height for output.
  - Specify MPEG4 output format.
  - Add metadata.


  What I can't do is:

  - Select the frame rate and make it constant.  I found it to be variable from 25 - 30 fps.
  - Force the rotation to be 0 and swap width/height.


  SDAVAssetExportSession
  ======================
 
  https://github.com/rs/SDAVAssetExportSession
 
  SDAVAssetExportSession is a replacement for AVAssetExportSession which provides all the
  flexibility of that class (notably the ability to specify a videoComposition) along with
  the use of AVAssetReader/AVAssetWriter under the hood.
  
  It uses AVAssetReaderVideoCompositionOutput instead of AVAssetReaderTrackOutput.
 
  SDAVAssetExportSession allows me to meet all the criteria I established for VideoExport project.

  Most of the interesting properties are exposed in public interface for SDAVAssetExportSession.
  One property that is not exposed is the transform property of AVAssetWriterInput which could be useful
  in some video applications.  This is discussed below in the section "Preferred transform".
 
 
  Misc. Project Notes
  ++++++++++++++++++++
 
  Some variables that would normally be declared as constants with "let" use
  "var" for debugging purposes.   Current Xcode version does not
  make "let" constants visible to debugger.
  
  Variables ("var") are currently not visible in the debugger when running on the
  real device.  This appears to be a limitation of current version of Xcode.
 
  When using the simulator, the breakpoint on "All Exceptions" must be disabled.
  Otherwise an exception is consistently triggered when a video is loaded.  This
  is a bug in the simulator which does not occur on the real device.
 
  Some movies do not load in the simulator, but will work fine on the real device.
  I noted this happening with .AVI files as well as front facing (640 x 480) Portrait
  movies taken on the iPhone.   This has been traced to an issue with the copyNextSampleBuffer method
  of AVAssetReaderOutput hanging when a video composition is used.  A bug will be filed with Apple.
  

  Movies in simulator are located in a directory such as:
  /Users/<username>/Library/Developer/CoreSimulator/Devices/<device id>/data/Media/DCIM/100APPLE
 
  Temp directory for simulator:
  /Users/<username>/Library/Developer/CoreSimulator/Devices/<device id>/data/Containers/Data/Application/<application id>/tmp
 
 
  Portrait Example
  ++++++++++++++++++
  Input:  MPEG-4 QuickTime .mov
  Size = 44.5MB
 
  Video
  1920 width x 1080 height (16:9)
  Rotation = 90
  Baseline@L4.1
  Bit rate = 21.3 Mbps
  Frame rate mode = Variable
  Frame rate = 29.970 fps
 
  Audio
  Bit rate = 64.0 Kbps
  Sampling rate = 44.1 KHz
 
 
  Output: MPEG-4 Base Media / Version 2 .mp4
  Size = 1.76MB
  Video
  288 width x 512 height (9:16)
  Rotation = 0
  Baseline@L3.0
  Bit rate = 778 Kbps
  Frame rate mode = Constant
  Frame rate = 30.000 fps
 
  Audio
  Bit rate = 64.0 Kbps
  Sampling rate = 44.1 KHz
 

 
  Preferred transform
  ++++++++++++++++++++++++
  The movie container has a preferred transform property.

  When we write out a movie for export the preferred transform is set to CGAffineTransformIdentity (no rotation).
  The orientation of Portrait or Landscape is then set by the ratio of width to height.
 
  Consider a movie originally captured on the iPhone in Portrait.  The width will be greater than the height, but
  the preferred transform will be set to rotate the movie 90 degrees.   The exported movie will change the
  preferred transform to 0 degrees and swap width and height, so that the movie still appears as Portrait.
 
  The advantage of using a rotation of 0 degrees is that the exported movie will appear correctly on all platforms
  (some Windows clients do not present a movie in Portrait correctly when using a 90 degree rotation).
 
  What if you wanted to adjust the preferred transform of the exported movie for some reason?
  You could consider enhancing the code in SDAVAssetExportSession.m in the method exportAsynchronouslyWithCompletionHandler:
  Provide a public transform property that you would then assign to self.videoInput.transform in that method. Your Swift code
  would could then alter the preferred transform.  In exportAsset() you might include:
 
  var angle45: CGFloat = CGFloat(45.0 * M_PI / 180.0) // Rotate 45 degrees
  var preferredTransform: CGAffineTransform = CGAffineTransformMakeRotation(angle45)
  encoder.transform = preferredTransform
 
  Reference:
  https://developer.apple.com/library/ios/qa/qa1744/_index.html#//apple_ref/doc/uid/DTS40011134
 
  "If you are using an AVAssetWriter object to write a movie file, you can use the transform property of the
  associated AVAssetWriterInput to specify the output file orientation. This will write a display transform
  property into the output file as the preferred transformation of the visual media data for display purposes."
 
 
  Contrasting preferred transform with video composition transform
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
  We can achieve similar effects by manipulation the preferred transform vs. the video composition transform,
  along with width/height.
 
  Suppose we want to take a Portrait video source and make it into a Landscape view,
  putting everyone in the source video on their backs.  We will also reduce the size, bit rate, etc. as we normally
  do in this project.  The original video is  1920 x 1080 with a 90 degree rotation.
 
  After selection by our UIImagePickerController, given our constraint on videoQuality, we get a video asset with a
  natural size of 640 (width) x 360 (height) and a preferred transform of 90 degree rotation.
 
  (Note: For purposes of reading the video by our encoder, SDAVAssetExportSession, this video is treated as if it
  were 360 x 640 with 0 degree rotation).
 
 
 
 
  Method 1
  =========
  One way to achieve the effect we are seeking would be to:
 
  1. Allow the normal swap of width/height.  Our scaled dimensions of 512 x 288 (from 640 x 360) would be swapped
     to give a video composition renderSize of 288 (width) x 512 (height).
  2. Set the preferred transform to 90 degrees for container.
 
  After exporting, we would end up with a movie with dimensions 288 x 512 and a 90 degree (preferred transform) rotation.
 
 
  Method 2
  =========
  An alternate method would be to:
 
  1. Don't swap width/height. Our scaled dimensions of 512 (width) x 288 (height) (from 640 x 360) would not be altered.
  2. Do not set a preferred transform (default to CGAffineTransformIdentity) for container.
  3. Add an additional rotate transform in our getVideoComposition method.
 
  After exporting, we would end up with a movie with dimensions 512 x 288 and a 0 degree (preferred transform) rotation.
 
 
  The code for the rotate transform might look like the following.  Note how we need to make sure
  that we shift the video content back into view afer rotating:
 
  var angle: CGFloat  = CGFloat(90.0 * M_PI / 180.0)
  var rotationTransform: CGAffineTransform  = CGAffineTransformMakeRotation(angle)
 
  translationTransform  = CGAffineTransformMakeTranslation(1.0 * videoSize.width, 0)
 
videolayerInstruction.setTransform(CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformConcat(videoTrack.preferredTransform, scaleFactorTransform), rotationTransform), translationTransform), atTime: kCMTimeZero)
 
 
 
  Comparison of methods
  =====================
  Both exported videos would appear the same on clients that support non zero rotations.  Method 2 is preferred however to ensure that
  the video appears correctly on all clients.
 
 

 
  Additional References
  ++++++++++++++++++++++
  
  The following are some additional references that I found useful.
  
  
  General
  ==========
  SDAVAssetExportSession
  https://github.com/rs/SDAVAssetExportSession
  
  
  Choosing a Frame Rate
  https://documentation.apple.com/en/finalcutpro/usermanual/index.html#chapter=D%26section=4%26tasks=true
  
  What video formats are supported on the iPhone 4?
  http://www.iphonefaq.org/archives/97961
  
  
  Aspect Ratio Fundamentals and Free Aspect Ratio Calculators
  http://www.premiumbeat.com/blog/understanding-aspect-ratios-and-aspect-ratio-calculators/
  Discusses ratios other than 4:3 and 16:9
  
  Media information tools
  ExifTool - http://www.sno.phy.queensu.ca/~phil/exiftool/
  MediaInfo - http://mediaarea.net/en/MediaInfo
  
  
  AV Foundation Programming Guide
  https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/00_Introduction.html
  
  
  H.264/MPEG-4 AVC
  http://en.wikipedia.org/wiki/H.264/MPEG-4_AVC#Profiles
  Includes discussion of profiles.
  
  
  
  Temp directory
  ===============
  UIImagePickerController doesn't delete temp video capture file from /tmp/capture
  http://stackoverflow.com/questions/20225360/uiimagepickercontroller-doesnt-delete-temp-video-capture-file-from-tmp-capture?rq=1
  
  
  
  Adding & Retrieving Metadata
  =============================
  How to add and retrieve custom meta data to a video file in iOS programming?
  http://stackoverflow.com/questions/14986103/how-to-add-and-retrieve-custom-meta-data-to-a-video-file-in-ios-programming
  
  Writing metadata to ALAsset
  http://stackoverflow.com/questions/5753740/writing-metadata-to-alasset
  
  AV Foundation Metadata Key Constants Reference
  https://developer.apple.com/library/mac/documentation/AVFoundation/Reference/AVFoundationMetadataKeyReference/Reference/reference.html
  
  AVMovieExporter (Sample code from Apple)
  https://developer.apple.com/library/ios/samplecode/AVMovieExporter/Introduction/Intro.html
  
  
  
  MPMoviePlayerController
  ==========================
  iOS: How to use MPMoviePlayerController
  http://stackoverflow.com/questions/12822420/ios-how-to-use-mpmovieplayercontroller
  
  
  
  UIRequiredDeviceCapabilities
  ============================
  Declaring the Required Device Capabilities
  https://developer.apple.com/library/ios/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/DeviceCompatibilityMatrix/DeviceCompatibilityMatrix.html
  Update UIRequiredDeviceCapabilities to include  "video-camera"
  
  
  
  Reducing file size
  ===================
  How can I reduce the file size of a video created with UIImagePickerController?
  http://stackoverflow.com/questions/11751883/how-can-i-reduce-the-file-size-of-a-video-created-with-uiimagepickercontroller?rq=1
  
  
  Record square video in iOS
  http://www.netwalk.be/article/record-square-video-ios
  
  
  Video settings
  ===============
  Advanced encoding settings - YouTube
  Recommended bitrates, codecs, and resolutions, and more
  https://support.google.com/youtube/answer/1722171?hl=en
  
  http://www.ezs3.com/public/What_bitrate_should_I_use_when_encoding_my_video_How_do_I_optimize_my_video_for_the_web.cfm
  Generally you should never exceed the frame rate of the source video. Obviously, the best results
  will be achieved if the frame rate is kept the same as your original source.
  
  http://www.videohelp.com/tools/H.264-Encoder
  For a frame size of 640 x 480 (standard definition), choose a data rate of 1,000-2,000 Kbps.
  For a frame size of 320 x 240 (Internet-size content), choose a data rate of 300-500 Kbps.
  
  h.264 Advanced Guide
  https://app.zencoder.com/docs/guides/encoding-settings/h264-advanced
  

 
 */


#endif

















