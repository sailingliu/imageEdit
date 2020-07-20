//
//  ImageCollectionViewCellEdit.m
//  imageEdit
//
//  Created by bytedance on 2020/7/7.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "ImageCollectionViewCellEdit.h"

@implementation ImageCollectionViewCellEdit
- (instancetype)initWithFrame:(CGRect)frame {
    self=[super initWithFrame:frame];
    if (self) {
        _imageViewEdit=[[UIImageView alloc]init];
        _imageViewEdit.contentMode=UIViewContentModeScaleAspectFit;
        _labelEdit=[[UILabel alloc]init];
        _labelEdit.textColor=[UIColor grayColor];
        _labelEdit.textAlignment=NSTextAlignmentCenter;
        _labelEdit.font=[UIFont systemFontOfSize:12];
        _labelEdit.textColor=[UIColor whiteColor];
        [self addSubview:_imageViewEdit];
        [self addSubview:_labelEdit];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageViewEdit.frame =CGRectMake(self.bounds.size.width*3/10,self.bounds.size.height*4/25, self.bounds.size.width*2/5, self.bounds.size.height*7/25);
    self.labelEdit.frame=CGRectMake(0, self.bounds.size.height*10/20, self.bounds.size.width, self.bounds.size.height/4);
}
@end
