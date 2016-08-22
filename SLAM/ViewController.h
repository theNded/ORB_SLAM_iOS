//
//  ViewController.h
//  ORB_SLAM_iOS
//
//  Created by Xin Sun on 12/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#import "MetalView.h"
#import "Profiler.h"
#import <SceneKit/SceneKit.h>


@interface ViewController : UIViewController

// Labels
@property (nonatomic, retain) IBOutlet UILabel* stateLabel;
@property (nonatomic, retain) IBOutlet UILabel* fpsLabel;
@property (nonatomic, retain) IBOutlet UILabel* nKFLabel;
@property (nonatomic, retain) IBOutlet UILabel* nMPLabel;

// Viewers
@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet MetalView*   metalView;
@property (strong, nonatomic) IBOutlet SCNView*     sceneView;

// Buttons
@property (nonatomic, retain) IBOutlet UIButton* startBtn;
@property (nonatomic, retain) IBOutlet UIButton* resetBtn;

@property (nonatomic, retain) Profiler* profiler;

- (IBAction)startSLAM:(id)sender;
- (IBAction)resetSLAM:(id)sender;

@end

