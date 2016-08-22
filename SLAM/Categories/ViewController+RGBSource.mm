//
//  ViewController+RGBSource.m
//  SLAM
//
//  Created by Xin Sun on 21/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController+RGBSource.h"
#import "ViewController+ORB_SLAM.h"
#import "ViewController+InfoDisplay.h"
#import "CVImageIO.h"
#import "ImageUtility.h"
#include <iostream>

@implementation ViewController (RGBSource)

bool isDone = true;

cv::Mat            _tmp;
AVCaptureSession*  _session;
AVCaptureDevice*   _device;
dispatch_queue_t   _trackingQueue;

- (void) runFromAVFoundation {
    [self setupCamera];
    _trackingQueue = dispatch_queue_create("tracking", DISPATCH_QUEUE_SERIAL);
    [_session startRunning];
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
    if (error)
    {
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
    
    if([_device lockForConfiguration:&error])
    {
        [_device setActiveVideoMaxFrameDuration:CMTimeMake(1, 30)];
        [_device setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
        [_device unlockForConfiguration];
    }
    
    [_session commitConfiguration];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    if (isDone) {
        isDone = false;
        _tmp = [ImageUtility cvMatFromCMSampleBufferRef: sampleBuffer];
        
        dispatch_async(_trackingQueue, ^{
            cv::Mat dummyDepth;
            cv::Mat colorInput;
            cv::resize(_tmp, colorInput, cv::Size(320, 240));
            cv::cvtColor(colorInput, colorInput, CV_BGRA2GRAY);
    
            [self.profiler start];
            [self trackFrame:colorInput andDepth:dummyDepth];
            [self.profiler end];
            [self showColorImage:_tmp];
            [self updateInfoDisplay];
            isDone = true;
        });
    }
}

@end
