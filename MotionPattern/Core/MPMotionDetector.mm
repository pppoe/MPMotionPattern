//
//  MPMotionDetector.m
//  MotionPattern
//
//  The Major Part is ported from project below
/*********************************************************************\
 *                                                                     *
 *   Camera Phone Based Interaction Methods                            *
 *   Author : Jingtao Wang  jingtaow@cs.berkeley.edu                   *
 *			 John Canny         jfc@cs.berkeley.edu                   *
 *                                                                     *
 *   Computer Science Division                                         *
 *                                                                     *
 *   University of California, Berkeley                                *
 *   All Rights Reserved ,  Copyright (c) 2005 - 2006                  *
 *                                                                     *
 \*********************************************************************/

/*
 This class compares two adjacent images captured by the cell phone's built-in camera and
 outputs the relative movement detected to objects which subscribe the event of this class.
 
 The motion sensing algorithm used in this class is called Motion Estimation, which is commonly
 used in MPEG2/4 video codecs and optical mice. To be specific, we implement
 a motion estimation algorithm that uses Grid Sampling and Mean Square Error (MSE) based
 Full-search Matching Algorithm (FBMA). Additional Distance measurements such as Sum of Absolute
 Distance (SAD) and Cross-Correlation Function (CCF) as well as the corresponding native ARM implememtations
 (corr.s) are also included. For compreshsive surveys of the Motion Estimation algorithm and
 various fast implementations, please refer to [1][2] listed below.
 
 [1]	Kuhn, P., Algorithms, Complexity Analysis and VLSI Architectures for MPEG-4 Motion Estimation,
 Kluwer Academic Publishers, ISBN:0792385160.
 [2]	Furht, B., Greenberg, J., Westwater, R., Motion Estimation Algorithm for Video Compression,
 Kluwer Academic Publishers, Boston/Dordrecht/London, 1997
 
 Prior to our motion estimation implementation on the BREW platform, Rohs, M.[3] also implemented a SAD
 based FBMA on Nokia Symbian phones as part of the VisualCodes project (http://www.visualcodes.net/).
 
 [3]   Rohs, M., Real-World Interaction with Camera Phones. Second International Symposium on Ubiquitous
 Computing Systems (UCS 2004), Tokyo, Japan, November 2004. Also published under Revised Selected
 Papers, pp. 74-89, LNCS 3598, Springer, July 2005.
 
 */

//  Created by Haoxiang Li on 8/14/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//


#import "MPMotionDetector.h"
#import "UIImage+OpenCV.h"
#import "MPMotionFilter.h"
#import "MPMotionPattern.h"

#define square(X) ((X)*(X))

#define kBufferFramesCount 3

#define MOTION_BLOCK_WIDTH 20
#define MOTION_BLOCK_HEIGHT 14

#define EFFECTIVE_IMAGE_WIDTH 160
#define EFFECTIVE_IMAGE_HEIGHT 112

#define kDefaultSamplingSpacing 4
#define kDefaultSamplingBinSizeInShift 4

#define kTextUniCodeUpArrow @"\u2191"
#define kTextUniCodeDownArrow @"\u2193"
#define kTextUniCodeLeftArrow @"\u2190"
#define kTextUniCodeRightArrow @"\u2192"

int t_SampledImagePrev[MOTION_BLOCK_HEIGHT][MOTION_BLOCK_WIDTH];
int t_SampledImageCurr[MOTION_BLOCK_HEIGHT][MOTION_BLOCK_WIDTH];

//< Measures
int MSE(cv::Mat& curImage, cv::Mat& prevImage, int nPosX, int nPosY)
{
	int nCount = 0;
	int nDifference = 0;
    
	for (int y1 = 0; y1 < curImage.rows; y1++)
	{
		for (int x1 = 0; x1 < curImage.cols; x1++)
		{
			int x2 = x1 + nPosX;
			int y2 = y1 + nPosY;
			if (x2 >= 0 && x2 < curImage.cols && y2 >= 0 && y2 < curImage.rows)
			{
                
				nDifference += square((int)curImage.at<uchar>(y1,x1) - (int)prevImage.at<uchar>(y2,x2));
				nCount++;
			}
		}
	}
    
	nDifference /= nCount;
    
	return nDifference;
}

void MotionEst(cv::Mat& curImage, cv::Mat& prevImage, int range, int& moveX, int& moveY)
{
	int nMinError = 999999;
	int nMV_X = 0;
	int nMV_Y = 0;
	int nMinDist = 0;
    
	for (int nOffsetY = -range; nOffsetY <= range; nOffsetY++)
	{
		for (int nOffsetX = -range; nOffsetX <= range; nOffsetX++)
		{
			int nDifference = 0;
            
			nDifference = MSE(curImage, prevImage, nOffsetX, nOffsetY);
            
			if ( nDifference < nMinError)
			{
				nMinError = nDifference;
				nMV_X = nOffsetX;
				nMV_Y = nOffsetY;
				nMinDist = nOffsetX*nOffsetX + nOffsetY*nOffsetY;
			}
            else if (nDifference == nMinError)
			{
				int nDistance = nOffsetX*nOffsetX + nOffsetY*nOffsetY;
                
				if (nDistance < nMinDist)
				{
					nMinError = nDifference;
					nMV_X = nOffsetX;
					nMV_Y = nOffsetY;
					nMinDist = nDistance;
				}
			}
		}
	}
    
    moveX = nMV_X;
    moveY = nMV_Y;
}

void gridSamplingImageMat(cv::Mat& org_imageMat, cv::Mat& to_imageMat, const int spacing, const int binSizeInShift) {
    
    int nWidth = org_imageMat.cols;
    int nHeight = org_imageMat.rows;
    
    const int nSampledWidth = (nWidth >> binSizeInShift);
    const int nSampledHeight = (nHeight >> binSizeInShift);
    
    to_imageMat = cv::Mat(nSampledHeight, nSampledWidth, CV_8U);
    
    int sampleBufferCounts[nSampledHeight][nSampledWidth];
    int sampleBuffer[nSampledHeight][nSampledWidth];
	for (int i = 0; i < nSampledHeight; i++)
	{
		for (int j = 0; j < nSampledWidth; j++)
		{
			sampleBuffer[i][j] = 0;
            sampleBufferCounts[i][j] = 0;
		}
	}
    
	for (int y = 0; y < nHeight; y += spacing)
	{
		int by = y >> binSizeInShift;
		for (int px = 1; px < nWidth; px += spacing)
		{
            int the_x = (px>>binSizeInShift);
            int gray = (int)org_imageMat.at<uchar>(y+spacing/2,px);
            sampleBuffer[by][the_x] += gray;
            sampleBufferCounts[by][the_x] += 1;
		}
	}
    
    //< Average
    for (int i = 0; i < nSampledHeight; i++)
	{
		for (int j = 0; j < nSampledWidth; j++)
		{
			to_imageMat.at<uchar>(i,j) = sampleBuffer[i][j] / sampleBufferCounts[i][j];
		}
	}
    
}

@interface MPMotionDetector () <MPMotionPatternDelegate>

@end

@implementation MPMotionDetector
@synthesize m_delegate, m_detectedPattern;

- (void)patternDetected:(MPMotionPatternType)motionPatternType {
    
}

- (id)init {
    if ((self = [super init]))
    {
        m_motionFilter = [[MPMotionFilter alloc] init];
        m_pattern = [[MPMotionPatternNodShake alloc] init];
    }
    return self;
}

- (NSString *)testDetection:(UIImage *)org_prevFrame :(UIImage*)org_curFrame {

    const int spacing = kDefaultSamplingSpacing;
    const int binSizeInShift = kDefaultSamplingBinSizeInShift;
    
    cv::Mat curFrameMat = [org_curFrame CVGrayscaleMat];
    
    if (!org_prevFrame || fabs([org_prevFrame size].width) < 1) //< Invalid PrevFrame
    {
        NSLog(@"First Frame");
        gridSamplingImageMat(curFrameMat, m_currFrameMat, spacing, binSizeInShift);
        return @"First Frame";
    }
    else
    {
        //< the Old-Curr Sampled Frame is now the prev-Sampled Frame
        static bool oddFrame = true;
        cv::Mat& r_preFrame = (oddFrame ? m_currFrameMat : m_prevFrameMat);
        cv::Mat& r_curFrame = (oddFrame ? m_prevFrameMat : m_currFrameMat);
        
        oddFrame = !oddFrame;
        
        const int search_range = 5;
        int moveX = 0;
        int moveY = 0;
        gridSamplingImageMat(curFrameMat, r_curFrame, kDefaultSamplingSpacing, kDefaultSamplingBinSizeInShift);
        MotionEst(r_curFrame, r_preFrame, search_range, moveX, moveY);
        
        [m_motionFilter addMovement:CGPointMake(moveX, moveY)];
        
        CGPoint move = [m_motionFilter getAverageMovement:kBufferFramesCount];
        
        NSMutableString *outputStr = [NSMutableString stringWithString:@""];
        
        moveX = (int)move.x;
        moveY = (int)move.y;
        
        const int activeMoveFrameCounts = 10;
        enum { EnumMoveNone, EnumMoveUp, EnumMoveDown, EnumMoveLeft, EnumMoveRight} moveType = EnumMoveNone;
        if (fabs(moveY) > fabs(moveX))
        {
            if (fabs(moveY) > 0)
            {
                moveType = (moveY < 0 ? EnumMoveRight : EnumMoveLeft);
            }
        }
        else
        {
            if (fabs(moveX) > 0)
            {
                moveType = (moveX < 0 ? EnumMoveUp : EnumMoveDown);
            }
        }

        [m_pattern processNewMove:move withDelegate:self];
        
//        [outputStr appendFormat:(moveY < 0 ? kTextUniCodeRightArrow : kTextUniCodeLeftArrow)];
//        [outputStr appendFormat:(moveX < 0 ? kTextUniCodeUpArrow : kTextUniCodeDownArrow)];

        return outputStr;
    }
}

@end
