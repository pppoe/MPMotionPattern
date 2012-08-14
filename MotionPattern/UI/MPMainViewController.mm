//
//  MPMainViewController.m
//  MotionPattern
//
//  Created by Haoxiang Li on 8/14/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import "MPMainViewController.h"
#import "MPVideoProcessor.h"
#import "MPMotionDetector.h"
#import <AVFoundation/AVFoundation.h>

#import "UIImage+OpenCV.h"

#define kControlButtonStatusWaitForStart 0x100
#define kControlButtonStatusWaitForStop 0x101
#define kControlButtonCaptionStart @"Start"
#define kControlButtonCaptionStop @"Stop"

@interface MPMainViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>
@end

@implementation MPMainViewController
@synthesize m_dispLabel, m_imageView, m_controlButton, m_motionDetector;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.m_videoProcessor = [[MPVideoProcessor alloc] init];        
        self.m_motionDetector = [[MPMotionDetector alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.m_controlButton setTag:kControlButtonStatusWaitForStart];
    [self.m_controlButton setTitle:kControlButtonCaptionStart forState:UIControlStateNormal];
    
    self.m_imageView.layer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CVImageBufferRef imageBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    CGImageRef dstImage = [MPVideoProcessor createGrayScaleImageRefFromImageBuffer:imageBuffer];
//    CGImageRef dstImage = [MPVideoProcessor createRGBImageRefFromImageBuffer:imageBuffer];
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    UIImage *prevFrameImage = [UIImage imageWithCGImage:(CGImageRef)self.m_imageView.layer.contents];
    UIImage *currFrameImage = [UIImage imageWithCGImage:dstImage];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
//        UIImage *newImage =  [MPMotionDetector testSamplingGrayImage:currFrameImage];
//        [self.m_imageView setImage:newImage];
        self.m_imageView.layer.contents = (__bridge id)dstImage;
    });
    
    CGImageRelease(dstImage);

    //< Motion Estimate
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.m_dispLabel setText:[self.m_motionDetector testDetection:prevFrameImage :currFrameImage]];
    });
}

#pragma IBAction
- (IBAction)controlButtonTapped:(UIButton *)controlBtn {
    if (controlBtn.tag == kControlButtonStatusWaitForStart)
    {
        NSLog(@"Start Tapped");
        [self.m_controlButton setTag:kControlButtonStatusWaitForStop];
        [self.m_controlButton setTitle:kControlButtonCaptionStop forState:UIControlStateNormal];
        [self.m_videoProcessor startAVSessionWithBufferDelegate:self];
    }
    else
    {
        NSLog(@"Stop Tapped");
        [self.m_controlButton setTag:kControlButtonStatusWaitForStart];
        [self.m_controlButton setTitle:kControlButtonCaptionStart forState:UIControlStateNormal];
        [self.m_videoProcessor stopAVSession];
    }
}

@end
