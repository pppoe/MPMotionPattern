//
//  MPVideoProcessor.m
//  MotionPattern
//
//  Created by Haoxiang Li on 8/14/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import "MPVideoProcessor.h"
#import <AVFoundation/AVFoundation.h>

@implementation MPVideoProcessor
@synthesize m_avSession;

- (void)setupAVCaptureSession {

    NSError *error;
    
    AVCaptureSession *avSession = [[AVCaptureSession alloc] init];
    [avSession setSessionPreset:AVCaptureSessionPresetLow];
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice
                                                                              error:&error];
    if ([avSession canAddInput:deviceInput])
    {
        NSLog(@"avSession input added");
        [avSession addInput:deviceInput];
        
        //< Output Buffer
        AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        dataOutput.videoSettings = [NSDictionary
                                    dictionaryWithObject:[NSNumber numberWithUnsignedInt:
                                                          kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                    forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
        if ([avSession canAddOutput:dataOutput])
        {
            [avSession addOutput:dataOutput];
            NSLog(@"avSession output added");
        }
    }

    self.m_avSession = avSession;
}

- (void)startAVSessionWithBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>) delegate {
    AVCaptureVideoDataOutput *dataOutput = [[self.m_avSession outputs] objectAtIndex:0];
    if ([dataOutput sampleBufferDelegate] == nil || [dataOutput sampleBufferDelegate] != delegate)
    {
        [dataOutput setSampleBufferDelegate:delegate queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [self.m_avSession startRunning];
    }
}

- (void)stopAVSession {
    [self.m_avSession stopRunning];
}

- (void)testWithBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate {
    
    NSError *error;
    
    AVCaptureSession *avSession = [[AVCaptureSession alloc] init];
    [avSession setSessionPreset:AVCaptureSessionPresetLow];
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice
                                                                              error:&error];
    if ([avSession canAddInput:deviceInput])
    {
        NSLog(@"avSession input added");
        [avSession addInput:deviceInput];
        
        //< Output Buffer
        AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        dataOutput.videoSettings = [NSDictionary
                                    dictionaryWithObject:[NSNumber numberWithUnsignedInt:
                                                          kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                    forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
        if ([avSession canAddOutput:dataOutput])
        {
            [avSession addOutput:dataOutput];
            NSLog(@"avSession output added");
        }
    }

    self.m_avSession = avSession;
    
    AVCaptureVideoDataOutput *dataOutput = [[self.m_avSession outputs] objectAtIndex:0];
    if ([dataOutput sampleBufferDelegate] == nil || [dataOutput sampleBufferDelegate] != delegate)
    {
        [dataOutput setSampleBufferDelegate:delegate queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [self.m_avSession startRunning];
    }
}

@end
