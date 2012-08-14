//
//  MPMotionDetector.h
//  MotionPattern
//
//  Created by Haoxiang Li on 8/14/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPMotionDetector;

@protocol MPMotionDetectorDelegate <NSObject>

- (void)motionPatternDetected:(MPMotionDetector *)detector;

@end

typedef enum {
    EnumMD_MoveDirection
} MotionDetectorPattern;

@interface MPMotionDetector : NSObject {
    cv::Mat m_prevFrameMat;
    cv::Mat m_currFrameMat;
}

@property (assign, nonatomic) id<MPMotionDetectorDelegate> m_delegate;
@property (assign, nonatomic) MotionDetectorPattern m_detectedPattern;

- (NSString *)testDetection:(UIImage *)prevFrame :(UIImage*)curFrame;

+ (UIImage *)testSamplingGrayImage:(UIImage *)image;

@end
