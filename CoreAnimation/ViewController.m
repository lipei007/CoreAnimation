//
//  ViewController.m
//  CoreAnimation
//
//  Created by Jack on 2016/10/20.
//  Copyright © 2016年 mini1. All rights reserved.
//

#import "ViewController.h"
#import "myView.h"
#import <GLKit/GLKit.h>
#import "ReflectionView.h"

@interface ViewController () {
    CAReplicatorLayer *replicatorLayer;
    CAShapeLayer *activityLayer;
}

@property (nonatomic,strong) UIView *containerView;

@property (nonatomic,strong) CALayer *colorLayer;

@end

@implementation ViewController

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        _containerView.center = self.view.center;
    }
    return _containerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self buildCube];
//    [self reflectionView];
//    [self emitter];
    
//    [self presentationLayer];
    
//    UIImage *image = [UIImage imageNamed:@"1001.jepg"];
//
//    UIImage *mask = [UIImage imageNamed:@"mars.png"];
//    CGColorSpaceRef graySpace = CGColorSpaceCreateDeviceGray();
//
//    CGImageRef maskRef = CGImageCreateCopyWithColorSpace(mask.CGImage, graySpace);
//
//    CGImageRef resultRef = CGImageCreateWithMask(image.CGImage, maskRef);
//    UIImage *result = [UIImage imageWithCGImage:resultRef];
//    CGImageRelease(resultRef);
//    CGImageRelease(maskRef);
//
//    UIImageView *imageV = [[UIImageView alloc] initWithImage:result];
//    imageV.frame = CGRectMake(100, 100, 100, 100);
//    imageV.backgroundColor = [UIColor redColor];
//    [self.view addSubview:imageV];
    
    
    [self addLayer];
    [self addActivityLayer];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ReplicatorLayer

- (void)addLayer {
    //初始化添加复制图层
    replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.bounds = CGRectMake(100, 100, 300, 300);
    replicatorLayer.position = self.view.center;
    replicatorLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.view.layer addSublayer:replicatorLayer];
    [self addActivityLayer];
}

- (void)addActivityLayer {
    activityLayer = [CAShapeLayer layer];
    
    //使用贝塞尔曲线绘制矩形路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.view.center.x, self.view.center.y/2)];
    [path addLineToPoint:CGPointMake(self.view.center.x + 20, self.view.center.y/2)];
    [path addLineToPoint:CGPointMake(self.view.center.x + 10, self.view.center.y/2 + 20)];
    [path addLineToPoint:CGPointMake(self.view.center.x - 10 , self.view.center.y/2 + 20)];
    [path closePath];
    activityLayer.fillColor = [UIColor redColor].CGColor;
    activityLayer.path = path.CGPath;
    //设置图层不可见
    activityLayer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01);
    
    [replicatorLayer addSublayer:activityLayer];
    
    //复制的图层数为三个
    replicatorLayer.instanceCount = 3;
    //设置每个复制图层延迟时间
    replicatorLayer.instanceDelay = 1.f / 3.f;
    //设置每个图层之间的偏移
    replicatorLayer.instanceTransform = CATransform3DMakeTranslation(35, 0, 0);
}

- (CABasicAnimation *)alphaAnimation{
    //设置透明度动画
    CABasicAnimation *alpha = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alpha.fromValue = @1.0;
    alpha.toValue = @0.01;
    alpha.duration = 1.f;
    return alpha;
}

- (CABasicAnimation *)activityScaleAnimation{
    //设置缩放动画
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.toValue = @1;
    scale.fromValue = @1;
    return scale;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //设置动画组，并执行动画
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[[self alphaAnimation],[self activityScaleAnimation]];
    group.duration = 1.f;
    group.repeatCount = HUGE;
    [activityLayer addAnimation:group forKey:@""];
    
}

#pragma mark - 固体

#define Top 0
#define Bottom 1
#define Left 2
#define Right 3
#define Front 4
#define Back 5
#define CubeSide 200.0f


- (NSArray <UIView *>*)faceArray {
    static NSMutableArray *faces = nil;
    
    if (!faces) {
        
        faces = [NSMutableArray array];
        
        for (int i = 0; i < 6; i++) {
            UILabel *face = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CubeSide, CubeSide)];
            face.font = [UIFont systemFontOfSize:50];
            face.text = [NSString stringWithFormat:@"%d",i+1];
            face.textAlignment = NSTextAlignmentCenter;
            UIColor *randomColor = [UIColor colorWithRed:(0.3 * (i+1) / 6) green:(0.8 * (i+1) / 6) blue:(0.5 * (i+1) / 6) alpha:1];
//            face.textColor = randomColor;
            face.backgroundColor = randomColor;
            
            [faces addObject:face];
        }
    }
    
    return faces;
}

- (void)applyLight:(CALayer *)face {
    
#define LIGHT_DIRECTION 0, 1, -1 // 光照射方向，点光源：光线从光源点向四面八方发散
#define AMBIENT_LIGHT 0.4 // 环境光强度，环境光源：光线从各个地方以各个角度投射到场景中所有物体表面，找不到光源的确切位置。
    
    //add lighting layer
    CALayer *layer = [CALayer layer];
    layer.frame = face.bounds;
    [face addSublayer:layer];
    //convert the face transform to matrix
    //(GLKMatrix4 has the same structure as CATransform3D)
    //GLKMatrix4和CATransform3D内存结构一致，但坐标类型有长度区别，所以理论上一致
    CATransform3D transform = face.transform;
    GLKMatrix4 matrix4 = *(GLKMatrix4 *)&transform;
    GLKMatrix3 matrix3 = GLKMatrix4GetMatrix3(matrix4);
    //get face normal
    GLKVector3 normal = GLKVector3Make(0, 0, 1);

    
    normal = GLKMatrix3MultiplyVector3(matrix3, normal);
    normal = GLKVector3Normalize(normal);
    //get dot product with light direction
    GLKVector3 light = GLKVector3Normalize(GLKVector3Make(LIGHT_DIRECTION));
    float dotProduct = GLKVector3DotProduct(light, normal);
    
    //set lighting layer opacity
    CGFloat shadow = 1 + dotProduct - AMBIENT_LIGHT;
    UIColor *color = [UIColor colorWithWhite:0 alpha:shadow];
    layer.backgroundColor = color.CGColor;
}

- (void)cube:(UIView *)cube addFace:(NSInteger)face withTransform:(CATransform3D)transform {
    
    UIView *faceView = [[self faceArray] objectAtIndex:face];
    faceView.layer.position = CGPointMake(CubeSide / 2, CubeSide / 2);
    faceView.layer.transform = transform;
    
    [cube addSubview:faceView];
    [self applyLight:faceView.layer];
}

- (void)buildCube {
    
    UIView *cube = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CubeSide, CubeSide)];
    cube.center = self.view.center;
    [self.view addSubview:cube];
    
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0f / 500;
    
    perspective = CATransform3DRotate(perspective, -M_PI_4, 1, 0, 0);
    perspective = CATransform3DRotate(perspective, -M_PI_4, 0, 1, 0);
    
    cube.layer.sublayerTransform = perspective;
    
    CATransform3D transform = CATransform3DIdentity;
    // top 1
    transform = CATransform3DTranslate(transform, 0, -CubeSide / 2, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 1, 0, 0);
    [self cube:cube addFace:Top withTransform:transform];
    
    // bottom 2
    transform = CATransform3DMakeTranslation(0, CubeSide / 2, 0);
    transform = CATransform3DRotate(transform, -M_PI_2, 1, 0, 0);
    [self cube:cube addFace:Bottom withTransform:transform];
    
    // left 3
    transform = CATransform3DMakeTranslation(-CubeSide / 2, 0, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
    [self cube:cube addFace:Left withTransform:transform];
    
    // right 4
    transform = CATransform3DMakeTranslation(CubeSide / 2, 0, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
    [self cube:cube addFace:Right withTransform:transform];
    
    // front 5
    transform = CATransform3DMakeTranslation(0, 0, CubeSide / 2);
    [self cube:cube addFace:Front withTransform:transform];
    
    // back 6
    transform = CATransform3DMakeTranslation(0, 0, -CubeSide / 2);
    transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
    [self cube:cube addFace:Back withTransform:transform];
    
    
}


#pragma mark - CATextLayer

- (void)drawText {
    
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    // contentsScale 并不关心屏幕的拉伸因素而总是默认为1.0。
    // 如果我们想以Retina的质量来显示文字，我们就得手动地设置 CATextLayer 的 contentsScale 属性
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    
    //set text attributes
    textLayer.foregroundColor = [UIColor blackColor].CGColor;
    textLayer.alignmentMode = kCAAlignmentJustified;
    textLayer.wrapped = YES;
    
    //choose a font
    UIFont *font = [UIFont systemFontOfSize:15];
    
    //set layer font
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    // font 属性不是一个 UIFont 类型，而是一个 CFTypeRef 类型。
    // 这样可以根据你的具体需要来决定字体属性应该是用 CGFontRef 类型还是 CTFontRef 类型（ Core Text字体）
    textLayer.font = fontRef;
    // 字体大小也是用 fontSize 属性单独设置的，因为 CTFontRef 和 CGFontRef 并不像UIFont一样包含点大小
    textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    
    //choose some text
    NSString *text = @"Lorem ipsum dolor sit amet, consectetur adipiscing";
    
    //set layer text
    // CATextLayer 的 string 属性并不是你想象的 NSString 类型
    // 而是 id 类型。这样你既可以用 NSString 也可以用 NSAttributedString 来指定文本了
    textLayer.string = text;
}

- (void)transformLayer {
    //create cube layer
    CATransformLayer *cube = [CATransformLayer layer];


}

- (CALayer *)faceWithTransform:(CATransform3D)transform
{
    //create cube face layer
    CALayer *face = [CALayer layer];
    face.frame = CGRectMake(-50, -50, 100, 100);
    //apply a random color
    CGFloat red = (rand() / (double)INT_MAX);
    CGFloat green = (rand() / (double)INT_MAX);
    CGFloat blue = (rand() / (double)INT_MAX);
    face.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1].CGColor;
    //apply the transform and return
    face.transform = transform;
    return face;
    
}


- (void)gradientLayer {
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    //set gradient colors
    // 数组成员接受 CGColorRef 类型的值
    gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor,(__bridge id)[UIColor greenColor].CGColor,(__bridge id)[UIColor blueColor].CGColor];

    
    // 默认情况下，这些颜色在空间上均匀地被渲染，但是我们可以用 locations 属性来调整空间。
    // locations 属性是一个浮点数值的数组（ 以 NSNumber 包装）。
    // 这些浮点数定义了 colors 属性中每个不同颜色的位置，
    // 以单位坐标系进行标定。0.0代表着渐变的开始，1.0代表着结束。
    // locations 数组并不是强制要求的，但是如果你给它赋值了就一定要确保 locations 的数组大小和 colors 数组大小一定要相同，否则你将会得到一个空白的渐变。
    //set locations
    gradientLayer.locations = @[@0.0, @0.25, @0.5];
    
    //set gradient start and end points
    // startPoint 和 endPoint 属性，他们决定了渐变的方向。这两个参数是以单位坐标系进行的定义，所以左上角坐标是{0, 0}，右下角坐标是{1, 1}。
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    
}

- (void)reflectionView {
    
    ReflectionView *v = [[ReflectionView alloc] initWithFrame:CGRectMake(0, 0, 200, 180)];
    v.center = self.view.center;
    [self.view addSubview:v];

}

- (void)emitter{
    
    [self.view addSubview:self.containerView];
    
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.frame = self.containerView.bounds;
    
    [self.containerView.layer addSublayer:emitter];
    //configure emitter
    emitter.renderMode = kCAEmitterLayerAdditive;
    emitter.emitterPosition = CGPointMake(emitter.frame.size.width / 2.0, emitter.frame.size.height / 2.0);
    //create a particle template
    CAEmitterCell *cell = [[CAEmitterCell alloc] init];
    cell.contents = (__bridge id)[UIImage imageNamed:@"mars.png"].CGImage;
    cell.birthRate = 150;
    cell.lifetime = 5.0;
    cell.color = [UIColor colorWithRed:1 green:0.5 blue:0.1 alpha:1.0].CGColor;
    cell.alphaSpeed = -0.4;
    cell.velocity = 50;
    cell.velocityRange = 50;
    cell.emissionRange = M_PI * 2.0;
    //add particle template to emitter
    emitter.emitterCells = @[cell];
    
}

- (void)presentationLayer {
    
    self.colorLayer = [CALayer layer];
    self.colorLayer.frame = CGRectMake(0, 0, 100, 100);
    self.colorLayer.position = CGPointMake(self.view.bounds.size.width / 2,self.view.bounds.size.height / 2);
    
    self.colorLayer.backgroundColor = [UIColor redColor].CGColor;
    
    [self.view.layer addSublayer:self.colorLayer];
                                           
}
                                           
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    if ([self.colorLayer.presentationLayer hitTest:point]) {
        
        NSLog(@"touched container");
        
        CGFloat red = arc4random() / (CGFloat)INT_MAX;
        CGFloat green = arc4random() / (CGFloat)INT_MAX;
        CGFloat blue = arc4random() / (CGFloat)INT_MAX;
        
        self.colorLayer.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1].CGColor;
        
    } else {
        
        NSLog(@"ok,I'll be there");
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:4.0];
        self.colorLayer.position = point;
        [CATransaction commit];
        
    }
    
}
                            
                            

@end
