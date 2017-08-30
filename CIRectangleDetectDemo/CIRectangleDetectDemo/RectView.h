//
//  RectView.h
//  CIRectangleDetectDemo
//
//  Created by fujikoli(李鑫) on 2017/8/29.
//  Copyright © 2017年 fujikoli(李鑫). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RectView : UIView

@property (atomic) CGPoint point1;
@property (atomic) CGPoint point2;
@property (atomic) CGPoint point3;
@property (atomic) CGPoint point4;

- (void)drawWithPointsfirst:(CGPoint)point1 second:(CGPoint)point2 thrid:(CGPoint)point3 forth:(CGPoint)point4;

@end
