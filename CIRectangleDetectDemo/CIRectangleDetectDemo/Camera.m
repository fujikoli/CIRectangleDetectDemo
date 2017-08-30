//
//  Camera.m
//  CIRectangleDetectDemo
//
//  Created by fujikoli(李鑫) on 2017/8/29.
//  Copyright © 2017年 fujikoli(李鑫). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Camera.h"

@implementation Camera

- (id)init
{
    if ((self = [super init]))
    {
        [self setCaptureSession:[[AVCaptureSession alloc] init]];
        _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    }
    return self;
}

- (void)addVideoPreviewLayer
{
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (void)addVideoInputFromCamera
{
    self.device = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] firstObject];
    NSError *error = nil;
    AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (!error)
    {
        if ([_captureSession canAddInput:backFacingCameraDeviceInput])
        {
            [_captureSession addInput:backFacingCameraDeviceInput];
        }
    }
}

- (void)addVideoOutput{
    [self setOutput:[[AVCaptureVideoDataOutput alloc]init]];
    [_output setAlwaysDiscardsLateVideoFrames:YES];
    [_output setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}];
    if([_captureSession canAddOutput:_output]){
        [_captureSession addOutput:_output];
    }
}

//- (void)addStillImageOutput
//{
//    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
//    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
//    [[self stillImageOutput] setOutputSettings:outputSettings];
//    
//    AVCaptureConnection *videoConnection = nil;
//    
//    for (AVCaptureConnection *connection in [_stillImageOutput connections])
//    {
//        for (AVCaptureInputPort *port in [connection inputPorts])
//        {
//            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
//            {
//                videoConnection = connection;
//                break;
//            }
//        }
//        if (videoConnection)
//        {
//            break;
//        }
//    }
//    [_captureSession addOutput:[self stillImageOutput]];
//}

//- (void)captureStillImage
//{
//    AVCaptureConnection *videoConnection = nil;
//    for (AVCaptureConnection *connection in [[self stillImageOutput] connections])
//    {
//        for (AVCaptureInputPort *port in [connection inputPorts])
//        {
//            if ([[port mediaType] isEqual:AVMediaTypeVideo])
//            {
//                videoConnection = connection;
//                break;
//            }
//        }
//        
//        if (videoConnection)
//        {
//            break;
//        }
//    }
//    
//    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
//                                                   completionHandler:
//     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
//         
//         if (imageSampleBuffer)
//         {
//             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
//             UIImage *image = [[UIImage alloc] initWithData:imageData];
//             [self setStillImage:image];
//             
//             [[NSNotificationCenter defaultCenter] postNotificationName:@"imageCapturedSuccessfully" object:nil];
//         }
//     }];
//}

- (void)dealloc {
    
    [[self captureSession] stopRunning];
    
    _previewLayer = nil;
    _captureSession = nil;
//    _stillImageOutput = nil;
    _stillImage = nil;
    _output = nil;
}

@end
