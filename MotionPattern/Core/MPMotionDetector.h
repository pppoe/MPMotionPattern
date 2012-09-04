//
//  MPMotionDetector.h
//  MotionPattern
//
//  Created by Haoxiang Li on 8/14/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

class ImageDataWrapper;

@class MPMotionDetector;
@class MPMotionFilter;
@class MPMotionPatternNodShake;

@protocol MPMotionDetectorDelegate <NSObject>

- (void)motionPatternDetected:(MPMotionDetector *)detector;

@end

typedef enum {
    EnumMD_MoveDirection
} MotionDetectorPattern;

@interface MPMotionDetector : NSObject {
    //< Frame Mat is int
    ImageDataWrapper *m_prevFrameImageData;
    ImageDataWrapper *m_currFrameImageData;
    
    MPMotionFilter *m_motionFilter;
    MPMotionPatternNodShake *m_pattern;
}

@property (assign, nonatomic) id<MPMotionDetectorDelegate> m_delegate;
@property (assign, nonatomic) MotionDetectorPattern m_detectedPattern;

- (NSString *)testDetection:(UIImage *)prevFrame :(UIImage*)curFrame;

@end
