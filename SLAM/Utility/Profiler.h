//
//  Profiler.h
//  ORB_SLAM_iOS
//
//  Created by Xin Sun on 14/10/2015.
//  Copyright © 2015 Xin Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Profiler : NSObject

-(instancetype)init;

-(void)start;
-(void)end;

-(float)getAverageTime;

@end
