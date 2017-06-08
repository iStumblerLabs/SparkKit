#import "ILSparkView.h"
#import "ILSparkStyle.h"


#pragma mark -

@interface ILSparkView ()
@property(nonatomic, retain) ILSparkStyle* styleStorage;
@property(nonatomic, retain) CAShapeLayer* borderLayerStorage;

@end

@implementation ILSparkView

- (ILSparkStyle*) style
{
    if (self.styleStorage) {
        return self.styleStorage;
    }
    else {
        return [ILSparkStyle defaultStyle];
    }
}

- (void) setStyle:(ILSparkStyle *)style
{
    self.styleStorage = style;
}

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
    self.borderLayerStorage = nil;
    [self updateView];
}
#endif

#pragma mark - border

- (CAShapeLayer*) border
{
    if (!self.borderLayerStorage) {
        if (self.isCircular) {
            self.borderLayerStorage = [CAShapeLayer new];
            CGRect square = CGRectInset(ILRectSquareInRect(self.bounds), (self.style.width / 2), (self.style.width / 2));
            CGPathRef squarePath = CGPathCreateWithEllipseInRect(square, NULL);
            self.borderLayerStorage.path = squarePath;
            CGPathRelease(squarePath);
        }
        else {
            self.borderLayerStorage = [CAShapeLayer new];
            CGRect insetRect = CGRectInset(self.bounds, (self.style.width / 2), (self.style.width / 2));
            CGPathRef borderPath = CGPathCreateWithRect(insetRect, NULL);
            self.borderLayerStorage.path = borderPath;
            CGPathRelease(borderPath);
        }
    }
    return self.borderLayerStorage;
}

- (BOOL) isCircular
{
    return NO;
}

#pragma mark - ILViews

- (void) initView
{
#ifdef IL_APP_KIT
    self.layer = [CALayer new];
    self.wantsLayer = YES;
#endif
    self.style = [ILSparkStyle defaultStyle];
}

- (void) updateView
{
    // udpate the border view
    if (self.style.bordered) {
        CAShapeLayer* borderLayer = self.border;
        borderLayer.fillColor = [ILColor clearColor].CGColor;
        borderLayer.lineWidth = self.style.width;
        borderLayer.strokeColor = self.style.border.CGColor;
        if (![self.layer.sublayers containsObject:borderLayer]) {
            [self.layer addSublayer:borderLayer];
        }
    }
}

@end
