//
//  DetectViewController.h
//  CIRectangleDetectDemo
//
//  Created by fujikoli(李鑫) on 2017/8/29.
//  Copyright © 2017年 fujikoli(李鑫). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Camera.h"
#import "RectView.h"

@protocol ImagePickerControllerDelegate <NSObject>

@required

- (void)imagePickerDidCancel;

@end

@interface DetectViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>
{
    NSTimer *borderDetectKeeper;
}

@property (nonatomic,assign) id<ImagePickerControllerDelegate> delegate;
@property (nonatomic, strong) Camera *captureManager;
@property (nonatomic, strong) RectView *rectView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) UIView *focusView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property BOOL sourceTypeCamera;

@end
