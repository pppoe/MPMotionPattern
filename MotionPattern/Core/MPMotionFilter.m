//
//  MPMotionFilter.m
//  MotionPattern
//
//  Created by Haoxiang Li on 8/23/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import "MPMotionFilter.h"

#define kMaxBufferMovementCounts 1000

@implementation MPMotionFilter

- (id)init {
    if ((self = [super init]))
    {
        m_movementsBuffer = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)addMovement:(CGPoint)move {
    [m_movementsBuffer addObject:[NSValue valueWithCGPoint:move]];

    if ([m_movementsBuffer count] >= kMaxBufferMovementCounts)
    {
        [m_movementsBuffer removeObjectsInRange:NSMakeRange(0, kMaxBufferMovementCounts/2)];
    }
    NSLog(@"%f %f", move.x, move.y);
}

- (CGPoint)getAverageMovement:(int)frames {
    CGPoint averMove = CGPointMake(0, 0);
    int bufferLength = [m_movementsBuffer count];
    if (bufferLength >= frames)
    {
        
        for (int c = 1; c <= frames; c++)
        {
            averMove.x += [[m_movementsBuffer objectAtIndex:(bufferLength-c)] CGPointValue].x;
            averMove.y += [[m_movementsBuffer objectAtIndex:(bufferLength-c)] CGPointValue].y;
        }
        
        averMove.x /= frames;
        averMove.y /= frames;
        
        NSLog(@"%f %f %d/%d : %f %f", averMove.x, averMove.y, frames, bufferLength,
              [[m_movementsBuffer lastObject] CGPointValue].x,
              [[m_movementsBuffer lastObject] CGPointValue].y
              );
    }
    
    return averMove;
}

@end
