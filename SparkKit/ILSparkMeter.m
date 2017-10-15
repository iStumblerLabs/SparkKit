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
@property (nonatomic, retain) CALayer *indicatorLayer;

@end

#pragma mark -

@implementation ILSparkMeter

+ (CALayer*) sparkMeterWithData:(NSObject<ILSparkMeterDataSource>*)dataSource size:(CGSize)size meterStyle:(ILSparkMeterStyle) meterStyle sparkStyle:(ILSparkStyle*)sparkStyle
{
    CALayer* meterLayer = nil;
    ILBezierPath* filledPath = nil;
    
    CGFloat datum = dataSource.datum;
    CGRect insetRect = NSMakeRect(0, 0, size.width, size.height); // self.borderInset;
    
    if (dataSource) {
        switch (meterStyle) {
            case ILSparkMeterTextStyle: {
                NSString* valueString = [NSString stringWithFormat:@"%.1f%%", datum * 100];
                CGRect textRect = insetRect;
                textRect.size.height = (sparkStyle.font.pointSize * 1.5); // baseline?
                textRect.origin.y = (((insetRect.size.height - textRect.size.height) / 2) + insetRect.origin.y);
                
                CATextLayer* indicatorText = [CATextLayer layer];
                indicatorText.string = valueString;
                indicatorText.alignmentMode = kCAAlignmentCenter;
                indicatorText.font = (__bridge CFTypeRef _Nullable)(sparkStyle.font.fontName);
                indicatorText.fontSize = sparkStyle.font.pointSize;
                indicatorText.frame = textRect;
                indicatorText.zPosition = 1.0; // frontmost?
                indicatorText.contentsGravity = kCAGravityCenter;
                indicatorText.foregroundColor = sparkStyle.fill.CGColor;
                indicatorText.truncationMode = kCATruncationEnd;
                indicatorText.contentsScale = [[ILScreen mainScreen] scale];
                indicatorText.hidden = NO;
                
                meterLayer = indicatorText;
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
                CGFloat indicatorSideLength = (squareRect.size.width * datum);
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
                CGPoint insetPoint = ILPointOnLineToPointAtDistance(outsideEndPoint, squareCenter, sparkStyle.ringWidth);
                [filledPath addLineToPoint:insetPoint];
                [filledPath addArcWithCenter:squareCenter radius:(indicatorSideLength - sparkStyle.ringWidth) startAngle:secondAngle endAngle:firstAngle clockwise:NO];
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
                CGFloat indicatorSideLength = (squareRect.size.height / 2.0f) - sparkStyle.dialWidth;
                CGPoint squareCenter = ILPointCenteredInRect(squareRect);
                CGFloat indicatorAngle = ((2.0f * M_PI) * datum) - (M_PI / 2.0f);
                filledPath = [ILBezierPath new];
                [filledPath addArcWithCenter:squareCenter radius:indicatorSideLength startAngle:indicatorAngle endAngle:indicatorAngle clockwise:YES];
                [filledPath addLineToPoint:squareCenter];
                break;
            }
        }
    }
    
    if (filledPath) {
        CAShapeLayer* indicatorLayer = [CAShapeLayer layer];
        indicatorLayer.path = filledPath.CGPath;
        // self.indicatorLayer.mask = self.border;
        indicatorLayer.fillColor = sparkStyle.fill.CGColor;
        
        if (meterStyle == ILSparkMeterDialStyle) {
            indicatorLayer.strokeColor = sparkStyle.fill.CGColor;
            indicatorLayer.lineWidth = sparkStyle.dialWidth;
            indicatorLayer.lineCap = @"round";
        } else {
            indicatorLayer.strokeColor = sparkStyle.stroke.CGColor;
            indicatorLayer.lineWidth = sparkStyle.width;
        }
        
        meterLayer = indicatorLayer;
    }
    
    return meterLayer;
}

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

#pragma mark - ILSparkView

- (void)initView
{
    [super initView];
    self.style = [ILSparkStyle defaultStyle];
    self.dataSource = nil;
}

- (void)updateView
{
    [super updateView];
    self.indicatorLayer = [ILSparkMeter sparkMeterWithData:self.dataSource size:self.frame.size meterStyle:self.gaugeStyle sparkStyle:self.style];
    self.indicatorLayer.frame = self.bounds;
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


#if IL_APP_KIT

#pragma mark -

@implementation ILSparkMeterCell

- (void) initCell
{
    self.gaugeStyle = ILSparkMeterHorizontalStyle;
    self.style = [ILSparkStyle defaultStyle];
}

#pragma mark - NSObject

- (id) init
{
    if( self = [super init]) {
        [self initCell];
    }
    return self;
}

#pragma mark - NSCell

- (id) initTextCell:(NSString*)aString
{
    if( self = [super initTextCell:aString]) {
        [self initCell];
    }
    return self;
}

- (id) initImageCell:(NSImage*)anImage
{
    if( self = [super initImageCell:anImage]) {
        [self initCell];
    }
    return self;
}

- (void)drawWithFrame:(NSRect)rect inView:(NSView *)view
{
    if ([[self representedObject] conformsToProtocol:@protocol(ILSparkMeterDataSource)]) {
        CALayer* sparkMeter = [ILSparkMeter sparkMeterWithData:[self representedObject] size:rect.size meterStyle:self.gaugeStyle sparkStyle:self.style];
        [[view layer] addSublayer:sparkMeter];
        sparkMeter.frame = rect;
    }
}

@end

#endif
