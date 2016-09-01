//
//  ViewController+InfoDisplay.m
//  SLAM
//
//  Created by Xin Sun on 18/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController+InfoDisplay.h"
#import "ViewController+ORB_SLAM.h"
#import "ViewController+MetalRendering.h"
#import "ViewController+PoseGraph.h"
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

@implementation ViewController (InfoDisplay)

- (void)initProfiler {
    self.profiler = [[Profiler alloc] init];
}

- (void) updateInfoDisplay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.fpsLabel setText:[NSString stringWithFormat:@"fps: %f", 1.f/[self.profiler getAverageTime]]];
        
        switch([self getTrackingState]) {
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
                [self.nKFLabel setText:[NSString stringWithFormat:@"nKF: %d", [self getnKF]]];
                [self.nMPLabel setText:[NSString stringWithFormat:@"nMP: %d", [self getnMP]]];
                
                Mat R = [self getCurrentPose_R];
                Mat T = [self getCurrentPose_T];

                [self addCameraWithR:R andT:T];
                [self addMapPoints: [self getMapPoints]];
                [self drawObjectWith:R andT:T];

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

- (void) showColorImage:(Mat&)image {
    if ([self getTrackingState] == 3) {
        int mnTracked=0;
        const float r = 5;
        std::vector<ORB_SLAM::MapPoint*> vMatchedMapPoints = [self getMatchedPoints];
        std::vector<cv::KeyPoint> vCurrentKeys = [self getKeyPoints];
        std::vector<bool> mvbOutliers = [self getOutliers];
        for(unsigned int i=0;i<vMatchedMapPoints.size();i++)
        {
            if(vMatchedMapPoints[i] || mvbOutliers[i])
            {
                cv::Point2f pt1,pt2;
                pt1.x = 2 * vCurrentKeys[i].pt.x-r;
                pt1.y = 2 * vCurrentKeys[i].pt.y-r;
                pt2.x = 2 * vCurrentKeys[i].pt.x+r;
                pt2.y = 2 * vCurrentKeys[i].pt.y+r;
                if(!mvbOutliers[i])
                {
                    cv::rectangle(image,pt1,pt2,cv::Scalar(0,255,0));
                    cv::circle(image,2 * vCurrentKeys[i].pt,2,cv::Scalar(0,255,0),-1);
                    mnTracked++;
                }
            }
        }
    }
    UIImage* colorImage = [ImageUtility UIImageFromCVMat:image];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = colorImage;;
    });
}

@end
