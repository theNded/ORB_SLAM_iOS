//
//  ViewController+PoseGraph.h
//  SLAM
//
//  Created by Xin Sun on 21/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (PoseGraph)

- (void) initScene;
- (void) addPose:(SCNVector3) point;
- (void) resetSceneView;

@end
