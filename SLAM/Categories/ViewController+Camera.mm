//
//  ViewController+RGBSource.m
//  SLAM
//
//  Created by Xin Sun on 21/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController+Camera.h"

#include <iostream>

#import "ImageUtility.h"

#import "ViewController+OrbSLAM.h"
#import "ViewController+InfoLabels.h"
#import "ViewController+ImageView.h"
#import "ViewController+MetalView.h"
#import "ViewController+SceneView.h"

@implementation ViewController (Camera)

cv::Mat            _inputImage;
AVCaptureSession*  _session;
AVCaptureDevice*   _device;
dispatch_queue_t   _trackingQueue;
// A not strict lock
bool               _isTracking = false;

- (void) initCamera {
    [self setupCamera];
}

- (void) startCameraCapturing {
    _trackingQueue = dispatch_queue_create("tracking", DISPATCH_QUEUE_SERIAL);
    [_session startRunning];
}

// MAIN LOOP
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    if (! _isTracking) {
        _isTracking = true;
        _inputImage = [ImageUtility cvMatFromCMSampleBufferRef: sampleBuffer];
        
        dispatch_async(_trackingQueue, ^{
            cv::Mat dummyDepth;
            cv::Mat color;
            cv::resize(_inputImage, color, cv::Size(320, 240));
            cv::cvtColor(color, color, CV_BGRA2GRAY);
            
            // Update SLAM (model)
            [self.profiler start];
            [self trackFrame:color andDepth:dummyDepth];
            [self.profiler end];
            
            // OrbSLAM condition variables
            int trackingState                                  = [self getTrackingState];
            int keyFrameCount                                  = [self getnKF];
            int mapPointCount                                  = [self getnMP];
            std::vector<ORB_SLAM::MapPoint *> mapPoints        = [self getMapPoints];
            std::vector<ORB_SLAM::MapPoint*> *matchedMapPoints = [self getMatchedMapPoints];
            std::vector<cv::KeyPoint> *currentKeyPoints        = [self getCurrentKeyPoints];
            std::vector<bool> *outliers                        = [self getOutliers];
            cv::Mat R                                          = [self getCurrentPose_R];
            cv::Mat T                                          = [self getCurrentPose_T];
            
            // Update Views
            [self updateInfoLabelsWithState:trackingState
                              KeyFrameCount:keyFrameCount
                           andMapPointCount:mapPointCount];

            if (trackingState == TrackingState::WORKING) {
                [self updateMetalViewWithR:R andT:T];
                
                [self updateSceneViewWithR:R andT:T];
                [self updateSceneViewWithMapPoints:mapPoints];
                
                [self updateImageViewWithImage:_inputImage
                              MatchedMapPoints:matchedMapPoints
                              CurrentKeyPoints:currentKeyPoints
                                   andOutliers:outliers];
            } else if (trackingState == TrackingState::INITIALIZING) {
                [self updateImageViewWithImage:_inputImage
                                 InitKeyPoints:[self getInitKeyPoints]
                              CurrentKeyPoints:currentKeyPoints
                                    andMatches:[self getMatches]];
            }

            _isTracking = false;
        });
    }
}

- (void) setupCamera {
    NSString *sessionPreset = AVCaptureSessionPreset640x480;
    
    // Set up Capture Session.
    _session = [[AVCaptureSession alloc] init];
    [_session beginConfiguration];
    
    // Set preset session size.
    [_session setSessionPreset:sessionPreset];
    
    // Create a video device and input from that Device.  Add the input to the capture session.
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (_device == nil)
        assert(0);
    
    // Configure Focus, Exposure, and White Balance
    NSError *error;
    
    // Use auto-exposure, and auto-white balance and set the focus to infinity.
    if([_device lockForConfiguration:&error]) {
        // Allow exposure to change
        if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        
        // Allow white balance to change
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        
        // Set focus at the maximum position allowable (e.g. "near-infinity") to get the
        // best color/depth alignment.
        [_device setFocusModeLockedWithLensPosition:1.0f completionHandler:nil];
        
        [_device unlockForConfiguration];
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (error) {
        NSLog(@"Cannot initialize AVCaptureDeviceInput");
        assert(0);
    }
    
    [_session addInput:input]; // After this point, captureSession captureOptions are filled.
    
    //  Create the output for the capture session.
    AVCaptureVideoDataOutput* dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // We don't want to process late frames.
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    // Use BGRA pixel format.
    [dataOutput setVideoSettings:[NSDictionary
                                  dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                  forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    // Set dispatch to be on the main thread so OpenGL can do things with the data
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [_session addOutput:dataOutput];
    
    if([_device lockForConfiguration:&error]) {
        [_device setActiveVideoMaxFrameDuration:CMTimeMake(1, 30)];
        [_device setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
        [_device unlockForConfiguration];
    }
    
    [_session commitConfiguration];
}

@end
