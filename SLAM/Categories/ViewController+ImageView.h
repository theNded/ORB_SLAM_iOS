//
//  ViewController+ImageView.h
//  SLAM
//
//  Created by Neo on 16/9/5.
//  Copyright © 2016年 Xin Sun. All rights reserved.
//

#import "ViewController.h"

#include <vector>
#include <opencv2/opencv.hpp>
#include "../ORB_SLAM/MapPoint.hpp"

@interface ViewController (ImageView)

- (void) initImageView;
- (void) updateImageViewWithImage:(cv::Mat &)image
                 MatchedMapPoints:(std::vector<ORB_SLAM::MapPoint*>&) matchedMapPoints
                 CurrentKeyPoints:(std::vector<cv::KeyPoint>&) currentKeyPoints
                      andOutliers:(std::vector<bool>&) outliers;


@end
