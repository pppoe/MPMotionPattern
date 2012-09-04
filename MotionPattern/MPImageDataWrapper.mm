//
//  MPImageDataWrapper.mm
//  MotionPattern
//
//  Created by li haoxiang on 9/1/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import "MPImageDataWrapper.h"

#pragma mark ImageDataWrapper

ImageDataWrapper::ImageDataWrapper(const int width, const int height)
{
    _width = width;
    _height = height;
    _data = new unsigned char[_height*_width];
}

ImageDataWrapper::ImageDataWrapper(const ImageDataWrapper& imageData)
{
    *this = imageData;
}

const ImageDataWrapper& ImageDataWrapper::operator=(const ImageDataWrapper& imageData)
{
    _width = imageData.width();
    _height = imageData.height();
    _data = new unsigned char[_height*_width];
    memcpy(_data, imageData.data(), _width*_height*sizeof(unsigned char));
    return *this;
}

ImageDataWrapper::~ImageDataWrapper()
{
    delete [] _data;
}

int ImageDataWrapper::width() const
{
    return _width;
}

int ImageDataWrapper::height() const
{
    return _height;
}

unsigned char *ImageDataWrapper::data() const
{
    return _data;
}

unsigned char ImageDataWrapper::at(int y, int x) const
{
    return _data[y*_width+x];
}

unsigned char& ImageDataWrapper::assignAt(int y, int x)
{
    return _data[y*_width+x];
}

@implementation MPImageDataWrapper

+ (ImageDataWrapper *)imageDataWrapperFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    ImageDataWrapper *dataWrapper = new ImageDataWrapper(cols, rows);
    
    CGContextRef contextRef = CGBitmapContextCreate(dataWrapper->data(),
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cols,                     // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNone |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return dataWrapper;
}

+ (void)fillImageDataWithUIImage:(UIImage *)image dataWrapper:(ImageDataWrapper *)dataWrapper
{
    *dataWrapper = *([MPImageDataWrapper imageDataWrapperFromUIImage:image]);
}

@end
