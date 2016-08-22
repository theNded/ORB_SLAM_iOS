//
//  ViewController.m
//  ORB_SLAM_iOS
//
//  Created by Xin Sun on 12/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController.h"

#import "Categories/ViewController+RGBSource.h"
#import "Categories/ViewController+InfoDisplay.h"
#import "Categories/ViewController+MetalRendering.h"
#import "Categories/ViewController+ORB_SLAM.h"
#import "Categories/ViewController+PoseGraph.h"

@implementation ViewController

- (void)viewDidLoad {    
    [super viewDidLoad];
    
    [self initProfiler];
    [self initRendering];
    [self initORB_SLAM];
    [self initScene];
}

-(IBAction)startSLAM:(id)sender {
    [self runFromAVFoundation];
}

- (IBAction)resetSLAM:(id)sender {
    [self requestSLAMReset];
    [self resetSceneView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
