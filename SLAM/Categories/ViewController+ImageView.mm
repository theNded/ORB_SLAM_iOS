//
//  ViewController+ImageView.m
//  SLAM
//
//  Created by Neo on 16/9/5.
//  Copyright © 2016年 Xin Sun. All rights reserved.
//

#import "ViewController+ImageView.h"

#import "ImageUtility.h"
#import "ViewController+OrbSLAM.h"

@implementation ViewController (ImageView)

- (void) initImageView {}

- (void) updateImageViewWithImage:(cv::Mat &)image
                 MatchedMapPoints:(std::vector<ORB_SLAM::MapPoint*>&) matchedMapPoints
                 CurrentKeyPoints:(std::vector<cv::KeyPoint>&) currentKeyPoints
                      andOutliers:(std::vector<bool>&) outliers {
    if ([self getTrackingState] == 3) {
        int mnTracked=0;
        const float r = 5;
        
        for(unsigned int i=0;i < matchedMapPoints.size();i++)
        {
            if(matchedMapPoints[i] || outliers[i])
            {
                cv::Point2f pt1,pt2;
                pt1.x = 2 * currentKeyPoints[i].pt.x-r;
                pt1.y = 2 * currentKeyPoints[i].pt.y-r;
                pt2.x = 2 * currentKeyPoints[i].pt.x+r;
                pt2.y = 2 * currentKeyPoints[i].pt.y+r;
                if(!outliers[i])
                {
                    cv::rectangle(image,pt1,pt2,cv::Scalar(0,255,0));
                    cv::circle(image,2 * currentKeyPoints[i].pt,2,cv::Scalar(0,255,0),-1);
                    mnTracked++;
                }
            }
        }
    }
    
    UIImage* colorImage = [ImageUtility UIImageFromCVMat:image];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = colorImage;;
    });
}

@end
