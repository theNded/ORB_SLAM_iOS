//
//  Profiler.m
//  ORB_SLAM_iOS
//
//  Created by Xin Sun on 14/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//
#import "Profiler.h"

@interface Profiler ()

@property int   frameCount;
@property float totalTimeInterval;
@property float lastTimeInterval;
@property NSDate* time;

@end

@implementation Profiler

-(instancetype)init {
    self = [super init];
    if (self) {
        _frameCount = 0;
        _totalTimeInterval = 0;
        _lastTimeInterval = -1;
    }
    return self;
}

-(void)start {
    _time = [NSDate date];
}

-(void)end {
    _frameCount ++;
    _lastTimeInterval   = -[_time timeIntervalSinceNow];
    _totalTimeInterval += _lastTimeInterval;
}

-(long)getLastTime {
    return _lastTimeInterval;
}

-(float)getAverageTime {
    if (_frameCount == 0)
        return -1;
    else
        return static_cast<float>(_totalTimeInterval/static_cast<float>(_frameCount));
}

@end