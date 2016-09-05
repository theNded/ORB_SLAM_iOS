//
//  ViewController.m
//  ORB_SLAM_iOS
//
//  Created by Xin Sun on 12/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController.h"

#import "Categories/ViewController+Camera.h"
#import "Categories/ViewController+OrbSLAM.h"

#import "Categories/ViewController+InfoLabels.h"
#import "Categories/ViewController+ImageView.h"
#import "Categories/ViewController+MetalView.h"
#import "Categories/ViewController+SceneView.h"

@implementation ViewController

- (void)viewDidLoad {    
    [super viewDidLoad];
    
    [self initCamera];

    [self initOrbSLAM];

    [self initInfoLabels];
    [self initImageView];
    [self initMetalView];
    [self initSceneView];
}

-(IBAction)startSLAM:(id)sender {
    [self startCameraCapturing];
}

- (IBAction)resetSLAM:(id)sender {
    [self requestSLAMReset];
    [self resetSceneView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
