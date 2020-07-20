//
//  ViewController.m
//  imageEdit
//
//  Created by bytedance on 2020/7/3.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "ViewController.h"
#import "ImageCollectionViewCell.h"
#import "ImageCollectionViewCellEdit.h"
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAssetChangeRequest.h>
#import <QuartzCore/QuartzCore.h>
@interface ViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong) UIImagePickerController *imagePicker;
@property(nonatomic,strong)UIButton*importButton;
@property(nonatomic,strong,readwrite)NSArray*imagePathArray;
@property(nonatomic,strong,readwrite)NSArray*imagePathArrayEdit;
@property(nonatomic,strong,readwrite)NSArray*arrayEdit;
@property(nonatomic,strong)UIButton*filterButton;
@property(nonatomic,strong)UIButton*editButton;
@property(nonatomic,strong)UICollectionView* collectionViewFilter;
@property(nonatomic,strong)UICollectionView* collectionViewEdit;
@property(nonatomic,strong,readwrite)NSMutableArray*filterArray;
@property(nonatomic,strong,readwrite)UISlider* slider;
@property(nonatomic,strong,readwrite)UISlider* sliderC;
@property(nonatomic,strong,readwrite)UISlider* sliderS;
@property(nonatomic,strong,readwrite)UISlider* sliderH;
@property(nonatomic,strong,readwrite)CIFilter*brightFilter;
@property(nonatomic,strong,readwrite)CIFilter*contrastFilter;
@property(nonatomic,strong,readwrite)CIFilter*saturationFilter;
@property(nonatomic,strong,readwrite)CIFilter*highBrightFilter;
@property(nonatomic,strong)UIButton*compareButton;
@property(nonatomic,strong)UIButton*downLoadButton;
@property(nonatomic,strong)UIScrollView*scrollView;
@property(nonatomic,readwrite)CGFloat currentScale;
@property(nonatomic,strong)UIView *cutView;
@property(nonatomic,strong)CALayer*cutLayer;
@property(nonatomic,strong)UIButton*firstCancel;
@property(nonatomic,strong)UIButton*secondCancel;
@property(nonatomic,strong)UIButton*doneCut;
@property(nonatomic,strong)CAShapeLayer*fillLayer;
@property(nonatomic,assign,readwrite)CGPoint touchPoint;
@property(nonatomic,assign,readwrite)CGRect maskRect;
@property(nonatomic,strong,readwrite) UIBezierPath*innerPath;
@property(nonatomic,strong,readwrite) UIBezierPath*outerPath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor blackColor];
    _importImage=[[UIImageView alloc]initWithFrame:CGRectMake(0,0 ,self.view.bounds.size.width , self.view.bounds.size.height*4/5)];
    _importImage.userInteractionEnabled=YES;
    
    //scroll 设置
    [_scrollView addSubview:_importImage];
    //scrollview 设置2
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,0 ,self.view.bounds.size.width , self.view.bounds.size.height*4/5)];
    _scrollView.backgroundColor=[UIColor blackColor];
    _scrollView.contentSize=_importImage.frame.size;
    _scrollView.delegate=self;
    _scrollView.maximumZoomScale=5.0;
    _scrollView.minimumZoomScale=1.0;
    [_scrollView setZoomScale:1 animated:NO];
    _scrollView.scrollsToTop =NO;
    _scrollView.scrollEnabled =YES;
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:_scrollView];
    //设置双击手势
    UITapGestureRecognizer* doubleTapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired=2;
    [_importImage addGestureRecognizer:doubleTapGesture];
    
    //设置裁剪选择框随手势缩放
    UIPanGestureRecognizer*clickTap=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(changeSize:)];
    clickTap.delegate=self;
    [_importImage addGestureRecognizer:clickTap];
    [clickTap setMaximumNumberOfTouches:1];
    [clickTap setMinimumNumberOfTouches:1];
    [_importImage addGestureRecognizer:clickTap];
    //设置对比图单击重新选择照片
    _resultImage=[[UIImageView alloc]initWithFrame:CGRectMake(0,0 ,self.view.bounds.size.width , self.view.bounds.size.height*4/5)];
    _tempImage=[[UIImageView alloc]initWithFrame:CGRectMake(0,0 ,self.view.bounds.size.width , self.view.bounds.size.height*4/5)];
    //导入照片按钮
    _importButton=[[UIButton alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-100)/2, (self.view.bounds.size.height*4/5-100)/2, 100, 100)];
    [_importButton setImage:[UIImage imageNamed:@"import"] forState:UIControlStateNormal];
    [self.view addSubview:_importButton];
    [_importButton addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
    //初始化滤镜图片效果路径数组
    _imagePathArray=[[NSArray alloc]initWithObjects:@"filter1", @"filter2",@"filter3",@"filter4",@"filter5",@"filter6",@"filter7",@"filter8",@"filter9",@"filter10",nil];
    _imagePathArrayEdit=[[NSArray alloc]initWithObjects:@"caijian", @"brightj2",@"icon2",@"baohedu",@"gaoguang",nil];
    _arrayEdit=[[NSArray alloc]initWithObjects:@"裁剪",@"亮度",@"对比度",@"饱和度",@"高光", nil];
    _filterArray=[[NSMutableArray alloc]initWithObjects:
                      @"CIPhotoEffectMono",
                      @"CIPhotoEffectChrome",
                      @"CIPhotoEffectFade",
                      @"CIPhotoEffectInstant",
                      @"CIPhotoEffectNoir",
                      @"CIPhotoEffectProcess",
                      @"CIPhotoEffectTonal",
                      @"CIPhotoEffectTransfer",
                      @"CISRGBToneCurveToLinear",
                      @"CIVignetteEffect",
                  nil];
    //创建UICollectionView
    UICollectionViewFlowLayout*layout=[[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing=3;
    layout.itemSize=CGSizeMake((self.view.bounds.size.width)/5-10, self.view.bounds.size.height*12/75);
    UICollectionViewFlowLayout*layoutEdit=[[UICollectionViewFlowLayout alloc]init];
    layoutEdit.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    layoutEdit.minimumInteritemSpacing=3;
    layoutEdit.itemSize=CGSizeMake((self.view.bounds.size.width)/5-10, self.view.bounds.size.height*12/75);
    _collectionViewFilter=[[UICollectionView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height*4/5, self.view.bounds.size.width, self.view.bounds.size.height*2/15) collectionViewLayout:layout];
    _collectionViewFilter.showsHorizontalScrollIndicator=NO;
    _collectionViewFilter.backgroundColor=[UIColor blackColor];
    
    _collectionViewFilter.delegate=self;
    _collectionViewFilter.dataSource=self;
    [_collectionViewFilter registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.view addSubview:_collectionViewFilter];
    _collectionViewEdit=[[UICollectionView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height*4/5, self.view.bounds.size.width, self.view.bounds.size.height*2/15) collectionViewLayout:layoutEdit];
    _collectionViewEdit.showsHorizontalScrollIndicator=NO;
    _collectionViewEdit.backgroundColor=[UIColor blackColor];
    _collectionViewEdit.delegate=self;
    _collectionViewEdit.dataSource=self;
    [_collectionViewEdit registerClass:[ImageCollectionViewCellEdit class] forCellWithReuseIdentifier:@"UICollectionViewEditCell"];
    [self.view addSubview:_collectionViewEdit];
    _collectionViewEdit.hidden=YES;
    //设置两个底部按钮
    _filterButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/8, self.view.bounds.size.height*14/15, self.view.bounds.size.width*5/16, self.view.bounds.size.height*1/15)];
    _editButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width*9/16, self.view.bounds.size.height*14/15, self.view.bounds.size.width*5/16, self.view.bounds.size.height*1/15)];
    UIColor*gy=[[UIColor alloc]initWithRed:0.8 green:1.0 blue:0.6 alpha:1];

    [_filterButton setTitle:@"滤镜" forState:UIControlStateNormal];
 
    [_filterButton setTitleColor:gy forState:UIControlStateNormal];

    [_filterButton addTarget:self action:@selector(showFilter) forControlEvents:UIControlEventTouchUpInside];
    [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_editButton addTarget:self action:@selector(showEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_filterButton];
    [self.view addSubview:_editButton];
    
//光度控制滑动条
    _slider=[[UISlider alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/10, self.view.bounds.size.height*14/20, self.view.bounds.size.width*3/5, self.view.bounds.size.height*1/20)];
    _slider.minimumTrackTintColor=[UIColor grayColor];
    _slider.continuous=YES;
    
    _sliderC=[[UISlider alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/10, self.view.bounds.size.height*14/20, self.view.bounds.size.width*3/5, self.view.bounds.size.height*1/20)];
    _sliderC.minimumTrackTintColor=[UIColor grayColor];
    _sliderC.continuous=YES;
    
    _sliderS=[[UISlider alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/10, self.view.bounds.size.height*14/20, self.view.bounds.size.width*3/5, self.view.bounds.size.height*1/20)];
    _sliderS.minimumTrackTintColor=[UIColor grayColor];
    _sliderS.continuous=YES;
    
    _sliderH=[[UISlider alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/10, self.view.bounds.size.height*14/20, self.view.bounds.size.width*3/5, self.view.bounds.size.height*1/20)];
    _sliderH.minimumTrackTintColor=[UIColor grayColor];
    _sliderH.continuous=YES;
    
    //原图对比UI
    _compareButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width*8/10, self.view.bounds.size.height*14/20, self.view.bounds.size.width/10, self.view.bounds.size.width/10)];
    [_compareButton addTarget:self action:@selector(showOldImage) forControlEvents:UIControlEventTouchDown];
    [_compareButton addTarget:self action:@selector(hiddeOldImage) forControlEvents:UIControlEventTouchUpInside];
    [_compareButton setImage:[UIImage imageNamed:@"compare"] forState:UIControlStateNormal];
    [self.view addSubview:_compareButton];
    _compareButton.hidden=YES;
    
    //图片下载
    _downLoadButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width*35/40, self.view.bounds.size.height/20, self.view.bounds.size.width/14, self.view.bounds.size.width/14)];
    [_downLoadButton addTarget:self action:@selector(downLoadImage) forControlEvents:UIControlEventTouchDown];
    [_downLoadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    [self.view addSubview:_downLoadButton];
    _downLoadButton.hidden=YES;
    //取消编辑按钮
    _firstCancel=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/15,self.view.bounds.size.height/20 ,self.view.bounds.size.width/17, self.view.bounds.size.width/17)];
    [_firstCancel addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchDown];
    [_firstCancel setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    [self.view addSubview:_firstCancel];
    _firstCancel.hidden=YES;
    //图片裁剪
    _cutView=[[UIView alloc]init];
    _cutView.userInteractionEnabled=NO;
    _cutLayer=[CALayer layer];
    _fillLayer=[CAShapeLayer layer];
    //图片裁剪取消按钮
    _secondCancel=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/20, _importImage.bounds.size.height-self.view.bounds.size.width/10,self.view.bounds.size.width/20, self.view.bounds.size.width/20)];
    [_secondCancel setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    [self.view addSubview:_secondCancel];
    [_secondCancel addTarget:self action:@selector(cutCancel) forControlEvents:UIControlEventTouchDown];
    _secondCancel.hidden=YES;
    //图片裁剪完成按钮
    _doneCut=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width*18/20, _importImage.bounds.size.height-self.view.bounds.size.width/10, self.view.bounds.size.width/20, self.view.bounds.size.width/20)];
    [_doneCut setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
    [self.view addSubview:_doneCut];
    [_doneCut addTarget:self action:@selector(cutDone) forControlEvents:UIControlEventTouchDown];
    _doneCut.hidden=YES;
    
}
#pragma mark -scrollview del

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.importImage;
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    _currentScale=scale;
}

#pragma mark-scrollview gesture

-(void)handDoubleTap:(UIGestureRecognizer*)sender{
    if (_currentScale==_scrollView.maximumZoomScale) {
        _currentScale=_scrollView.minimumZoomScale;
        [_scrollView setZoomScale:_currentScale animated:YES];
        return;
    }
    if (_currentScale==_scrollView.minimumZoomScale) {
        _currentScale=_scrollView.maximumZoomScale;
        [_scrollView setZoomScale:_currentScale animated:YES];
        return;
    }
    CGFloat aveScale=_scrollView.minimumZoomScale+(_scrollView.maximumZoomScale-_scrollView.minimumZoomScale)/2;
    if (_currentScale>=aveScale) {
        _currentScale=_scrollView.maximumZoomScale;
        [_scrollView setZoomScale:_currentScale animated:YES];
        return;
    }
    if (_currentScale<aveScale) {
        _currentScale=_scrollView.minimumZoomScale;
        [_scrollView setZoomScale:_currentScale animated:YES];
        return;
    }
}

#pragma mark - Navigation

-(void)chooseImage{
    self.imagePicker=[[UIImagePickerController alloc]init];
    self.imagePicker.delegate=self;
    self.imagePicker.allowsEditing=YES;
    UIAlertController*actionSheet=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction*cameraAction=[UIAlertAction actionWithTitle:@"从相机拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        }
    }];
    UIAlertAction*photoAction=[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action ){
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            self.imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        }
    }];
    UIAlertAction*canceAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action ){
        NSLog(@"点击了取消");
    }];
    [actionSheet addAction:cameraAction];
    [actionSheet addAction:photoAction];
    [actionSheet addAction:canceAction];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

 -(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
     [picker dismissViewControllerAnimated:YES completion:nil];
     self.importImage.image=[info objectForKey:UIImagePickerControllerOriginalImage];
     self.resultImage.image=[info objectForKey:UIImagePickerControllerOriginalImage];
     self.tempImage.image=[info objectForKey:UIImagePickerControllerOriginalImage];
     self.importImage.contentMode=UIViewContentModeScaleAspectFit;
     [self.view addSubview:_scrollView];
     [_scrollView addSubview:self.importImage];
     [self.view bringSubviewToFront:_compareButton];
     [self.view bringSubviewToFront:_downLoadButton];
     [self.view bringSubviewToFront:_firstCancel];
     _downLoadButton.hidden=NO;
     _firstCancel.hidden=NO;
}
 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
        [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-collectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(collectionView==_collectionViewEdit){
        return 5;
    }
    if (collectionView==_collectionViewFilter) {
        return 10;
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView==self.collectionViewFilter) {
        ImageCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
        cell.imageView.image=[UIImage imageNamed:self.imagePathArray[indexPath.item]];
        return cell;
    }
    else{
        ImageCollectionViewCellEdit *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewEditCell" forIndexPath:indexPath];
        cell.imageViewEdit.image=[UIImage imageNamed:self.imagePathArrayEdit[indexPath.item]];
        [cell.labelEdit setText:self.arrayEdit[indexPath.item]];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView==self.collectionViewFilter) {
        _compareButton.hidden=NO;
        CIImage*ciImage=[[CIImage alloc]initWithImage:_tempImage.image];
        CIFilter*filter=[CIFilter filterWithName:_filterArray[indexPath.item]keysAndValues:kCIInputImageKey,ciImage, nil];
        [filter setDefaults];
        CIContext*context=[CIContext contextWithOptions:nil];
        CIImage*outputImage=[filter outputImage];
        CGImageRef cgImage=[context createCGImage:outputImage fromRect:[outputImage extent]];
        _importImage.image=[UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
    }
    if (collectionView==self.collectionViewEdit) {
        switch (indexPath.item) {
            case 0:{
                [_sliderC removeFromSuperview];
                [_sliderS removeFromSuperview];
                [_sliderH removeFromSuperview];
                [_slider removeFromSuperview];
                _downLoadButton.hidden=YES;
                _compareButton.hidden=YES;
                _firstCancel.hidden=YES;
                _doneCut.hidden=NO;
                _secondCancel.hidden=NO;
                _cutView.frame=CGRectMake(0, 0, _importImage.bounds.size.width, _importImage.bounds.size.height);
                CGFloat widthRatio=_importImage.bounds.size.width/_importImage.image.size.width;
                CGFloat heightRadio=_importImage.bounds.size.height/_importImage.image.size.height;
                CGFloat scale=MIN(widthRatio, heightRadio);
                _maskRect=CGRectMake(_importImage.bounds.size.width-_importImage.image.size.width*scale, (_importImage.bounds.size.height-_importImage.image.size.height*scale)/2, _importImage.image.size.width*scale,_importImage.image.size.height*scale);
                _innerPath=[UIBezierPath bezierPathWithRect:_maskRect];
                _outerPath=[UIBezierPath bezierPathWithRect:_cutView.bounds];
                [_outerPath appendPath:_innerPath];
                _fillLayer=[CAShapeLayer layer];
                _fillLayer.path=_outerPath.CGPath;
                _fillLayer.fillRule=kCAFillRuleEvenOdd;
                _cutView.layer.backgroundColor=[UIColor blackColor].CGColor;
                _cutView.layer.opacity=0.6;
                _cutView.layer.mask=_fillLayer;
                _cutLayer.frame=CGRectMake(_importImage.bounds.size.width-_importImage.image.size.width*scale, (_importImage.bounds.size.height-_importImage.image.size.height*scale)/2, _importImage.image.size.width*scale,_importImage.image.size.height*scale);
                _cutLayer.borderColor=[UIColor whiteColor].CGColor;
                _cutLayer.borderWidth=3;
                [self.view addSubview:_cutView];
                [self.view.layer addSublayer:_cutLayer];
                _cutLayer.hidden=NO;
                [self.view bringSubviewToFront:_secondCancel];
                [self.view bringSubviewToFront:_doneCut];
                break;
            }
            case 1:{
                _downLoadButton.hidden=NO;
                _compareButton.hidden=NO;
                _firstCancel.hidden=NO;
                _secondCancel.hidden=YES;
                _doneCut.hidden=YES;
                [_sliderC removeFromSuperview];
                [_sliderS removeFromSuperview];
                [_sliderH removeFromSuperview];
                [_cutView removeFromSuperview];
                [_cutLayer removeFromSuperlayer];
                CIImage*bImage=[[CIImage alloc]initWithImage:_importImage.image];
                _brightFilter=[CIFilter filterWithName:@"CIColorControls"];
                [_brightFilter setValue:bImage forKey:kCIInputImageKey];
                [self.view addSubview:_slider];
                
                _slider.minimumValue=-1.0;
                _slider.maximumValue=1.0;
                [_slider addTarget:self action:@selector(updateBrightValue:) forControlEvents:UIControlEventValueChanged];
                break;
            }
            case 2:{
                _downLoadButton.hidden=NO;
                _compareButton.hidden=NO;
                _firstCancel.hidden=NO;
                _secondCancel.hidden=YES;
                _doneCut.hidden=YES;
                [_slider removeFromSuperview];
                [_sliderS removeFromSuperview];
                [_sliderH removeFromSuperview];
                [_cutView removeFromSuperview];
                [_cutLayer removeFromSuperlayer];
                CIImage*bImage=[[CIImage alloc]initWithImage:_importImage.image];
                _contrastFilter=[CIFilter filterWithName:@"CIColorControls"];
                [_contrastFilter setValue:bImage forKey:kCIInputImageKey];
                [self.view addSubview:_sliderC];
                
                _sliderC.minimumValue=0;
                _sliderC.maximumValue=4;
 
                [_sliderC addTarget:self action:@selector(updateContrastValue:) forControlEvents:UIControlEventValueChanged];
                break;
            }
            case 3:{
                _downLoadButton.hidden=NO;
                _compareButton.hidden=NO;
                _firstCancel.hidden=NO;
                _secondCancel.hidden=YES;
                _doneCut.hidden=YES;
                [_sliderC removeFromSuperview];
                [_slider removeFromSuperview];
                [_sliderH removeFromSuperview];
                [_cutView removeFromSuperview];
                [_cutLayer removeFromSuperlayer];
                CIImage*bImage=[[CIImage alloc]initWithImage:_importImage.image];
                _saturationFilter=[CIFilter filterWithName:@"CIColorControls"];
                [_saturationFilter setValue:bImage forKey:kCIInputImageKey];
                [self.view addSubview:_sliderS];
                
                _sliderS.minimumValue=0;
                _sliderS.maximumValue=2;
                [_sliderS addTarget:self action:@selector(updateSaturationValue:) forControlEvents:UIControlEventValueChanged];
                break;
            }
            case 4:{
                _downLoadButton.hidden=NO;
                _compareButton.hidden=NO;
                _firstCancel.hidden=NO;
                _secondCancel.hidden=YES;
                _doneCut.hidden=YES;
                [_sliderC removeFromSuperview];
                [_sliderS removeFromSuperview];
                [_slider removeFromSuperview];
                [_cutView removeFromSuperview];
                [_cutLayer removeFromSuperlayer];

                break;
            }
            default:
                break;
        }
    }
}

-(void)updateBrightValue:(UISlider*)slider{
    [_brightFilter setValue:@(slider.value) forKey:kCIInputBrightnessKey];
    CIImage* imageBrightOut=[_brightFilter outputImage];
    CIContext*contextB=[CIContext contextWithOptions:nil];
    CGImageRef outBImage=[contextB createCGImage:imageBrightOut fromRect:[imageBrightOut extent]];
    _importImage.image=[UIImage imageWithCGImage:outBImage];
    _tempImage.image=[UIImage imageWithCGImage:outBImage];
    CGImageRelease(outBImage);
}
-(void)updateContrastValue:(UISlider*)slider{
    [_contrastFilter setValue:@(slider.value) forKey:kCIInputContrastKey];
    CIImage* imageBrightOut=[_contrastFilter outputImage];
    CIContext*contextC=[CIContext contextWithOptions:nil];
    CGImageRef outBImage=[contextC createCGImage:imageBrightOut fromRect:[imageBrightOut extent]];
    _importImage.image=[UIImage imageWithCGImage:outBImage];
    _tempImage.image=[UIImage imageWithCGImage:outBImage];
    CGImageRelease(outBImage);
}
-(void)updateSaturationValue:(UISlider*)slider{
    [_saturationFilter setValue:@(slider.value) forKey:kCIInputSaturationKey];
    CIImage* imageBrightOut=[_saturationFilter outputImage];
    CIContext*contextC=[CIContext contextWithOptions:nil];
    CGImageRef outBImage=[contextC createCGImage:imageBrightOut fromRect:[imageBrightOut extent]];
    _importImage.image=[UIImage imageWithCGImage:outBImage];
    _tempImage.image=[UIImage imageWithCGImage:outBImage];
    CGImageRelease(outBImage);
}
-(void)updateHeightBrightValue:(UISlider*)slider{
}
#pragma mark-bottomButton

-(void)showFilter{
    _downLoadButton.hidden=NO;
    _compareButton.hidden=NO;
    _firstCancel.hidden=NO;
    _secondCancel.hidden=YES;
    _doneCut.hidden=YES;
    [_sliderC removeFromSuperview];
    [_sliderS removeFromSuperview];
    [_sliderH removeFromSuperview];
    [_slider removeFromSuperview];
    [_cutView removeFromSuperview];
    [_cutLayer removeFromSuperlayer];
    [_editButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    UIColor*gy=[[UIColor alloc]initWithRed:0.8 green:1.0 blue:0.6 alpha:1];
    [_filterButton setTitleColor:gy forState:UIControlStateNormal];
    _collectionViewEdit.hidden=YES;
    _collectionViewFilter.hidden=NO;
}
-(void)showEdit{
    [_filterButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    UIColor*gy=[[UIColor alloc]initWithRed:0.8 green:1.0 blue:0.6 alpha:1];
    [_editButton setTitleColor:gy forState:UIControlStateNormal];
    _collectionViewFilter.hidden=YES;
    _collectionViewEdit.hidden=NO;
}
-(void)showOldImage{
    
    [self.view addSubview:_resultImage];
    _resultImage.contentMode=UIViewContentModeScaleAspectFit;
    [self.view bringSubviewToFront:_compareButton];
    [self.view bringSubviewToFront:_downLoadButton];
    [self.view bringSubviewToFront:_firstCancel];
    _importImage.hidden=YES;
}
-(void)hiddeOldImage{
    [_resultImage removeFromSuperview];
    _importImage.hidden=NO;
}
-(void)downLoadImage{
    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:self.importImage.image];
    } completionHandler:^(BOOL success,NSError* _Nullable error){
        NSLog(@"success = %d, error = %@", success, error);
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    _touchPoint=[touch locationInView:[touch view]];
    CGFloat clx=_cutLayer.frame.origin.x;
    CGFloat cly=_cutLayer.frame.origin.y;
    CGFloat cLW=_cutLayer.frame.size.width;
    CGFloat cLH=_cutLayer.frame.size.height;
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        if(_touchPoint.x>=clx-10&&_touchPoint.x<=clx+10&&_touchPoint.y>=cly-10&&_touchPoint.y<=cly+10)
        {
            return YES;
        }
        if (_touchPoint.x>=clx+cLW-10&&_touchPoint.x<=clx+cLW+10&&_touchPoint.y>=cly-10&&_touchPoint.y<=cly+10) {
            return YES;
        }
        if(_touchPoint.x>=clx-10&&_touchPoint.x<=clx+10&&_touchPoint.y>=cly+cLH-10&&_touchPoint.y<=cly+cLH+10){
            return YES;
        }
        if (_touchPoint.x>=clx+cLW-10&&_touchPoint.x<=clx+cLW+10&&_touchPoint.y>=cly+cLH-10&&_touchPoint.y<=cly+cLH+10) {
            return YES;
        }
    }
    return NO;
}

-(void)changeSize:(UIPanGestureRecognizer*)pan{
    CGPoint layerSizeChange=[pan translationInView:self.view];
//    CGFloat clx=_cutLayer.frame.origin.x;
//    CGFloat cly=_cutLayer.frame.origin.y;
//    CGFloat cLW=_cutLayer.frame.size.width;
//    CGFloat cLH=_cutLayer.frame.size.height;
    if(_touchPoint.x>=_cutLayer.frame.origin.x-10&&_touchPoint.x<=_cutLayer.frame.origin.x+10&&_touchPoint.y>=_cutLayer.frame.origin.y-10&&_touchPoint.y<=_cutLayer.frame.origin.y+10){
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _cutLayer.frame=CGRectMake(_cutLayer.frame.origin.x+layerSizeChange.x, _cutLayer.frame.origin.y+layerSizeChange.y, _cutLayer.frame.size.width-layerSizeChange.x,_cutLayer.frame.size.height-layerSizeChange.y);
        [CATransaction commit];
        _maskRect=CGRectMake(_cutLayer.frame.origin.x+layerSizeChange.x, _cutLayer.frame.origin.y+layerSizeChange.y, _cutLayer.frame.size.width-layerSizeChange.x,_cutLayer.frame.size.height-layerSizeChange.y);
        _innerPath=[UIBezierPath bezierPathWithRect:_maskRect];
        _outerPath=[UIBezierPath bezierPathWithRect:_cutView.bounds];
        [_outerPath appendPath:_innerPath];
        _fillLayer.path=_outerPath.CGPath;
        _fillLayer.fillRule=kCAFillRuleEvenOdd;
        _touchPoint.x=_cutLayer.frame.origin.x;
        _touchPoint.y=_cutLayer.frame.origin.y;
        [pan setTranslation:CGPointZero inView:self.view];
    }
    else if (_touchPoint.x>=_cutLayer.frame.origin.x+_cutLayer.frame.size.width-10&&_touchPoint.x<=_cutLayer.frame.origin.x+_cutLayer.frame.size.width+10&&_touchPoint.y>=_cutLayer.frame.origin.y-10&&_touchPoint.y<=_cutLayer.frame.origin.y+10) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _cutLayer.frame=CGRectMake(_cutLayer.frame.origin.x, _cutLayer.frame.origin.y+layerSizeChange.y, _cutLayer.frame.size.width+layerSizeChange.x,_cutLayer.frame.size.height-layerSizeChange.y);
        [CATransaction commit];
        _maskRect=CGRectMake(_cutLayer.frame.origin.x, _cutLayer.frame.origin.y+layerSizeChange.y, _cutLayer.frame.size.width+layerSizeChange.x,_cutLayer.frame.size.height-layerSizeChange.y);
        _innerPath=[UIBezierPath bezierPathWithRect:_maskRect];
        _outerPath=[UIBezierPath bezierPathWithRect:_cutView.bounds];
        [_outerPath appendPath:_innerPath];
        _fillLayer.path=_outerPath.CGPath;
        _fillLayer.fillRule=kCAFillRuleEvenOdd;
        _touchPoint.x=_cutLayer.frame.origin.x+_cutLayer.frame.size.width;
        _touchPoint.y=_cutLayer.frame.origin.y;
        [pan setTranslation:CGPointZero inView:self.view];
    }
    else if(_touchPoint.x>=_cutLayer.frame.origin.x-10&&_touchPoint.x<=_cutLayer.frame.origin.x+10&&_touchPoint.y>=_cutLayer.frame.origin.y+_cutLayer.frame.size.height-10&&_touchPoint.y<=_cutLayer.frame.origin.y+_cutLayer.frame.size.height+10){
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _cutLayer.frame=CGRectMake(_cutLayer.frame.origin.x+layerSizeChange.x, _cutLayer.frame.origin.y, _cutLayer.frame.size.width-layerSizeChange.x,_cutLayer.frame.size.height+layerSizeChange.y);
        [CATransaction commit];
        _maskRect=CGRectMake(_cutLayer.frame.origin.x+layerSizeChange.x, _cutLayer.frame.origin.y, _cutLayer.frame.size.width-layerSizeChange.x,_cutLayer.frame.size.height+layerSizeChange.y);
        _innerPath=[UIBezierPath bezierPathWithRect:_maskRect];
        _outerPath=[UIBezierPath bezierPathWithRect:_cutView.bounds];
        [_outerPath appendPath:_innerPath];
        _fillLayer.path=_outerPath.CGPath;
        _fillLayer.fillRule=kCAFillRuleEvenOdd;
        _touchPoint.x=_cutLayer.frame.origin.x;
        _touchPoint.y=_cutLayer.frame.origin.y+_cutLayer.frame.size.height;
        [pan setTranslation:CGPointZero inView:self.view];
    }
    else if (_touchPoint.x>=_cutLayer.frame.origin.x+_cutLayer.frame.size.width-10&&_touchPoint.x<=_cutLayer.frame.origin.x+_cutLayer.frame.size.width+10&&_touchPoint.y>=_cutLayer.frame.origin.y+_cutLayer.frame.size.height-10&&_touchPoint.y<=_cutLayer.frame.origin.y+_cutLayer.frame.size.height+10) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _cutLayer.frame=CGRectMake(_cutLayer.frame.origin.x, _cutLayer.frame.origin.y, _cutLayer.frame.size.width+layerSizeChange.x,_cutLayer.frame.size.height+layerSizeChange.y);
        [CATransaction commit];
        _maskRect=CGRectMake(_cutLayer.frame.origin.x, _cutLayer.frame.origin.y, _cutLayer.frame.size.width+layerSizeChange.x,_cutLayer.frame.size.height+layerSizeChange.y);
        _innerPath=[UIBezierPath bezierPathWithRect:_maskRect];
        _outerPath=[UIBezierPath bezierPathWithRect:_cutView.bounds];
        [_outerPath appendPath:_innerPath];
        _fillLayer.path=_outerPath.CGPath;
        _fillLayer.fillRule=kCAFillRuleEvenOdd;
        _touchPoint.x=_cutLayer.frame.origin.x+_cutLayer.frame.size.width;
        _touchPoint.y=_cutLayer.frame.origin.y+_cutLayer.frame.size.height;
        [pan setTranslation:CGPointZero inView:self.view];
    }
}

-(void)cutCancel{
    _doneCut.hidden=YES;
    _secondCancel.hidden=YES;
    _cutLayer.hidden=YES;
    _downLoadButton.hidden=NO;
    _compareButton.hidden=NO;
    _firstCancel.hidden=NO;
   [_cutView removeFromSuperview];
}
-(void)cutDone{
    CGFloat widthRatio=_importImage.bounds.size.width/_importImage.image.size.width;
    CGFloat heightRadio=_importImage.bounds.size.height/_importImage.image.size.height;
    CGFloat scale=MIN(widthRatio, heightRadio);
    CIImage*sImage=[[CIImage alloc]initWithImage:_importImage.image];
    CGImageRef sourceImage=[sImage CGImage];
    CGRect cutRect=CGRectMake((_cutLayer.frame.origin.x-(_importImage.frame.size.width-_importImage.image.size.width*scale)/2)/scale, (_cutLayer.frame.origin.y-(_importImage.frame.size.height-_importImage.image.size.height*scale)/2)/scale, _cutLayer.frame.size.width/scale, _cutLayer.frame.size.height/scale);
    CGImageRef tempImage=CGImageCreateWithImageInRect(sourceImage, cutRect);
    UIImage *cutImage=[UIImage imageWithCGImage:tempImage];
    _importImage.image=cutImage;
    _tempImage.image=cutImage;
    _doneCut.hidden=YES;
     _secondCancel.hidden=YES;
     _cutLayer.hidden=YES;
     _downLoadButton.hidden=NO;
     _compareButton.hidden=NO;
     _firstCancel.hidden=NO;
    [_cutView removeFromSuperview];
    CGImageRelease(sourceImage);
    CGImageRelease(tempImage);
}
@end
