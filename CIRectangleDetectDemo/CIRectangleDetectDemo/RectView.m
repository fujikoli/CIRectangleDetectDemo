//
//  RectView.m
//  CIRectangleDetectDemo
//
//  Created by fujikoli(李鑫) on 2017/8/29.
//  Copyright © 2017年 fujikoli(李鑫). All rights reserved.
//

#import "RectView.h"

@implementation RectView

- (instancetype)init {
    if(self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect;
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context)
    {
        CGContextMoveToPoint(context, _point1.x, _point1.y);
        CGContextAddLineToPoint(context, _point2.x, _point2.y);
        CGContextAddLineToPoint(context, _point3.x, _point3.y);
        CGContextAddLineToPoint(context, _point4.x, _point4.y);
        CGContextAddLineToPoint(context, _point1.x, _point1.y);
        CGContextSetRGBStrokeColor(context, 83 /255.0, 239/255.0, 111/255.0, 1);//green
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineWidth(context, 3.0f);
        CGContextStrokePath(context);
    }
}

- (void)drawWithPointsfirst:(CGPoint)point1 second:(CGPoint)point2 thrid:(CGPoint)point3 forth:(CGPoint)point4 {
    _point1 = point1;
    _point2 = point2;
    _point3 = point3;
    _point4 = point4;
}

@end
