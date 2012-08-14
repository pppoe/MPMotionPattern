//
//  MPVideoProcessor.h
//  MotionPattern
//
//  Created by Haoxiang Li on 8/14/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVCaptureSession;
@protocol AVCaptureVideoDataOutputSampleBufferDelegate;

@interface MPVideoProcessor : NSObject

@property (strong, nonatomic) AVCaptureSession *m_avSession;

- (void)setupAVCaptureSession;
- (void)startAVSessionWithBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate;
- (void)stopAVSession;

- (void)testWithBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate;

@end
