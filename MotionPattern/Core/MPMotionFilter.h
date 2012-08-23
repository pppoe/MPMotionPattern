//
//  MPMotionFilter.h
//  MotionPattern
//
//  Created by Haoxiang Li on 8/23/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPMotionFilter : NSObject {
    NSMutableArray *m_movementsBuffer;
}

- (void)addMovement:(CGPoint)move;

//< Choices
/*< Average movement of the nearest [frames] frames */
- (CGPoint)getAverageMovement:(int)frames;

@end
