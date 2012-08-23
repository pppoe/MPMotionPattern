//
//  MPMotionPattern.h
//  MotionPattern
//
//  Created by Haoxiang Li on 8/23/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MPMotionPatternNone,
    /*< MPMotionPatternFourDirections */
    MPMotionPatternUp,
    MPMotionPatternDown,
    MPMotionPatternLeft,
    MPMotionPatternRight,
    /*< MPMotionPatternBackAndForth */
    MPMotionPatternUpAndDown,
    MPMotionPatternDownAndUp,
    MPMotionPatternLeftAndRight,
    MPMotionPatternRightAndLeft,
    /*< MPMotionPatternNodShake */
    MPMotionPatternNod,
    MPMotionPatternShake,
    MPMotionPatternCounts
} MPMotionPatternType;

@class MPMotionPatternBase;
@class MPMotionPatternFourDirections;
@class MPMotionPatternNodShake;

@protocol MPMotionPatternDelegate <NSObject>

- (void)patternDetected:(MPMotionPatternType)motionPatternType;

@end

@interface MPMotionPatternBase : NSObject {
    int m_state;
    int m_time;
}
    
- (void)setup;
- (void)processNewMove:(CGPoint)move withDelegate:(id<MPMotionPatternDelegate>)delegate;

@end

@interface MPMotionPatternFourDirections : MPMotionPatternBase

@end

@interface MPMotionPatternBackAndForth : MPMotionPatternBase {
    MPMotionPatternFourDirections *_fourDirectionPattern;
}

@end

@interface MPMotionPatternNodShake : MPMotionPatternBase {
    MPMotionPatternFourDirections *_fourDirectionPattern;
    id<MPMotionPatternDelegate> _delegate;
}

@end