//
//  DetectViewController.m
//  CIRectangleDetectDemo
//
//  Created by fujikoli(李鑫) on 2017/8/29.
//  Copyright © 2017年 fujikoli(李鑫). All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import "DetectViewController.h"

@interface Feature : NSObject

@property (nonatomic) CGPoint topLeft;
@property (nonatomic) CGPoint topRight;
@property (nonatomic) CGPoint bottomRight;
@property (nonatomic) CGPoint bottomLeft;

@end @implementation Feature @end


@implementation DetectViewController

- (void)viewDidLoad
{
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    if (_sourceTypeCamera == true && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        
        self.cameraView = [[UIView alloc] init];
        self.cameraView.backgroundColor = [UIColor blackColor];
        self.cameraView.frame = self.view.bounds;
        [self.view addSubview:self.cameraView];
        
        self.rectView = [[RectView alloc] init];
        self.rectView.frame = self.cameraView.frame;
        self.rectView.hidden = NO;
        [self.view addSubview:self.rectView];
        
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
        [self.view addGestureRecognizer:_tapGesture];
        
        _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        _focusView.layer.borderWidth = 1.0;
        _focusView.layer.borderColor =[UIColor greenColor].CGColor;
        _focusView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_focusView];
        _focusView.hidden = YES;
        
        [self setCaptureManager:[[Camera alloc] init]];
        [_captureManager addVideoInputFromCamera];
//        [_captureManager addStillImageOutput];
        [_captureManager addVideoOutput];
        dispatch_queue_t queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
        [_captureManager.output setSampleBufferDelegate:self queue:queue];
        [_captureManager addVideoPreviewLayer];
        
        _captureManager.previewLayer.frame = _cameraView.bounds;
        [_cameraView.layer addSublayer:_captureManager.previewLayer];
        
        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissController)];
        [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
        [self.view addGestureRecognizer:swipeDown];
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(self.view.bounds.size.width*1/4, self.view.bounds.size.height-100, 60, 60);
        [_cancelButton setImage:[UIImage imageNamed:@"close-button"] forState: UIControlStateNormal];
        _cancelButton.accessibilityLabel = @"Close Camera Viewer";
        [_cancelButton addTarget:self action:@selector(dismissController) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_cancelButton];
        
    }else {
        
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_sourceTypeCamera == true && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [_cancelButton setEnabled:YES];
        [[_captureManager captureSession] startRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_sourceTypeCamera == true && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [[_captureManager captureSession] stopRunning];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissController];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _captureManager = nil;
}

- (void)dismissController
{
    [self removeNotificationObservers];
    if (_sourceTypeCamera == true && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [[_captureManager captureSession] stopRunning];
        
    }
    else
    {
        
    }
    [_delegate imagePickerDidCancel];
}


- (void)removeNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)startOverlayHideTimer
{
    if(borderDetectKeeper) {
        [borderDetectKeeper invalidate];
    }
    
    borderDetectKeeper = [NSTimer scheduledTimerWithTimeInterval:0.06
                                                          target:self
                                                        selector:@selector(removeBoundingBox:)
                                                        userInfo:nil
                                                         repeats:NO];
}

- (void)removeBoundingBox:(id)sender
{
    _rectView.hidden = YES;
}

- (void)dismissPreview:(UITapGestureRecognizer *)dismissTap
{
    [self.view addGestureRecognizer:_tapGesture];
    [[_captureManager captureSession] startRunning];
    [_cancelButton setEnabled:YES];
    _cancelButton.alpha = 1;
}

- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([_captureManager.device lockForConfiguration:&error]) {
        if ([_captureManager.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [_captureManager.device setFocusPointOfInterest:focusPoint];
            [_captureManager.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        [_captureManager.device unlockForConfiguration];
    }
    _focusView.center = point;
    _focusView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            _focusView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            _focusView.hidden = YES;
        }];
    }];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

    @autoreleasepool{
        
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        CIImage *image = [CIImage imageWithCVPixelBuffer:imageBuffer];
        
        CIFilter *transform = [CIFilter filterWithName:@"CIAffineTransform"];
        [transform setValue:image forKey:kCIInputImageKey];
        NSValue *rotation = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(-90 * (M_PI/180))];
        
        [transform setValue:rotation forKey:@"inputTransform"];
        image = [transform outputImage];
        
        CIRectangleFeature *rectangleFeature = [self biggestRectangleInRectangles:[[self highAccuracyRectangleDetector] featuresInImage:image]];
        
        CGRect previewRect = _cameraView.frame;
        CGRect imageRect = image.extent;
        
        CGFloat deltaX = CGRectGetWidth(previewRect)/CGRectGetWidth(imageRect);
        CGFloat deltaY = CGRectGetHeight(previewRect)/CGRectGetHeight(imageRect);
        
        //将坐标沿着y轴对称过去
        CGAffineTransform transform2 = CGAffineTransformMakeTranslation(0.f, CGRectGetHeight(previewRect));
        transform2 = CGAffineTransformScale(transform2, 1, -1);
        
        //按照cameraview的scale调整
        transform2 = CGAffineTransformScale(transform2, deltaX, deltaY);
        
        CGPoint points[4];
        points[0] = CGPointApplyAffineTransform(rectangleFeature.topLeft, transform2);
        points[1] = CGPointApplyAffineTransform(rectangleFeature.topRight, transform2);
        points[2] = CGPointApplyAffineTransform(rectangleFeature.bottomRight, transform2);
        points[3] = CGPointApplyAffineTransform(rectangleFeature.bottomLeft, transform2);
        
        if(rectangleFeature){
            _rectView.hidden = NO;
            [_rectView drawWithPointsfirst:points[0]
                                    second:points[1]
                                     thrid:points[2]
                                     forth:points[3]];
        }
        
    }
    
    //更新视图
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.rectView setNeedsDisplay];
        [self startOverlayHideTimer];
    });
    
}

- (CIDetector *)highAccuracyRectangleDetector
{
    static CIDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
                  });
    return detector;
}

- (CIRectangleFeature *)_biggestRectangleInRectangles:(NSArray *)rectangles
{
    if (![rectangles count]) return nil;
    
    float halfPerimiterValue = 0;
    
    CIRectangleFeature *biggestRectangle = [rectangles firstObject];
    
    for (CIRectangleFeature *rect in rectangles)
    {
        CGPoint p1 = rect.topLeft;
        CGPoint p2 = rect.topRight;
        CGFloat width = hypotf(p1.x - p2.x, p1.y - p2.y);
        
        CGPoint p3 = rect.topLeft;
        CGPoint p4 = rect.bottomLeft;
        CGFloat height = hypotf(p3.x - p4.x, p3.y - p4.y);
        
        CGFloat currentHalfPerimiterValue = height + width;
        
        if (halfPerimiterValue < currentHalfPerimiterValue)
        {
            halfPerimiterValue = currentHalfPerimiterValue;
            biggestRectangle = rect;
        }
    }
    
    return biggestRectangle;
}

- (CIRectangleFeature *)biggestRectangleInRectangles:(NSArray *)rectangles
{
    CIRectangleFeature *rectangleFeature = [self _biggestRectangleInRectangles:rectangles];
    if (!rectangleFeature) return nil;
    
    NSArray *points = @[[NSValue valueWithCGPoint:rectangleFeature.topLeft],[NSValue valueWithCGPoint:rectangleFeature.topRight],[NSValue valueWithCGPoint:rectangleFeature.bottomLeft],[NSValue valueWithCGPoint:rectangleFeature.bottomRight]];
    
    CGPoint min = [points[0] CGPointValue];
    CGPoint max = min;
    for (NSValue *value in points)
    {
        CGPoint point = [value CGPointValue];
        min.x = fminf(point.x, min.x);
        min.y = fminf(point.y, min.y);
        max.x = fmaxf(point.x, max.x);
        max.y = fmaxf(point.y, max.y);
    }
    
    CGPoint center =
    {
        0.5f * (min.x + max.x),
        0.5f * (min.y + max.y),
    };
    
    NSNumber *(^angleFromPoint)(id) = ^(NSValue *value)
    {
        CGPoint point = [value CGPointValue];
        CGFloat theta = atan2f(point.y - center.y, point.x - center.x);
        CGFloat angle = fmodf(M_PI - M_PI_4 + theta, 2 * M_PI);
        return @(angle);
    };
    
    NSArray *sortedPoints = [points sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                             {
                                 return [angleFromPoint(a) compare:angleFromPoint(b)];
                             }];
    
    Feature *featureMutable = [Feature new];
    featureMutable.topLeft = [sortedPoints[3] CGPointValue];
    featureMutable.topRight = [sortedPoints[2] CGPointValue];
    featureMutable.bottomRight = [sortedPoints[1] CGPointValue];
    featureMutable.bottomLeft = [sortedPoints[0] CGPointValue];
    
    return (id)featureMutable;
}

//- (CIImage *)correctPerspectiveForImage:(CIImage *)image withFeatures:(CIRectangleFeature *)rectangleFeature
//{
//    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
//    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.topLeft];
//    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:rectangleFeature.topRight];
//    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomLeft];
//    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomRight];
//    return [image imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
//}

@end
