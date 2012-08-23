//
//  MPMotionPattern.m
//  MotionPattern
//
//  Created by Haoxiang Li on 8/23/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import "MPMotionPattern.h"

//< States
enum {
    MPStateInit = 0,
    /*< MPMotionPatternFourDirections */
    /*< MPMotionPatternBackAndForth */
    MPState_BackAndForth_Prepare,
    MPState_BackAndForth_InUp,
    MPState_BackAndForth_InDown,
    MPState_BackAndForth_InLeft,
    MPState_BackAndForth_InRight
    /**********************************/
    /*< MPMotionPatternNodShake */
};

@implementation MPMotionPatternBase

- (id)init {
    if ((self = [super init]))
    {
        [self setup];
    }
    return self;
}

- (void)setup {
    m_state = MPStateInit;
}

- (void)processNewMove:(CGPoint)move withDelegate:(id<MPMotionPatternDelegate>)delegate {}

@end

@implementation MPMotionPatternFourDirections

- (void)processNewMove:(CGPoint)move withDelegate:(id<MPMotionPatternDelegate>)delegate {
    int moveX = move.x;
    int moveY = move.x;
    if (fabs(moveX) > 0 && fabs(moveY) > 0)
    {
        if (fabs(moveX) > fabs(moveY))
        {
            [delegate patternDetected:(moveX < 0 ? MPMotionPatternLeft : MPMotionPatternRight)];
        }
        else
        {
            [delegate patternDetected:(moveY < 0 ? MPMotionPatternUp : MPMotionPatternDown)];
        }
    }
    else
    {
        [delegate patternDetected:MPMotionPatternNone];
    }
}

@end

@interface MPMotionPatternBackAndForth () <MPMotionPatternDelegate>

@end

@implementation MPMotionPatternBackAndForth

- (void)setup {
    [super setup];
    _fourDirectionPattern = [[MPMotionPatternFourDirections alloc] init];
}

- (void)processNewMove:(CGPoint)move {
    [_fourDirectionPattern processNewMove:move withDelegate:self];
}

- (void)patternDetected:(MPMotionPatternType)motionPatternType {
    
    const int actionAcceptDuration = 3;
    
    //< Update State
    switch (m_state) {
        case MPMotionPatternLeft:
            break;
        case MPMotionPatternRight:
            break;
        case MPMotionPatternUp:
            break;
        case MPMotionPatternDown:
            break;
        default:
            break;
    }
    
    m_time++;
}


@end


@interface MPMotionPatternNodShake () <MPMotionPatternDelegate>

@end

@implementation MPMotionPatternNodShake

- (void)setup {
    [super setup];
    _fourDirectionPattern = [[MPMotionPatternFourDirections alloc] init];
}

- (void)processNewMove:(CGPoint)move withDelegate:(id<MPMotionPatternDelegate>)delegate {
    _delegate = delegate;
    [_fourDirectionPattern processNewMove:move withDelegate:self];
}

- (MPMotionPatternType)testProcessNewMove:(CGPoint)move withDelegate:(id<MPMotionPatternDelegate>)delegate {
    _delegate = delegate;
    [_fourDirectionPattern processNewMove:move withDelegate:self];
}

- (void)patternDetected:(MPMotionPatternType)motionPatternType {
    
    const int actionAcceptDuration = 3;

    //< Update State
    if (m_state == 0)
    {
        switch (motionPatternType) {
            case MPMotionPatternLeft:
                m_state = 1;
                break;
            case MPMotionPatternRight:
                m_state = 2;
                break;
            case MPMotionPatternUp:
                m_state = 3;
                break;
            case MPMotionPatternDown:
                m_state = 4;
                break;
            case MPMotionPatternNone:
                m_state = 0;
                break;
            default:
                break;
        }
        m_time = 0;
    }
    else if (m_state == 1) //< In Left
    {
        if ((m_time < actionAcceptDuration) && (MPMotionPatternLeft == motionPatternType))
        {
            m_time++;
        }
        else if ((m_time >= actionAcceptDuration) && (MPMotionPatternRight == motionPatternType))
        {
            m_state = 2; //< Wait For actionAcceptDuration Right
        }
        else
        {
            m_state = 0;
            m_time = 0;
        }
    }
    else if (m_state == 2) //<  In Right
    {
        if ((m_time < actionAcceptDuration) && (MPMotionPatternRight == motionPatternType))
        {
            m_time++;
        }
        else if ((m_time >= actionAcceptDuration) && (MPMotionPatternRight == motionPatternType))
        {
            //< NO Detected
            [_delegate patternDetected:MPMotionPatternShake];
        }
        else
        {
            m_state = 0;
            m_time = 0;
        }
    }
    else if (m_state == 3) //< In Up
    {
        if ((m_time < actionAcceptDuration) && (MPMotionPatternUp == motionPatternType))
        {
            m_time++;
        }
        else if ((m_time >= actionAcceptDuration) && (MPMotionPatternDown == motionPatternType))
        {
            m_state = 4; //< Wait For actionAcceptDuration Right
        }
        else
        {
            m_state = 0;
            m_time = 0;
        }
    }
    else if (m_state == 4) //< In Down
    {
        if ((m_time < actionAcceptDuration) && (MPMotionPatternDown == motionPatternType))
        {
            m_time++;
        }
        else if ((m_time >= actionAcceptDuration) && (MPMotionPatternDown == motionPatternType))
        {
            //< YES Detected
            [_delegate patternDetected:MPMotionPatternNod];
        }
        else
        {
            m_state = 0;
            m_time = 0;
        }
    }
    else
    {
        //< Nothing
        [_delegate patternDetected:MPMotionPatternNone];
    }
}

@end

