//
//  ZXScanViewController.m
//  ZXQrCode
//
//  Created by Xiang on 16/4/20.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "ZXScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZXResultViewController.h"

#define XCenter self.view.center.x
#define YCenter self.view.center.y

#define SHeight 20
#define SWidth (XCenter + 30)

#define ZXScreenW [UIScreen mainScreen].bounds.size.width
#define ZXScreenH [UIScreen mainScreen].bounds.size.height

@interface ZXScanViewController ()<AVCaptureMetadataOutputObjectsDelegate> {
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    UIImageView * imageView;
}

@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureMetadataOutput *output;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, retain) UIImageView *line;

@end

@implementation ZXScanViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [_session startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    self.view.backgroundColor = [UIColor whiteColor];
    
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake((ZXScreenW - SWidth)/2, (ZXScreenH - SWidth)/2,SWidth, SWidth)];
    imageView.image = [UIImage imageNamed:@"scan_window"];
    [self.view addSubview:imageView];
    
    upOrdown = NO;
    num = 0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(imageView.frame) + 5, CGRectGetMinY(imageView.frame) + 5, SWidth - 10, 1)];
    _line.image = [UIImage imageNamed:@"scan_line"];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    [self setupCamera];
}

- (CGRect)rectOfInterestByScanViewRect:(CGRect)rect {
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    CGFloat x = (height - CGRectGetHeight(rect)) / 2 / height;
    CGFloat y = (width - CGRectGetWidth(rect)) / 2 / width;
    
    CGFloat w = CGRectGetHeight(rect) / height;
    CGFloat h = CGRectGetWidth(rect) / width;
    
    return CGRectMake(x, y, w, h);
}

#pragma mark - 添加模糊效果
- (void)setOverView {
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    CGFloat x = CGRectGetMinX(imageView.frame);
    CGFloat y = CGRectGetMinY(imageView.frame);
    CGFloat w = CGRectGetWidth(imageView.frame);
    CGFloat h = CGRectGetHeight(imageView.frame);
    
    [self creatView:CGRectMake(0, 0, width, y)];
    [self creatView:CGRectMake(0, y, x, h)];
    [self creatView:CGRectMake(0, y + h, width, height - y - h)];
    [self creatView:CGRectMake(x + w, y, width - x - w, h)];
    
}

- (void)creatView:(CGRect)rect {
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.45;
    [self.view addSubview:view];
}

#pragma mark - Camera

- (void)animation1 {
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(CGRectGetMinX(imageView.frame)+5, CGRectGetMinY(imageView.frame)+5+2*num, SWidth-10,1);
        
        if (num ==(int)(( SWidth-10)/2)) {
            upOrdown = YES;
        }
    } else {
        num --;
        _line.frame =CGRectMake(CGRectGetMinX(imageView.frame)+5, CGRectGetMinY(imageView.frame)+5+2*num, SWidth-10,1);
        
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}

- (void)setupCamera {
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _output.rectOfInterest =[self rectOfInterestByScanViewRect:imageView.frame];//CGRectMake(0.1, 0, 0.9, 1);//
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input]) {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output]) {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode];
    
    
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResize;
    _preview.frame =self.view.bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    [self.view bringSubviewToFront:imageView];
    
    [self setOverView];
    
    // Start
    //[_session startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    ///系统处于铃声模式下扫描到结果会调用"卡擦"声音;
    AudioServicesPlaySystemSound(1305);
    ///系统处于震动模式扫描到结果会震动一下;
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        /**
         *  获取扫描结果
         */
        stringValue = metadataObject.stringValue;
    }
    // 跳转到结果页
    ZXResultViewController *resultVC = [[ZXResultViewController alloc] init];
    resultVC.result = stringValue;
    [self.navigationController pushViewController:resultVC animated:YES];
    
    [_session stopRunning];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
