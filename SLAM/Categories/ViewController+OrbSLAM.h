//
//  ViewController+ORB_SLAM.h
//  SLAM
//
//  Created by Xin Sun on 18/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (OrbSLAM)
    
- (void) initOrbSLAM;
- (void) updateOrbSLAM;

- (void) trackFrame:(cv::Mat&)colorImage
           andDepth:(cv::Mat&)depthImage;

- (int) getTrackingState;
- (int) getnKF;
- (int) getnMP;

- (cv::Mat) getCurrentPose_R;
- (cv::Mat) getCurrentPose_T;

- (std::vector<ORB_SLAM::MapPoint *>  ) getMapPoints;
- (std::vector<ORB_SLAM::MapPoint *> *) getMatchedMapPoints;
- (std::vector<cv::KeyPoint> *) getCurrentKeyPoints;
- (std::vector<cv::KeyPoint> *) getInitKeyPoints;
- (std::vector<bool> *) getOutliers;
- (std::vector<int> *)  getMatches;

- (void) requestSLAMReset;

@end
