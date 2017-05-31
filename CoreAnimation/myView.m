//
//  myView.m
//  CoreAnimation
//
//  Created by Jack on 2016/10/20.
//  Copyright © 2016年 mini1. All rights reserved.
//

#import "myView.h"

@implementation myView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    NSLog(@"draw");
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextStrokePath(ctx);
    
}


@end
