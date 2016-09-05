//
//  ViewController+PoseGraph.h
//  SLAM
//
//  Created by Xin Sun on 21/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController.h"
#include "../ORB_SLAM/MapPoint.hpp"

@interface ViewController (SceneView)

- (void) initSceneView;
- (void) updateSceneViewWithR:(cv::Mat &)R andT:(cv::Mat &)T;
- (void) updateSceneViewWithMapPoints:(std::vector<ORB_SLAM::MapPoint *>&) points;

- (void) resetSceneView;

@end
