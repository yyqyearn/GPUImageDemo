//
//  ViewController.m
//  imageTest
//
//  Created by Yongqi on 15/6/4.
//  Copyright (c) 2015年 Yongqi. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"

typedef NS_ENUM(NSInteger,FilterType) {
    FilterTypeBrightness = 0,
    FilterTypeContrast = 1,
};

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) UIButton *selectedBtn;


/** 图片输出View */
@property (weak, nonatomic) IBOutlet GPUImageView *outImageView;

/** 加工图片 */
@property (strong, nonatomic) GPUImagePicture *sourceImage;

/** 图片加工通道 */
@property (strong, nonatomic) GPUImageFilterPipeline *pipeLine;

/** 当前所用滤镜 */
@property (strong, nonatomic) GPUImageOutput *filterTool;

/** 所有滤镜集合 */
@property (strong, nonatomic) NSArray *filtersArray;

/** 当前所使用的滤镜类型 */
@property (assign, nonatomic) FilterType filterType;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFilters];
}

- (void)setupFilters
{
    //1.存入图片
    UIImage *image = [UIImage imageNamed:@"IMG_2041"];
    self.sourceImage = [[GPUImagePicture alloc]initWithImage:image];
    [self.sourceImage addTarget:self.outImageView];
    
    //2.创建滤镜
    self.filterTool = [[GPUImageOutput alloc]init];
    [self.filterTool addTarget:self.outImageView];
    
    GPUImageBrightnessFilter *briFilter = [[GPUImageBrightnessFilter alloc]init];
    [briFilter addTarget:self.outImageView];
    GPUImageContrastFilter *conFilter = [[GPUImageContrastFilter alloc]init];
    [conFilter addTarget:self.outImageView];
    
    self.filtersArray = @[briFilter,conFilter];
    
    //3.设置通道
    self.pipeLine = [[GPUImageFilterPipeline alloc]initWithOrderedFilters:self.filtersArray input:self.sourceImage output:self.outImageView];
   
    //4.初始化输出
    [self.sourceImage processImage];
    
}

- (IBAction)filterClick:(UIButton *)sender {
    self.selectedBtn.selected = NO;
    sender.selected = YES;
    self.selectedBtn = sender;
    self.slider.enabled = YES;
    
    if (sender.tag == FilterTypeBrightness) {
        NSLog(@"选中了了Brightness按钮");

        self.filterType = FilterTypeBrightness;
        self.filterTool = self.filtersArray[self.filterType];
    }else if (sender.tag == FilterTypeContrast){
        NSLog(@"选中了了Contrast按钮");
        
        self.filterType = FilterTypeContrast;
        self.filterTool = self.filtersArray[self.filterType];
    }

}

- (IBAction)sliderChange:(UISlider *)sender {
    if (self.filterType == FilterTypeBrightness) {
        [(GPUImageBrightnessFilter*)self.filterTool setBrightness:sender.value];
        [self.sourceImage processImage];
    }else if (self.filterType == FilterTypeContrast){
        [(GPUImageContrastFilter*)self.filterTool setContrast:sender.value];
        [self.sourceImage processImage];
    }
}



- (IBAction)saveClick:(UIButton *)sender {
    if (!sender.tag) {
        NSLog(@"点击了取消");
        UIImage *image = [UIImage imageNamed:@"IMG_2041"];
        self.bgImageView.image = image;
        return;
    }
    NSLog(@"点击了保存");
    
    [self.filterTool useNextFrameForImageCapture];
    [self.sourceImage processImage];
    UIImage *image = [self.pipeLine currentFilteredFrame];
    if (image) {
        self.bgImageView.image = image;
    }else{
        NSLog(@"没有图片");
    }

}


@end
