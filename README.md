
## About

This is an iOS Swift based project that is intended to show how various video formats and orientations can be
read and exported for maximum compatibility across clients and reduced size.

## Criteria

The following criteria was used for export:
 
  1. Dimensions reduced to no greater than 512 x 288 (16:9) or 480 x 360 (4:3)
  2. Rotation (preferred transform) of container set to 0 degrees (CGAffineTransformIdentity).
  3. Video profile level set to AVVideoProfileLevelH264Baseline30 (Baseline@L3.0)
  4. Video bitrate reduced to average of 725,000 bps
  5. MP4 container
  

## Installation

Navigate to the folder where you downloaded the project (Ex: VideoExport-master) and execute

pod install

Assumes that CocoaPods is installed on your system.

## Issues

### Simulator hang bug

Some videos cannot be processed on the simulator, but will work fine on a real device.  

This is an Xcode bug that has been documented in the following article:
[Simulator hang bug](http://finalize.com/2014/10/18/using-a-video-composition-to-process-certain-videos-causes-an-xcode-simulator-hang/) 

A bug report has been filed with Apple.   A project demonstrating the bug can be found at:
[GitHub VideoCompositionSimulatorBug](https://github.com/scottcarter/VideoCompositionSimulatorBug)

There is no known workaround.

### CMTime bug

There exists a bug on the simulator wherein a CMTime structure can get corrupted when it is passed from Swift to Objective-C. 
It occurs only on the iPhone 4S and iPhone 5 configurations.   The bug has been documented in the article:
[CMTime bug](http://finalize.com/2014/10/08/xcode-simulator-bug-with-swift-to-objective-c-call-passing-cmtime-structure/)

A bug report has been filed with Apple.   A project demonstrating the bug can be found at:
[GitHub CMTimeBug](https://github.com/scottcarter/CMTimeBug)

A workaround exists and has been implemented in the method getVideoComposition() in ViewController.swift.


## Details

There is extensive details about the project including how I established the criteria to be used in the file
[README.h](https://github.com/scottcarter/VideoExport/blob/master/VideoExport/README.h)

The Table of Contents of that file includes:

**Overview**
  
**Criteria Discussion**
- Support for MPMoviePlayerController
- Support for Dropbox
- Android Support
- Bitrate considerations
- Container
  
**Meeting project criteria**
- AVAssetExportSession
- AVAssetReader/AVAssetWriter
- SDAVAssetExportSession
  
**Misc. Project Notes**
  
**Portrait Example**
  
**Preferred transform**
  
**Contrasting preferred transform with video composition transform**
- Method 1
- Method 2
- Comparison of methods
  
**Additional References**
- General
- Temp directory
- Adding & Retrieving Metadata
- MPMoviePlayerController
- UIRequiredDeviceCapabilities
- Reducing file size
- Video settings
  
  
