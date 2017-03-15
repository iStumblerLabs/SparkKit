#import "ILSparkView.h"
#import "ILSparkStyle.h"

CGRect ILRectSquareInRect(CGRect rect) {
    CGFloat sideLength = fminf(rect.size.width,rect.size.height);
    CGFloat xOffset = (rect.size.width-sideLength)/2;
    CGFloat yOffset = (rect.size.height-sideLength)/2;
    return CGRectIntegral(CGRectMake(xOffset,yOffset,sideLength,sideLength));
}

CGVector ILVectorFromPointToPoint(CGPoint from, CGPoint to) {
    return CGVectorMake(from.x-to.x,from.y-to.y);
}

CGFloat ILVectorLength(CGVector delta) {
    return sqrt(fabs(delta.dx*delta.dx) + fabs(delta.dy*delta.dy));
}

CGFloat ILVectorRadians(CGVector delta) {
    return atan2(delta.dx, delta.dy);
}

CGPoint ILPointOnLineToPointAtDistance(CGPoint from, CGPoint to, CGFloat distance) {
    CGVector lineVector = ILVectorFromPointToPoint(from, to);
    CGFloat lineDistance = ILVectorLength(lineVector);
    CGVector scaledVector = CGVectorMake(lineVector.dx / lineDistance, lineVector.dy / lineDistance);
    CGVector segmentVector = CGVectorMake( scaledVector.dx * distance, scaledVector.dy * distance);
//  NSLog(@"ILPointOnLineToPointAtDistance: %@ -> %@ vector: %@ scaled: %@ segment: %@",
//  NSStringFromCGPoint(from), NSStringFromCGPoint(to), NSStringFromCGVector(lineVector),
//  NSStringFromCGVector(scaledVector), NSStringFromCGVector(segmentVector));
    return CGPointMake(from.x-segmentVector.dx, from.y-segmentVector.dy);
}

#pragma mark -

@implementation ILSparkView

#pragma mark - ILView

- (instancetype) initWithFrame:(CGRect)frame {
    if( self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

#pragma mark - NSCoder

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if( self = [super initWithCoder:aDecoder]) {
        [self initView];
    }
    return self;
}

#ifdef IL_APP_KIT

#pragma mark - NSView

- (void)setFrameSize:(NSSize)newSize;
{
    [super setFrameSize:newSize];
    [self updateView];
}
#endif

#pragma mark - ILSparkStyle

- (CAShapeLayer*) border
{
    if (!self.borderLayerStorage) {
        self.borderLayerStorage = [CAShapeLayer new];
        CGPathRef borderPath = CGPathCreateWithRect(CGRectIntegral(self.bounds), NULL);
        self.borderLayerStorage.path = borderPath;
        CGPathRelease(borderPath);
    }
    return self.borderLayerStorage;
}

#pragma mark - ILViews

- (void) initView
{
#ifdef IL_APP_KIT
    [self setWantsLayer:YES];
#endif
    self.style = [ILSparkStyle defaultStyle];
}

- (void) updateView
{
    for (CALayer* layer in [self.layer.sublayers copy]) { // remove all sublayers
        [layer removeFromSuperlayer];
    }

    if (self.style.bordered) {
        CAShapeLayer* borderLayer = self.border;
        borderLayer.fillColor = [ILColor clearColor].CGColor;
        borderLayer.lineWidth = self.style.width;
        borderLayer.strokeColor = self.style.stroke.CGColor;
        [self.layer addSublayer:borderLayer];
    }
}

@end
