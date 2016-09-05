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
                    InitKeyPoints:(std::vector<cv::KeyPoint> *)initKeyPoints
                 CurrentKeyPoints:(std::vector<cv::KeyPoint> *)currentKeyPoints
                       andMatches:(std::vector<int> *)matches {
    for(unsigned int i = 0; i < matches->size(); i++) {
        if((*matches)[i] >= 0) {
            cv::line(image, (*initKeyPoints)[i].pt,
                     (*currentKeyPoints)[(*matches)[i]].pt,
                     cv::Scalar(0, 255, 0));
        }
    }
    
    UIImage* colorImage = [ImageUtility UIImageFromCVMat:image];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = colorImage;;
    });
}

- (void) updateImageViewWithImage:(cv::Mat &)image
                 MatchedMapPoints:(std::vector<ORB_SLAM::MapPoint*> *) matchedMapPoints
                 CurrentKeyPoints:(std::vector<cv::KeyPoint> *) currentKeyPoints
                      andOutliers:(std::vector<bool> *) outliers {
    
    const float r = 5;
    
    for(unsigned int i = 0;i < matchedMapPoints->size(); ++i) {
        if((*matchedMapPoints)[i] || (*outliers)[i]) {
            cv::Point2f pt1,pt2;
            pt1.x = 2 * (*currentKeyPoints)[i].pt.x-r;
            pt1.y = 2 * (*currentKeyPoints)[i].pt.y-r;
            pt2.x = 2 * (*currentKeyPoints)[i].pt.x+r;
            pt2.y = 2 * (*currentKeyPoints)[i].pt.y+r;
            if(!(*outliers)[i]) {
                cv::rectangle(image,pt1,pt2,cv::Scalar(0,255,0));
                cv::circle(image,2 * (*currentKeyPoints)[i].pt,2,cv::Scalar(0,255,0),-1);
            }
        }
    }

    UIImage* colorImage = [ImageUtility UIImageFromCVMat:image];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = colorImage;;
    });
}

@end
