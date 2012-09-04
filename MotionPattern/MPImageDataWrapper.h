//
//  MPImageDataWrapper.h
//  MotionPattern
//
//  Created by li haoxiang on 9/1/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

class ImageDataWrapper {
    
public:
    
    ImageDataWrapper(const int width, const int height);
    ImageDataWrapper(ImageDataWrapper const & imageData);
    ~ImageDataWrapper();
    
    int width() const;
    int height() const;
    unsigned char *data() const;
    
    unsigned char at(int y, int x) const;
    unsigned char& assignAt(int y, int x);
    
    const ImageDataWrapper& operator=(const ImageDataWrapper& imageData);
    
private:
    
    int _width;
    int _height;
    unsigned char *_data;
};

@interface MPImageDataWrapper : NSObject

+ (ImageDataWrapper *)imageDataWrapperFromUIImage:(UIImage *)image;
+ (void)fillImageDataWithUIImage:(UIImage *)image dataWrapper:(ImageDataWrapper *)dataWrapper;

@end
