#import "ILSparkPie.h"
#import "ILSparkStyle.h"

#pragma mark -

@implementation ILSparkPie

- (CAShapeLayer*) border
{
    if (!self.borderLayerStorage) {
        self.borderLayerStorage = [CAShapeLayer new];
        CGRect square = CGRectInset(ILRectSquareInRect(self.bounds),1,1);
        CGPathRef squarePath = CGPathCreateWithEllipseInRect(square, NULL);
        self.borderLayerStorage.path = squarePath;
        CGPathRelease(squarePath);
    }
    return self.borderLayerStorage;
}

- (void) updateView
{
    [super updateView]; // clears sublayers and sets the border
    CGRect square = CGRectInset(ILRectSquareInRect(self.bounds),1,1);
    CGPoint twelve = CGPointMake(CGRectGetMidX(square), CGRectGetMaxY(square));
    CGPoint center = CGPointMake(CGRectGetMidX(square), CGRectGetMidY(square));
    CGFloat zeroAngle = (M_PI / 2);
    CGFloat valueAngle = zeroAngle - ((2 * M_PI) * self.dataSource.datum);
    CGMutablePathRef wedge = CGPathCreateMutable();
    
    /* create the wedge path */
    CGPathMoveToPoint(wedge, NULL, twelve.x, twelve.y);
    CGPathAddArc(wedge, NULL, center.x, center.y, (square.size.width / 2), zeroAngle, valueAngle, true);
    CGPathAddLineToPoint(wedge, NULL, center.x, center.y);
    CGPathAddLineToPoint(wedge, NULL, twelve.x, twelve.y);
    
    CAShapeLayer* wedgeLayer = [CAShapeLayer new];
    wedgeLayer.path = wedge;
    wedgeLayer.lineWidth = self.style.width;
    wedgeLayer.strokeColor = self.style.stroke.CGColor;
    wedgeLayer.fillColor = (self.style.filled ? self.style.fill.CGColor : [ILColor clearColor].CGColor);
    
    [self.layer addSublayer:wedgeLayer];
    wedgeLayer.frame = self.bounds;
exit:
    CGPathRelease(wedge);
}

@end
