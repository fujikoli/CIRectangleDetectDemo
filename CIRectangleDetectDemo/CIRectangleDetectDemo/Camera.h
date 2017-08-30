//
//  Camera.h
//  CIRectangleDetectDemo
//
//  Created by fujikoli(李鑫) on 2017/8/29.
//  Copyright © 2017年 fujikoli(李鑫). All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface Camera : NSObject

@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
//@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureVideoDataOutput *output;
@property (strong, nonatomic) UIImage *stillImage;

- (void)addVideoPreviewLayer;
//- (void)addStillImageOutput;
//- (void)captureStillImage;
- (void)addVideoInputFromCamera;
- (void)addVideoOutput;

@end

