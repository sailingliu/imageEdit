//
//  ImageCollectionViewCellEdit.h
//  imageEdit
//
//  Created by bytedance on 2020/7/7.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCollectionViewCellEdit : UICollectionViewCell
@property(nonatomic,strong,readwrite) UIImageView*imageViewEdit;
@property(nonatomic,strong,readwrite) UILabel*labelEdit;

@end

NS_ASSUME_NONNULL_END
