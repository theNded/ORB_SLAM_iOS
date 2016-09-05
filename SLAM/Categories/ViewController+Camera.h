//
//  ViewController+RGBSource.h
//  SLAM
//
//  Created by Xin Sun on 21/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController (Camera) <AVCaptureVideoDataOutputSampleBufferDelegate>

- (void) initCamera;
- (void) startCameraCapturing;

@end
