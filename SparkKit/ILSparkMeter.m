#import "ILSparkMeter.h"


/*! Pie and Ring Drawing Hints */
NSString* const ILSparkMeterMinAngleHint = @"ILSparkMeterMinAngleHint";
NSString* const ILSparkMeterMaxAngleHint = @"ILSparkMeterMaxAngleHint";
NSString* const ILSparkMeterFillClockwiseHint = @"ILSparkMeterFillClockwiseHint";
NSString* const ILSparkMeterDialWidthHint = @"ILSparkMeterDialWidthHint";
NSString* const ILSparkMeterRingWidthHint = @"ILSparkMeterRingWidthHint";

/*! Vert and Horz Drawing Direction Hint */
NSString* const ILSparkMeterFillDirectionHint = @"ILSparkMeterFillDirectionHint";

/*! Default Dial and Ring Width */
CGFloat const ILSparkMeterDefaultDialWidth = 4;
CGFloat const ILSparkMeterDefaultRingWidth = 8;

#pragma mark - Gauge Style

@interface ILSparkStyle (ILSparkMeter)
@property (nonatomic, readonly) CGFloat minAngle;
@property (nonatomic, readonly) CGFloat maxAngle;
@property (nonatomic, readonly) BOOL fillClockwise;
@property (nonatomic, readonly) CGFloat dialWidth;
@property (nonatomic, readonly) CGFloat ringWidth;
@property (nonatomic, readonly) ILSparkMeterFillDirection fillDirection;

@end

#pragma mark - Private

@interface ILSparkMeter ()
@property (nonatomic, retain) CATextLayer *indicatorText;
@property (nonatomic, retain) CAShapeLayer *indicatorLayer;

@end

#pragma mark -

@implementation ILSparkMeter

#ifdef IL_UI_KIT
#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.indicatorLayer.frame = self.bounds;
//    NSLog(@"<%@ %p layoutSubviews frame: %@ layer frame: %@ layer bounds: %@>",
//        self.class, self, NSStringFromCGRect(self.frame),
//        NSStringFromCGRect(self.style == ILSparkMeterTextStyle ? self.indicatorText.frame : self.indicatorLayer.frame),
//        NSStringFromCGRect(self.style == ILSparkMeterTextStyle ? self.indicatorText.bounds : self.indicatorLayer.bounds));
}
#endif

#pragma mark - ILBorderedView

- (void)initView
{
    [super initView];
    self.style = [ILSparkStyle defaultStyle];
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

    self.indicatorLayer.hidden = (self.style == ILSparkMeterTextStyle);
    self.indicatorText.hidden = (self.style != ILSparkMeterTextStyle);

    CGFloat datum = self.dataSource.datum;
    CGRect insetRect = self.borderInset;

    if (self.dataSource) {
        switch (self.gaugeStyle) {
            case ILSparkMeterTextStyle: {
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
            case ILSparkMeterVerticalStyle: {
                CGFloat indicatorPosition = insetRect.size.height - (insetRect.size.height * datum);
                CGRect filledRect = CGRectMake(insetRect.origin.x, (insetRect.origin.x + indicatorPosition), insetRect.size.width, (insetRect.size.height - indicatorPosition));
                filledPath = [ILBezierPath bezierPathWithRect:filledRect];
                break;
            }
            case ILSparkMeterHorizontalStyle: {
                CGFloat indicatorPosition = (insetRect.size.width * datum);
                CGRect filledRect = CGRectMake(insetRect.origin.x, insetRect.origin.y, indicatorPosition, insetRect.size.height);
                filledPath = [ILBezierPath bezierPathWithRect:filledRect];
                break;
            }
            case ILSparkMeterSquareStyle: {
                CGRect squareRect = ILRectSquareInRect(insetRect);
                CGFloat indicatorSideLength = (squareRect.size.width * self.dataSource.datum);
                CGFloat indicatorInset = (squareRect.size.width - indicatorSideLength) / 2; // ??? take the square root?
                CGRect filledRect = CGRectInset(squareRect, indicatorInset, indicatorInset);
                filledPath = [ILBezierPath bezierPathWithRect:filledRect];
                break;
            }
            case ILSparkMeterCircleStyle: {
                CGRect squareRect = ILRectSquareInRect(insetRect);
                CGFloat indicatorSideLength = (squareRect.size.width * datum);
                CGFloat indicatorInset = (squareRect.size.width - indicatorSideLength) / 2; // ??? equal area?
                CGRect filledRect = CGRectInset(squareRect, indicatorInset, indicatorInset);
                filledPath = [ILBezierPath bezierPathWithOvalInRect:filledRect];
                break;
            }
            case ILSparkMeterRingStyle: {
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
            case ILSparkMeterPieStyle: {
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
            case ILSparkMeterDialStyle: {
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
        
        if (self.gaugeStyle == ILSparkMeterDialStyle) {
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
    return (self.gaugeStyle == ILSparkMeterCircleStyle)
        || (self.gaugeStyle == ILSparkMeterRingStyle)
        || (self.gaugeStyle == ILSparkMeterPieStyle)
        || (self.gaugeStyle == ILSparkMeterDialStyle);
}

@end

#pragma mark -

@implementation ILSparkStyle (ILSparkMeter)

- (CGFloat) minAngle
{
    CGFloat angle = 0.0;
    if (self.hints[ILSparkMeterMinAngleHint]) {
        angle = [self.hints[ILSparkMeterMinAngleHint] doubleValue];
    }
    return angle;
}

- (CGFloat) maxAngle
{
    CGFloat angle = 1.0;
    if (self.hints[ILSparkMeterMaxAngleHint]) {
        angle = [self.hints[ILSparkMeterMaxAngleHint] doubleValue];
    }
    return angle;
}

- (BOOL) fillClockwise
{
    BOOL clockwise = YES;
    if (self.hints[ILSparkMeterFillClockwiseHint]) {
        clockwise = [self.hints[ILSparkMeterFillClockwiseHint] boolValue];
    }
    return clockwise;
}

- (CGFloat) dialWidth;
{
    CGFloat width = ILSparkMeterDefaultDialWidth;
    if (self.hints[ILSparkMeterDialWidthHint]) {
        width = [self.hints[ILSparkMeterDialWidthHint] doubleValue];
    }
    return width;
}

- (CGFloat) ringWidth;
{
    CGFloat width = ILSparkMeterDefaultRingWidth;
    if (self.hints[ILSparkMeterRingWidthHint]) {
        width = [self.hints[ILSparkMeterRingWidthHint] doubleValue];
    }
    return width;
}

- (ILSparkMeterFillDirection) fillDirection
{
    ILSparkMeterFillDirection direciton = ILSparkMeterNaturalFill;
    if (self.hints[ILSparkMeterFillDirectionHint]) {
        direciton = [self.hints[ILSparkMeterFillDirectionHint] integerValue]; // TODO range check this
    }
    return direciton;
}

@end

