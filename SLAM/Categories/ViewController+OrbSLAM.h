//
//  ViewController+ORB_SLAM.h
//  SLAM
//
//  Created by Xin Sun on 18/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController.h"

#include "../ORB_SLAM/MapPoint.hpp"

@interface ViewController (OrbSLAM)
    
- (void) initOrbSLAM;
- (void) updateOrbSLAM;

- (void) trackFrame:(cv::Mat&)colorImage
           andDepth:(cv::Mat&)depthImage;

- (int) getTrackingState;
- (cv::Mat) getCurrentPose_R;
- (cv::Mat) getCurrentPose_T;
- (int) getnKF;
- (int) getnMP;

- (std::vector<ORB_SLAM::MapPoint *>) getMapPoints;
- (std::vector<cv::KeyPoint>) getKeyPoints;
- (std::vector<ORB_SLAM::MapPoint*>) getMatchedPoints;
- (std::vector<bool>) getOutliers;

- (void) requestSLAMReset;

@end
