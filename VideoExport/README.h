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
 
 Notes:
 
 Some variables that would normally be declared as constants with "let" use 
 "var" for debugging purposes.   Current Xcode version does not
 make "let" constants visible to debugger.
  
 All variables are currently not visible in the debugger when running on the 
 real device.  This appears to be a limitation of current version of Xcode.
 
 When using the simulator, the breakpoint on "All Exceptions" must be disabled.
 Otherwise an exception is consistently triggered when a video is loaded.  This
 is a bug in the simulator which does not occur on the real device.
 

 Movies in simulator located in a directory such as:
 /Users/scarter/Library/Developer/CoreSimulator/Devices/<device id>/data/Media/DCIM/100APPLE
 
 Temp directory for simulator:
 /Users/scarter/Library/Developer/CoreSimulator/Devices/<device id>/data/Containers/Data/Application/<application id>/tmp
 
 
 Portrait Example
 =================
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
 
 
 
 
 
 
 
 
 
 */


#endif

















