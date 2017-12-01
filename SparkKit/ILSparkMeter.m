#import "ILSparkMeter.h"

#pragma mark Hints

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

NSString* const ILSparkMeterStyleHint = @"ILSparkMeterStyleHint";

#pragma mark -

@interface ILSparkMeter ()
@property (nonatomic, retain) CALayer *indicatorLayer;

@end

#pragma mark -

@implementation ILSparkMeter

+ (CALayer*) sparkMeterWithDatum:(CGFloat) datum size:(CGSize)size sparkStyle:(ILSparkStyle*)sparkStyle
{
    CALayer* meterLayer = nil;
    ILBezierPath* filledPath = nil;
    CGRect insetRect = NSMakeRect(0, 0, size.width, size.height); // self.borderInset;
    
    switch (sparkStyle.meterStyle) {
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
            CGFloat secondAngle = ILZeroAngleRadians + ILPercentToRadians(datum);
            filledPath = [ILBezierPath new];
            [filledPath addArcWithCenter:squareCenter radius:indicatorSideLength startAngle:ILZeroAngleRadians endAngle:secondAngle clockwise:YES];
            CGPoint outsideEndPoint = filledPath.currentPoint;
            CGPoint insetPoint = ILPointOnLineToPointAtDistance(outsideEndPoint, squareCenter, sparkStyle.ringWidth);
            [filledPath addLineToPoint:insetPoint];
            [filledPath addArcWithCenter:squareCenter radius:(indicatorSideLength - sparkStyle.ringWidth) startAngle:secondAngle endAngle:ILZeroAngleRadians clockwise:NO];
            [filledPath addLineToPoint:topDeadCenter];
            break;
        }
        case ILSparkMeterPieStyle: {
            CGRect squareRect = ILRectSquareInRect(insetRect);
            CGFloat indicatorSideLength = (squareRect.size.height / 2.0f) - ILPathlineWidth;
            CGPoint squareCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2.0f), squareRect.origin.y + (squareRect.size.height / 2.0f));
            CGPoint topDeadCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2.0f),squareCenter.y - indicatorSideLength);
            CGFloat firstAngle = - (M_PI / 2.0);
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
    
    if (filledPath) {
        CAShapeLayer* indicatorLayer = [CAShapeLayer layer];
        indicatorLayer.path = filledPath.CGPath;
        // self.indicatorLayer.mask = self.border;
        indicatorLayer.fillColor = sparkStyle.fill.CGColor;
        
        if (sparkStyle.meterStyle == ILSparkMeterDialStyle) {
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
    self.dataSource = nil;
}

- (void)updateView
{
    [super updateView];
    self.indicatorLayer = [ILSparkMeter sparkMeterWithDatum:self.dataSource.datum size:self.frame.size sparkStyle:self.style];
    self.indicatorLayer.frame = self.bounds;
    self.layer.sublayers = @[self.indicatorLayer];
}

- (BOOL) isCircular
{
    return (self.style.meterStyle == ILSparkMeterCircleStyle)
        || (self.style.meterStyle == ILSparkMeterRingStyle)
        || (self.style.meterStyle == ILSparkMeterPieStyle)
        || (self.style.meterStyle == ILSparkMeterDialStyle);
}

@end

#pragma mark -

@implementation ILSparkStyle (ILSparkMeter)

- (ILSparkMeterStyle) meterStyle
{
    ILSparkMeterStyle meterStyle = ILSparkMeterHorizontalStyle;
    if (self.hints[ILSparkMeterStyleHint]) {
        meterStyle = [self.hints[ILSparkMeterStyleHint] integerValue]; // TODO range check this
    }
    return meterStyle;
}

- (ILSparkMeterFillDirection) fillDirection
{
    ILSparkMeterFillDirection direciton = ILSparkMeterNaturalFill;
    if (self.hints[ILSparkMeterFillDirectionHint]) {
        direciton = [self.hints[ILSparkMeterFillDirectionHint] integerValue]; // TODO range check this
    }
    return direciton;
}

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

@end

#if IL_APP_KIT

#pragma mark -

@implementation ILSparkMeterCell

- (void) initCell
{
    self.style = [ILSparkStyle defaultStyle];
}

#pragma mark - NSObject

- (id) init
{
    if (self = [super init]) {
        [self initCell];
    }
    return self;
}

#pragma mark - NSCell

- (id) initTextCell:(NSString*)aString
{
    if (self = [super initTextCell:aString]) {
        [self initCell];
    }
    return self;
}

- (id) initImageCell:(NSImage*)anImage
{
    if (self = [super initImageCell:anImage]) {
        [self initCell];
    }
    return self;
}

- (void)drawWithFrame:(NSRect)rect inView:(NSView *)view
{
    if ([[self representedObject] conformsToProtocol:@protocol(ILSparkMeterDataSource)]) {
        CGFloat datum = [(NSObject<ILSparkMeterDataSource>*)[self representedObject] datum];
        CALayer* sparkMeter = [ILSparkMeter sparkMeterWithDatum:datum size:rect.size sparkStyle:self.style];
        [[view layer] addSublayer:sparkMeter];
        sparkMeter.frame = rect;
    }
}

@end

#endif
