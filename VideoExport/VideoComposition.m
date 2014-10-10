//
//  VideoComposition.m
//  VideoExport
//
//  Created by Scott Carter on 10/7/14.
//  Copyright (c) 2014 Scott Carter. All rights reserved.
//

#import "VideoComposition.h"


@interface VideoComposition ()

@end


@implementation VideoComposition

// Helper to getVideoComposition() in ViewController.swift to get around a CMTime bug that
// is described where the call to this method is made.
//
+ (AVMutableVideoComposition *)finishVideoComposition:(AVMutableVideoCompositionLayerInstruction *)videolayerInstruction
                                                asset:(AVAsset *)asset
                                     videoComposition:(AVMutableVideoComposition *)videoComposition
{
    [videolayerInstruction setOpacity:0.0 atTime:asset.duration];
    
    
    AVMutableVideoCompositionInstruction *inst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    
    inst.layerInstructions = [NSArray arrayWithObject:videolayerInstruction];
    
    
    videoComposition.instructions = [NSArray arrayWithObject:inst];
    
    
    return videoComposition;
}


@end









