//
//  ViewController+ORB_SLAM.m
//  SLAM
//
//  Created by Xin Sun on 18/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import "ViewController+ORB_SLAM.h"
#import "ViewController+InfoDisplay.h"
#import "ImageUtility.h"

#include <iostream>
#include <boost/thread.hpp>
#include "../ORB_SLAM/LocalMapping.hpp"
#include "../ORB_SLAM/LoopClosing.hpp"
#include "../ORB_SLAM/KeyFrameDatabase.hpp"
#include "../ORB_SLAM/ORBVocabulary.hpp"
#include "../ORB_SLAM/Converter.hpp"

using namespace cv;

@implementation ViewController (ORB_SLAM)

ORB_SLAM::Map*              _World;
ORB_SLAM::Tracking*         _Tracker;
ORB_SLAM::ORBVocabulary*    _Vocabulary;
ORB_SLAM::KeyFrameDatabase* _Database;
ORB_SLAM::LocalMapping*     _LocalMapper;
ORB_SLAM::LoopClosing*      _LoopCloser;

bool isVocabLoaded = false;
    
- (void) initORB_SLAM {
    [self.stateLabel setText:@"state: Loading vocabulary"];
    [self.startBtn setEnabled:false];
    [self.resetBtn setEnabled:false];
    
    // New thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        const char *ORBvoc = [[[NSBundle mainBundle] pathForResource:@"ORBvoc"
                                                              ofType:@"binary"]
                              cStringUsingEncoding:[NSString defaultCStringEncoding]];
        _Vocabulary = new ORB_SLAM::ORBVocabulary();
        if (! isVocabLoaded) {
            isVocabLoaded = _Vocabulary->loadFromBinaryFile(ORBvoc);
            if(! isVocabLoaded) {
                std::cerr << "Failed to load vocabulary" << std::endl;
                exit(-1);
            }
        }
        _Database = new ORB_SLAM::KeyFrameDatabase(*_Vocabulary);
        
        // Execute when the thread is over
        dispatch_async(dispatch_get_main_queue(), ^{
            _World = new ORB_SLAM::Map();
            
            const char *settings = [[[NSBundle mainBundle] pathForResource:@"Settings"
                                                                    ofType:@"yaml"]
                                    cStringUsingEncoding:[NSString defaultCStringEncoding]];
            _Tracker = new ORB_SLAM::Tracking(_Vocabulary, _World, settings);
            boost::thread trackingThread(&ORB_SLAM::Tracking::Run, _Tracker);
            _Tracker->SetKeyFrameDatabase(_Database);
            
            _LocalMapper = new ORB_SLAM::LocalMapping(_World);
            boost::thread localMappingThread(&ORB_SLAM::LocalMapping::Run, _LocalMapper);
            
            _LoopCloser = new ORB_SLAM::LoopClosing(_World, _Database, _Vocabulary);
            boost::thread loopClosingThread(&ORB_SLAM::LoopClosing::Run, _LoopCloser);
            
            _Tracker->SetLocalMapper(_LocalMapper);
            _Tracker->SetLoopClosing(_LoopCloser);
            
            _LocalMapper->SetTracker(_Tracker);
            _LocalMapper->SetLoopCloser(_LoopCloser);
            
            _LoopCloser->SetTracker(_Tracker);
            _LoopCloser->SetLocalMapper(_LocalMapper);
            
            [self.stateLabel setText:@"state: Vocabulary loaded"];
            [self.startBtn setEnabled:true];
            [self.resetBtn setEnabled:true];
        });
    });
}

- (void) trackFrame:(Mat&)colorImage andDepth:(Mat&)depthImage {
    _Tracker->GrabImage(colorImage, depthImage);
}

- (Mat) getCurrentPose_R {
    return _Tracker->GetPose_R();
}

- (Mat) getCurrentPose_T {
    return _Tracker->GetPose_T();
}

- (int) getTrackingState {
    return _Tracker->mState;
}

- (int) getnKF {
    return _World->KeyFramesInMap();
}

- (std::vector<ORB_SLAM::MapPoint *>) getMapPoints {
    return _World->GetAllMapPoints();
}

- (std::vector<cv::KeyPoint>) getKeyPoints {
    return _Tracker->mCurrentFrame.mvKeys;
}

- (std::vector<ORB_SLAM::MapPoint*>) getMatchedPoints {
    return _Tracker->mCurrentFrame.mvpMapPoints;
}

- (std::vector<bool>) getOutliers {
    return _Tracker->mCurrentFrame.mvbOutlier;
}

- (int) getnMP {
    return _World->MapPointsInMap();
}

- (void) requestSLAMReset {
    _Tracker->Reset();
}

@end
