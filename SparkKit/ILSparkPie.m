#import "ILSparkPie.h"

@implementation ILSparkPie

- (CAShapeLayer*) border
{
    CAShapeLayer* borderLayer = [CAShapeLayer new];
    borderLayer.path = CGPathCreateWithEllipseInRect(ILRectSquareInRect(self.bounds), NULL);
    return borderLayer;
}


@end
