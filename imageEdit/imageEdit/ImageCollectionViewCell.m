//
//  ImageCollectionViewCell.m
//  imageEdit
//
//  Created by bytedance on 2020/7/7.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@interface ImageCollectionViewCell ()

@end

@implementation ImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self=[super initWithFrame:frame];
    if (self) {
        _imageView=[[UIImageView alloc]init];
        _imageView.contentMode=UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

@end
