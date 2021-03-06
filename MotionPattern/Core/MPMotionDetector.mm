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
#import "MPImageDataWrapper.h"
#import "MPMotionFilter.h"

#define square(X) ((X)*(X))

#define kBufferFramesCount 5

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

//< Measures
int MSE(ImageDataWrapper& curImage, ImageDataWrapper& prevImage, int nPosX, int nPosY)
{
	int nCount = 0;
	int nDifference = 0;
    
	for (int y1 = 0; y1 < curImage.height(); y1++)
	{
		for (int x1 = 0; x1 < curImage.width(); x1++)
		{
			int x2 = x1 + nPosX;
			int y2 = y1 + nPosY;
			if (x2 >= 0 && x2 < curImage.width() && y2 >= 0 && y2 < curImage.height())
			{
				nDifference += square((int)curImage.at(y1,x1) - (int)prevImage.at(y2,x2));
				nCount++;
			}
		}
	}
    
	nDifference /= nCount;
    
	return nDifference;
}

void MotionEst(ImageDataWrapper& curImage, ImageDataWrapper& prevImage, int range, int& moveX, int& moveY)
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

void gridSamplingImageMat(const ImageDataWrapper& org_imageMat, ImageDataWrapper& to_imageMat, const int spacing, const int binSizeInShift) {
    
    int nWidth = org_imageMat.width();
    int nHeight = org_imageMat.height();
    
    const int nSampledWidth = (nWidth >> binSizeInShift);
    const int nSampledHeight = (nHeight >> binSizeInShift);
    
    to_imageMat = ImageDataWrapper(nSampledWidth, nSampledHeight);
    
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
            int gray = (int)org_imageMat.at(y+spacing/2,px);
            sampleBuffer[by][the_x] += gray;
            sampleBufferCounts[by][the_x] += 1;
		}
	}
    
    //< Average
    for (int i = 0; i < nSampledHeight; i++)
	{
		for (int j = 0; j < nSampledWidth; j++)
		{
			to_imageMat.assignAt(i,j) = sampleBuffer[i][j] / sampleBufferCounts[i][j];
		}
	}
    
}

@implementation MPMotionDetector
@synthesize m_delegate, m_detectedPattern;

- (id)init {
    if ((self = [super init]))
    {
        m_motionFilter = [[MPMotionFilter alloc] init];
        m_currFrameImageData = new ImageDataWrapper;
        m_prevFrameImageData = new ImageDataWrapper;
    }
    return self;
}

- (void)dealloc {
    delete m_currFrameImageData;
    delete m_prevFrameImageData;
}

- (NSString *)testDetection:(UIImage *)org_prevFrame :(UIImage*)org_curFrame {

    const int spacing = kDefaultSamplingSpacing;
    const int binSizeInShift = kDefaultSamplingBinSizeInShift;
    
    ImageDataWrapper curFrameMat;
    [MPImageDataWrapper fillImageDataWithUIImage:org_curFrame dataWrapper:curFrameMat];
    
    if (!org_prevFrame || fabs([org_prevFrame size].width) < 1) //< Invalid PrevFrame
    {
        NSLog(@"First Frame");
        gridSamplingImageMat(curFrameMat, *m_currFrameImageData, spacing, binSizeInShift);
        return @"First Frame";
    }
    else
    {
        //< the Old-Curr Sampled Frame is now the prev-Sampled Frame
        static bool oddFrame = true;
        ImageDataWrapper* r_preFrame = (oddFrame ? m_currFrameImageData : m_prevFrameImageData);
        ImageDataWrapper* r_curFrame = (oddFrame ? m_prevFrameImageData : m_currFrameImageData);
        
        oddFrame = !oddFrame;
        
        const int search_range = 5;
        int moveX = 0;
        int moveY = 0;
        gridSamplingImageMat(curFrameMat, *r_curFrame, kDefaultSamplingSpacing, kDefaultSamplingBinSizeInShift);
        MotionEst(*r_curFrame, *r_preFrame, search_range, moveX, moveY);
        
        [m_motionFilter addMovement:CGPointMake(moveX, moveY)];
        
        CGPoint move = [m_motionFilter getAverageMovement:kBufferFramesCount];
        
        NSMutableString *outputStr = [NSMutableString stringWithString:@""];
        
        moveX = (int)move.x;
        moveY = (int)move.y;
        
        enum { EnumMoveNone, EnumMoveUp, EnumMoveDown, EnumMoveLeft, EnumMoveRight} moveType = EnumMoveNone;
        if (fabs(moveY) > fabs(moveX))
        {
            if (fabs(moveY) > 1/search_range)
            {
                moveType = (moveY < 0 ? EnumMoveRight : EnumMoveLeft);
                [outputStr appendFormat:(moveY < 0 ? kTextUniCodeRightArrow : kTextUniCodeLeftArrow)];
            }
        }
        else
        {
            if (fabs(moveX) > 1/search_range)
            {
                moveType = (moveX < 0 ? EnumMoveUp : EnumMoveDown);
                [outputStr appendFormat:(moveX < 0 ? kTextUniCodeUpArrow : kTextUniCodeDownArrow)];
            }
        }
        
        return outputStr;
    }
}

@end
