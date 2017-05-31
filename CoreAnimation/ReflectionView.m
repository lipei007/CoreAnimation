//
//  ReflectionView.m
//  CoreAnimation
//
//  Created by Jack on 2016/10/27.
//  Copyright © 2016年 mini1. All rights reserved.
//

#import "ReflectionView.h"

@implementation ReflectionView

+ (Class)layerClass
{
    return [CAReplicatorLayer class];
} -
(void)setUp
{
    UIImage *image = [UIImage imageNamed:@"1001.jpeg"];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:self.bounds];
    iv.image = image;
    [self addSubview:iv];
    //configure replicator
    // CAReplicatorLayer 创建layer和它的sublayer的多个副本，副本可以设置transform来变形，或者设置颜色、透明度的变化。
    CAReplicatorLayer *layer = (CAReplicatorLayer *)self.layer; // 变化效果只作用于sublayer的副本
    layer.instanceCount = 2; // 包括自己及副本个数的总个数
    
    //move reflection instance below original and flip vertically
    CATransform3D transform = CATransform3DIdentity;
    CGFloat verticalOffset = self.bounds.size.height + 2;
    transform = CATransform3DTranslate(transform, 0, verticalOffset, 0);
    transform = CATransform3DScale(transform, 1, -1, 0);
    
    layer.instanceTransform = transform;
    //reduce alpha of reflection layer
    layer.instanceAlphaOffset = -0.6;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

@end
