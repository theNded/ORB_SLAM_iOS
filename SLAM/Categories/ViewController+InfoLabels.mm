//
//  ViewController+InfoDisplay.m
//  SLAM
//
//  Created by Xin Sun on 18/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController+OrbSLAM.h"

#import "ViewController+InfoLabels.h"

#import "ViewController+MetalView.h"
#import "ViewController+SceneView.h"
#import "ImageUtility.h"

/*
 SYSTEM_NOT_READY=-1,
 NO_IMAGES_YET=0,
 NOT_INITIALIZED=1,
 INITIALIZING=2,
 WORKING=3,
 LOST=4
 */

using namespace cv;

@implementation ViewController (Info)

- (void) initInfoLabels {
    self.profiler = [[Profiler alloc] init];
}

- (void) updateInfoLabelsWithState:(int)state
                     KeyFrameCount:(int)nKF
                  andMapPointCount:(int)nMP {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.fpsLabel setText:[NSString stringWithFormat:@"fps: %f", 1.f/[self.profiler getAverageTime]]];
        
        switch(state) {
            case -1 :
                [self.stateLabel setText:[NSString stringWithFormat:@"state: %@", @"SYSTEM_NOT_READY"]];
                break;
            case 0 :
                [self.stateLabel setText:[NSString stringWithFormat:@"state: %@", @"NO_IMAGES_YET"]];
                break;
            case 1 :
                [self.stateLabel setText:[NSString stringWithFormat:@"state: %@", @"NOT_INITIALIZED"]];
                break;
            case 2 :
                [self.stateLabel setText:[NSString stringWithFormat:@"state: %@", @"INITIALIZING"]];
                break;
            case 3 : {
                [self.stateLabel setText:[NSString stringWithFormat:@"state: %@", @"WORKING"]];
                [self.nKFLabel setText:[NSString stringWithFormat:@"nKF: %d", nKF]];
                [self.nMPLabel setText:[NSString stringWithFormat:@"nMP: %d", nMP]];
                

                break;
            }
            case 4 :
                [self.stateLabel setText:[NSString stringWithFormat:@"state: %@", @"LOST"]];
                break;
            default: {
                break;
            }
        }
    });
}

@end
