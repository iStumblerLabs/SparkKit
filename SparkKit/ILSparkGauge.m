#import "ILSparkGauge.h"


/*! Pie and Ring Drawing Hints */
NSString* const ILSparkGaugeMinAngleHint = @"ILSparkGaugeMinAngleHint";
NSString* const ILSparkGaugeMaxAngleHint = @"ILSparkGaugeMaxAngleHint";
NSString* const ILSparkGaugeFillClockwiseHint = @"ILSparkGaugeFillClockwiseHint";
NSString* const ILSparkGaugeDialWidthHint = @"ILSparkGaugeDialWidthHint";
NSString* const ILSparkGaugeRingWidthHint = @"ILSparkGaugeRingWidthHint";

/*! Vert and Horz Drawing Direction Hint */
NSString* const ILSparkGaugeFillDirectionHint = @"ILSparkGaugeFillDirectionHint";

/*! Default Dial and Ring Width */
CGFloat const ILSparkGaugeDefaultDialWidth = 4;
CGFloat const ILSparkGaugeDefaultRingWidth = 8;

#pragma mark - Gauge Style

@interface ILSparkStyle (ILSparkGauge)
@property (nonatomic, readonly) CGFloat minAngle;
@property (nonatomic, readonly) CGFloat maxAngle;
@property (nonatomic, readonly) BOOL fillClockwise;
@property (nonatomic, readonly) CGFloat dialWidth;
@property (nonatomic, readonly) CGFloat ringWidth;
@property (nonatomic, readonly) ILSparkGaugeFillDirection fillDirection;

@end

#pragma mark - Private

@interface ILSparkGauge ()
@property (nonatomic, retain) CATextLayer *indicatorText;
@property (nonatomic, retain) CAShapeLayer *indicatorLayer;

@end

#pragma mark -

@implementation ILSparkGauge

#ifdef IL_UI_KIT
#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.indicatorLayer.frame = self.bounds;
//    NSLog(@"<%@ %p layoutSubviews frame: %@ layer frame: %@ layer bounds: %@>",
//        self.class, self, NSStringFromCGRect(self.frame),
//        NSStringFromCGRect(self.style == ILSparkGaugeTextStyle ? self.indicatorText.frame : self.indicatorLayer.frame),
//        NSStringFromCGRect(self.style == ILSparkGaugeTextStyle ? self.indicatorText.bounds : self.indicatorLayer.bounds));
}
#endif

#pragma mark - ILBorderedView

- (void)initView
{
    [super initView];
    self.style = ILSparkGaugeTextStyle;
    self.dataSource = nil;
    
    self.indicatorLayer = [CAShapeLayer new];
    [self.layer addSublayer:self.indicatorLayer];

    self.indicatorText = [CATextLayer new];
    [self.layer addSublayer:self.indicatorText];
}

- (void)updateView
{
    [super updateView];

    ILBezierPath* filledPath = nil;

    self.indicatorLayer.hidden = (self.style == ILSparkGaugeTextStyle);
    self.indicatorText.hidden = (self.style != ILSparkGaugeTextStyle);

    CGFloat datum = self.dataSource.datum;
    CGRect insetRect = self.borderInset;

    if (self.dataSource) {
        switch (self.gaugeStyle) {
            case ILSparkGaugeTextStyle: {
                NSString* valueString = [NSString stringWithFormat:@"%.1f%%", datum * 100];
                CGRect textRect = insetRect;
                textRect.size.height = (self.style.font.pointSize * 1.5); // baseline?
                textRect.origin.y = (((insetRect.size.height - textRect.size.height) / 2) + insetRect.origin.y);
                
                self.indicatorText.string = valueString;
                self.indicatorText.alignmentMode = kCAAlignmentCenter;
                self.indicatorText.font = (__bridge CFTypeRef _Nullable)(self.style.font.fontName);
                self.indicatorText.fontSize = self.style.font.pointSize;
                self.indicatorText.frame = textRect;
                self.indicatorText.zPosition = 1.0; // frontmost?
                self.indicatorText.contentsGravity = kCAGravityCenter;
                self.indicatorText.foregroundColor = self.style.fill.CGColor;
                self.indicatorText.truncationMode = kCATruncationEnd;
                self.indicatorText.contentsScale = [[ILScreen mainScreen] scale];
                self.indicatorText.hidden = NO;
            

                // self.indicatorText.shouldRasterize = YES;
                // self.indicatorText.sublayers = nil;

                // self.indicatorText.backgroundColor = [ILColor orangeColor].CGColor;

                // compute the string size and offsets
                // CGSize stringSize = attributedValueString.size;
                // CGFloat xOffset = (self.bounds.size.width-stringSize.width)/2;
                // CGFloat yOffset = (self.bounds.size.height-stringSize.height)/2;
                // CGRect stringRect = CGRectIntegral(CGRectMake(xOffset, yOffset, stringSize.width, stringSize.height));

                // set text properties and mask
                // self.indicatorText.mask = self.borderMask;
                

                // self.indicatorText.frame = stringRect;
                break;
            }
            case ILSparkGaugeVerticalStyle: {
                CGFloat indicatorPosition = insetRect.size.height - (insetRect.size.height * datum);
                CGRect filledRect = CGRectMake(insetRect.origin.x, (insetRect.origin.x + indicatorPosition), insetRect.size.width, (insetRect.size.height - indicatorPosition));
                filledPath = [ILBezierPath bezierPathWithRect:filledRect];
                break;
            }
            case ILSparkGaugeHorizontalStyle: {
                CGFloat indicatorPosition = (insetRect.size.width * datum);
                CGRect filledRect = CGRectMake(insetRect.origin.x, insetRect.origin.y, indicatorPosition, insetRect.size.height);
                filledPath = [ILBezierPath bezierPathWithRect:filledRect];
                break;
            }
            case ILSparkGaugeSquareStyle: {
                CGRect squareRect = ILRectSquareInRect(insetRect);
                CGFloat indicatorSideLength = (squareRect.size.width * self.dataSource.datum);
                CGFloat indicatorInset = (squareRect.size.width - indicatorSideLength) / 2; // ??? take the square root?
                CGRect filledRect = CGRectInset(squareRect, indicatorInset, indicatorInset);
                filledPath = [ILBezierPath bezierPathWithRect:filledRect];
                break;
            }
            case ILSparkGaugeCircleStyle: {
                CGRect squareRect = ILRectSquareInRect(insetRect);
                CGFloat indicatorSideLength = (squareRect.size.width * datum);
                CGFloat indicatorInset = (squareRect.size.width - indicatorSideLength) / 2; // ??? equal area?
                CGRect filledRect = CGRectInset(squareRect, indicatorInset, indicatorInset);
                filledPath = [ILBezierPath bezierPathWithOvalInRect:filledRect];
                break;
            }
            case ILSparkGaugeRingStyle: {
                CGRect squareRect = ILRectSquareInRect(insetRect);
                CGFloat indicatorSideLength = (squareRect.size.height / 2.0f) - ILPathlineWidth;
                CGPoint squareCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2.0f), squareRect.origin.y + (squareRect.size.height / 2.0f));
                CGPoint topDeadCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2.0f), squareCenter.y - indicatorSideLength);
                CGFloat firstAngle = -(M_PI / 2.0f);
                CGFloat secondAngle = ((2.0f * M_PI) * datum) - (CGFloat) (M_PI / 2.0f);
                filledPath = [ILBezierPath new];
                [filledPath addArcWithCenter:squareCenter radius:indicatorSideLength startAngle:firstAngle endAngle:secondAngle clockwise:YES];
                CGPoint outsideEndPoint = filledPath.currentPoint;
                CGPoint insetPoint = ILPointOnLineToPointAtDistance(outsideEndPoint, squareCenter, self.style.ringWidth);
                [filledPath addLineToPoint:insetPoint];
                [filledPath addArcWithCenter:squareCenter radius:(indicatorSideLength - self.style.ringWidth) startAngle:secondAngle endAngle:firstAngle clockwise:NO];
                [filledPath addLineToPoint:topDeadCenter];
                break;
            }
            case ILSparkGaugePieStyle: {
                CGRect squareRect = ILRectSquareInRect(insetRect);
                CGFloat indicatorSideLength = (squareRect.size.height / 2.0f) - ILPathlineWidth;
                CGPoint squareCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2.0f), squareRect.origin.y + (squareRect.size.height / 2.0f));
                CGPoint topDeadCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2.0f),squareCenter.y - indicatorSideLength);
                CGFloat firstAngle = -(M_PI / 2.0);
                CGFloat secondAngle = ((2.0f * M_PI) * datum) - (M_PI / 2.0f);
                filledPath = [ILBezierPath new];
                // filledPath.usesEvenOddFillRule = YES;
                // filledPath.windingRule = NSEvenOddWindingRule;
                [filledPath addArcWithCenter:squareCenter radius:indicatorSideLength startAngle:firstAngle endAngle:secondAngle clockwise:YES];
                [filledPath addLineToPoint:squareCenter];
                [filledPath addLineToPoint:topDeadCenter];
                break;
            }
            case ILSparkGaugeDialStyle: {
                CGRect squareRect = ILRectSquareInRect(insetRect);
                CGFloat indicatorSideLength = (squareRect.size.height / 2.0f) - self.style.dialWidth;
                CGPoint squareCenter = ILPointCenteredInRect(squareRect);
                CGFloat indicatorAngle = ((2.0f * M_PI) * self.dataSource.datum) - (M_PI / 2.0f);
                filledPath = [ILBezierPath new];
                [filledPath addArcWithCenter:squareCenter radius:indicatorSideLength startAngle:indicatorAngle endAngle:indicatorAngle clockwise:YES];
                [filledPath addLineToPoint:squareCenter];
                break;
            }
        }
    }

    if (filledPath) {
        self.indicatorLayer.path = filledPath.CGPath;
        // self.indicatorLayer.mask = self.border;
        self.indicatorLayer.fillColor = self.style.fill.CGColor;
        
        if (self.gaugeStyle == ILSparkGaugeDialStyle) {
            self.indicatorLayer.strokeColor = self.style.fill.CGColor;
            self.indicatorLayer.lineWidth = self.style.dialWidth;
            self.indicatorLayer.lineCap = @"round";
        } else {
            self.indicatorLayer.strokeColor = self.style.stroke.CGColor;
            self.indicatorLayer.lineWidth = self.style.width;
        }
    }
}

- (BOOL) isCircular
{
    return (self.gaugeStyle == ILSparkGaugeCircleStyle)
        || (self.gaugeStyle == ILSparkGaugeRingStyle)
        || (self.gaugeStyle == ILSparkGaugePieStyle)
        || (self.gaugeStyle == ILSparkGaugeDialStyle);
}

@end

#pragma mark -

@implementation ILSparkStyle (ILSparkGauge)

- (CGFloat) minAngle
{
    CGFloat angle = 0.0;
    if (self.hints[ILSparkGaugeMinAngleHint]) {
        angle = [self.hints[ILSparkGaugeMinAngleHint] doubleValue];
    }
    return angle;
}

- (CGFloat) maxAngle
{
    CGFloat angle = 1.0;
    if (self.hints[ILSparkGaugeMaxAngleHint]) {
        angle = [self.hints[ILSparkGaugeMaxAngleHint] doubleValue];
    }
    return angle;
}

- (BOOL) fillClockwise
{
    BOOL clockwise = YES;
    if (self.hints[ILSparkGaugeFillClockwiseHint]) {
        clockwise = [self.hints[ILSparkGaugeFillClockwiseHint] boolValue];
    }
    return clockwise;
}

- (CGFloat) dialWidth;
{
    CGFloat width = ILSparkGaugeDefaultDialWidth;
    if (self.hints[ILSparkGaugeDialWidthHint]) {
        width = [self.hints[ILSparkGaugeDialWidthHint] doubleValue];
    }
    return width;
}

- (CGFloat) ringWidth;
{
    CGFloat width = ILSparkGaugeDefaultRingWidth;
    if (self.hints[ILSparkGaugeRingWidthHint]) {
        width = [self.hints[ILSparkGaugeRingWidthHint] doubleValue];
    }
    return width;
}

- (ILSparkGaugeFillDirection) fillDirection
{
    ILSparkGaugeFillDirection direciton = ILSparkGaugeNaturalFill;
    if (self.hints[ILSparkGaugeFillDirectionHint]) {
        direciton = [self.hints[ILSparkGaugeFillDirectionHint] integerValue]; // TODO range check this
    }
    return direciton;
}

@end

