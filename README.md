
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
  
  
