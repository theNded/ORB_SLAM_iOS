//
//  ViewController+PoseGraph.m
//  SLAM
//
//  Created by Xin Sun on 21/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController+SceneView.h"

@implementation ViewController (SceneView)

SCNNode*   _trajectoryNode;
SCNNode*   _poseNode;
SCNNode*   _mapNode;
SCNVector3 _prevPose;

bool initialPose = true;

- (void) initSceneView {
    SCNScene *scene = [SCNScene scene];
    
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor colorWithWhite:0.67 alpha:1.0];
    [scene.rootNode addChildNode:ambientLightNode];
    
    SCNNode *omniLightNode = [SCNNode node];
    omniLightNode.light = [SCNLight light];
    omniLightNode.light.type = SCNLightTypeOmni;
    omniLightNode.light.color = [UIColor colorWithWhite:0.75 alpha:1.0];
    omniLightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:omniLightNode];
    
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0, 0, 6);
    [scene.rootNode addChildNode:cameraNode];
    
    self.sceneView.scene = scene;
    self.sceneView.allowsCameraControl = true;
    self.sceneView.backgroundColor = [UIColor whiteColor];
    
    _trajectoryNode = [SCNNode node];
    _poseNode       = [SCNNode node];
    _mapNode        = [SCNNode node];
    [scene.rootNode addChildNode:_trajectoryNode];
    [scene.rootNode addChildNode:_poseNode];
    [scene.rootNode addChildNode:_mapNode];
}

- (void) updateSceneViewWithR:(cv::Mat &)R andT:(cv::Mat &)T {
    //cv::Mat_<float> origin = - R.t() * T;
    cv::Mat Rwc = R.t();
    cv::Mat Twc = -R.t() * T;

    float d = 0.08;
    cv::Mat_<float> o  = Rwc * (cv::Mat_<float>(3,1) <<  0,     0,      0) + Twc;
    cv::Mat_<float> p1 = Rwc * (cv::Mat_<float>(3,1) <<  d, d *0.8, d*0.5) + Twc;
    cv::Mat_<float> p2 = Rwc * (cv::Mat_<float>(3,1) <<  d, -d*0.8, d*0.5) + Twc;
    cv::Mat_<float> p3 = Rwc * (cv::Mat_<float>(3,1) << -d, -d*0.8, d*0.5) + Twc;
    cv::Mat_<float> p4 = Rwc * (cv::Mat_<float>(3,1) << -d, d *0.8, d*0.5) + Twc;
    
    SCNVector3 vo  = SCNVector3Make(o(0),  -o(1),  -o(2));
    SCNVector3 vp1 = SCNVector3Make(p1(0), -p1(1), -p1(2));
    SCNVector3 vp2 = SCNVector3Make(p2(0), -p2(1), -p2(2));
    SCNVector3 vp3 = SCNVector3Make(p3(0), -p3(1), -p3(2));
    SCNVector3 vp4 = SCNVector3Make(p4(0), -p4(1), -p4(2));
    
    if (!initialPose)
        [_trajectoryNode addChildNode:[self makeLineWithX:_prevPose andY:vo]];
    else
        initialPose = false;
    [_poseNode addChildNode:[self makePyramidWithO:vo andP1:vp1 P2:vp2 P3:vp3 P4:vp4]];
    _prevPose = vo;
}

- (void) updateSceneViewWithMapPoints:(std::vector<ORB_SLAM::MapPoint *>&) points {
    std::vector<SCNVector3> vertices;
    for(size_t i = 0, iend = points.size(); i < iend; ++i) {
        if(points[i]->isBad())
            continue;
        cv::Mat_<float> p = points[i]->GetWorldPos();
        vertices.push_back(SCNVector3Make(p(0), p(1), p(2)));
    }
    SCNGeometrySource *source = [SCNGeometrySource geometrySourceWithVertices:vertices.data()
                                                                        count:vertices.size()];
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:NULL
                                                                primitiveType:SCNGeometryPrimitiveTypePoint
                                                               primitiveCount:vertices.size()
                                                                bytesPerIndex:sizeof(int)];
    SCNGeometry *map = [SCNGeometry geometryWithSources:@[source]
                                               elements:@[element]];
    map.firstMaterial.diffuse.contents = [UIColor greenColor];
    [_mapNode removeFromParentNode];
    _mapNode = [SCNNode nodeWithGeometry:map];
    [self.sceneView.scene.rootNode addChildNode:_mapNode];
}

- (SCNNode *)makeLineWithX:(SCNVector3)x andY:(SCNVector3)y {
    SCNVector3 vertices[] = {x, y};
    int indices[] = {0, 1};
    SCNGeometrySource *source   = [SCNGeometrySource geometrySourceWithVertices:vertices count:2];
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:
                                   [NSData dataWithBytes:indices length:sizeof(indices)]
                                                                primitiveType:SCNGeometryPrimitiveTypeLine
                                                               primitiveCount:1
                                                                bytesPerIndex:sizeof(int)];
    SCNGeometry *line           = [SCNGeometry geometryWithSources:@[source]
                                                          elements:@[element]];
    line.firstMaterial.diffuse.contents = [UIColor redColor];
    SCNNode *lineNode = [SCNNode nodeWithGeometry:line];
    return lineNode;
}

- (SCNNode *)makePyramidWithO:(SCNVector3)o
                        andP1:(SCNVector3)p1
                           P2:(SCNVector3)p2
                           P3:(SCNVector3)p3
                           P4:(SCNVector3)p4 {
    SCNVector3 vertices[] = {o, p1, p2, p3, p4};
    int indices[] = {0, 1, 0, 2, 0, 3, 0, 4, 1, 2, 2, 3, 3, 4, 4, 1};
    SCNGeometrySource *source   = [SCNGeometrySource geometrySourceWithVertices:vertices count:5];
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:[NSData dataWithBytes:indices length:sizeof(indices)]
                                                                primitiveType:SCNGeometryPrimitiveTypeLine
                                                               primitiveCount:8
                                                                bytesPerIndex:sizeof(int)];
    SCNGeometry *pyramid        = [SCNGeometry geometryWithSources:@[source]
                                                            elements:@[element]];
    pyramid.firstMaterial.diffuse.contents = [UIColor blueColor];
    SCNNode *pyramidNode = [SCNNode nodeWithGeometry:pyramid];
    return pyramidNode;
}

- (void) resetSceneView {
    initialPose = true;
    for (SCNNode *node in [_trajectoryNode childNodes]) {
        [node removeFromParentNode];
    }
    for (SCNNode *node in [_poseNode childNodes]) {
        [node removeFromParentNode];
    }
    [_mapNode removeFromParentNode];
    [_trajectoryNode removeFromParentNode];
    [_poseNode removeFromParentNode];

    _trajectoryNode = [SCNNode node];
    _poseNode       = [SCNNode node];
    _mapNode        = [SCNNode node];
    [self.sceneView.scene.rootNode addChildNode:_trajectoryNode];
    [self.sceneView.scene.rootNode addChildNode:_poseNode];
    [self.sceneView.scene.rootNode addChildNode:_mapNode];
}

@end
