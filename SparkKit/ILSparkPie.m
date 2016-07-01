#import "ILSparkPie.h"

@implementation ILSparkPie

- (CAShapeLayer*) border
{
    CAShapeLayer* borderLayer = [CAShapeLayer new];
    CGRect square = CGRectInset(ILRectSquareInRect(self.bounds),1,1);
    borderLayer.path = CGPathCreateWithEllipseInRect(square, NULL);
    return borderLayer;
}

- (void) updateView
{
    [super updateView]; // clears sublayers and draws the border
    CGFloat zero = -0.25 * (2 * M_PI);
    CGFloat value = (self.dataSource.data * (2 * M_PI)) + zero;
    CGRect square = CGRectInset(ILRectSquareInRect(self.bounds),1,1);
    CGPoint twelve = CGPointMake(CGRectGetMidX(square), CGRectGetMaxY(square));
    CGPoint center = CGPointMake(CGRectGetMidX(square), CGRectGetMidY(square));
    CGMutablePathRef wedge = CGPathCreateMutable();
    
    /* create the wedge path */
    CGPathMoveToPoint(wedge, NULL, twelve.x, twelve.y);
    CGPathAddArc(wedge, NULL, center.x, center.y, (square.size.width / 2), zero, value, true);
    CGPathAddLineToPoint(wedge, NULL, center.x, center.y);
    CGPathAddLineToPoint(wedge, NULL, twelve.x, twelve.y);
    
    CAShapeLayer* wedgeLayer = [CAShapeLayer new];
    wedgeLayer.path = wedge;
    wedgeLayer.lineWidth = self.style.width;
    wedgeLayer.strokeColor = self.style.stroke.CGColor;
    wedgeLayer.fillColor = self.style.fill.CGColor;
    
    [self.layer addSublayer:wedgeLayer];
    wedgeLayer.frame = self.bounds;
}

@end
