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

 */

@implementation ViewController (Info)

NSDictionary* stateDict;

- (void) initInfoLabels {
    self.profiler = [[Profiler alloc] init];
    stateDict = [NSDictionary dictionaryWithObjectsAndKeys:
                 @"state: SYSTEM_NOT_READY", [NSNumber numberWithInt:  TrackingState::SYSTEM_NOT_READY],
                 @"state: NO_IMAGES_YET",    [NSNumber numberWithInt:  TrackingState::NO_IMAGES_YET],
                 @"state: NOT_INITIALIZED",  [NSNumber numberWithInt:  TrackingState::NOT_INITIALIZED],
                 @"state: INITIALIZING",     [NSNumber numberWithInt:  TrackingState::INITIALIZING],
                 @"state: WORKING",          [NSNumber numberWithInt:  TrackingState::WORKING],
                 @"state: LOST",             [NSNumber numberWithInt:  TrackingState::LOST],
                 nil];
}

- (void) updateInfoLabelsWithState:(int)state
                     KeyFrameCount:(int)nKF
                  andMapPointCount:(int)nMP {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.fpsLabel setText:[NSString stringWithFormat:@"fps: %f", 1.f/[self.profiler getAverageTime]]];
        [self.stateLabel setText:[stateDict objectForKey:[NSNumber numberWithInt: state]]];

        if (state == TrackingState::WORKING) {
            [self.nKFLabel setText:[NSString stringWithFormat:@"nKF: %d", nKF]];
            [self.nMPLabel setText:[NSString stringWithFormat:@"nMP: %d", nMP]];
        }
    });
}

@end
