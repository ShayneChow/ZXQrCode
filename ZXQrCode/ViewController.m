//
//  ViewController.m
//  ZXQrCode
//
//  Created by Xiang on 16/4/20.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)generateQrCode:(id)sender {
    if (self.textField.text.length != 0) {
        NSLog(@"%@", self.textField.text);
        ///生成二维码,原生态生成二维码需要导入CoreImage.framework
        //二维码滤镜
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        //恢复滤镜的默认属性
        [filter setDefaults];
        //*****************************************************************//
        //如果是从外界传递来的字符串这里将外界传递来的字符串转换为data即可.
        //*****************************************************************//
        
        //字符串转换为data
        NSData *data = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding];
        //通过KVO设置滤镜inputmessage数据
        [filter setValue:data forKey:@"inputMessage"];
        //获得滤镜输出的图像
        CIImage *outPutImage = [filter outputImage];
        //将CIImage转换成UImage并展示
        self.qrCodeImageView.image = [self createNonInterpolatedUIImageFormCIImage:outPutImage withSize:200.0];
        self.qrCodeImageView.contentMode = UIViewContentModeScaleToFill;

    } else {
        ///为空不生成
    }
}

///将数据转换为二维码图片
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
