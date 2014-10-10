//
//  VideoComposition.h
//  VideoExport
//
//  Created by Scott Carter on 10/7/14.
//  Copyright (c) 2014 Scott Carter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>


#pragma mark -
@interface VideoComposition : NSObject


+ (AVMutableVideoComposition *)finishVideoComposition:(AVMutableVideoCompositionLayerInstruction *)videolayerInstruction
                                                asset:(AVAsset *)asset
                                     videoComposition:(AVMutableVideoComposition *)videoComposition;

@end


