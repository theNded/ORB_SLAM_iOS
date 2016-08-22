//
//  ViewController+PoseGraph.h
//  SLAM
//
//  Created by Xin Sun on 21/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController.h"
#include "../ORB_SLAM/MapPoint.hpp"

@interface ViewController (PoseGraph)

- (void) initScene;
- (void) addCameraWithR:(cv::Mat &)R andT:(cv::Mat &)T;
- (void) addMapPoints:(std::vector<ORB_SLAM::MapPoint *>) points;
- (void) resetSceneView;

@end
