#import "ILSparkStack.h"

#pragma mark Hints

NSString* const ILSparkStackColorsHint = @"ILSparkStackColorsHint"; // NSArray<ILColor*>*

#pragma mark - Private

@interface ILSparkStack ()
@property(nonatomic, retain) CALayer* stackLayer;
@end

#pragma mark -

@implementation ILSparkStack

+ (NSArray<ILColor*>*) defaultStackColors
{
    static NSArray<ILColor*>* defaultColors = nil;
    if (!defaultColors) {
        defaultColors = @[
            [ILColor redColor],
            [ILColor orangeColor],
            [ILColor yellowColor],
            [ILColor greenColor],
            // [ILColor aquaColor],
            [ILColor blueColor],
            // [ILColor violetColor],
            [ILColor grayColor],
            [ILColor whiteColor],
            [ILColor clearColor],
            [ILColor blackColor]
        ];
    }
    return defaultColors;
}

+ (CALayer*) sparkStackWithData:(NSArray<NSNumber*>*)data size:(CGSize)size sparkStyle:(ILSparkStyle*)sparkStyle
{
    CALayer* stackLayer = [CALayer new];
    CGRect insetRect = CGRectMake(0, 0, size.width, size.height); // self.borderInset;

    stackLayer.frame = insetRect;
    
    if (data) {
        // sum the data, so we can compute percentages
        CGFloat dataTotal = 0;
        for (NSNumber* datum in data) {
            dataTotal += datum.doubleValue;
        }
        
        CGFloat dataOffset = 0;
        for (NSNumber* datum in data) {
            ILBezierPath* filledPath = nil;
            CGFloat datumPercentage = (datum.doubleValue / dataTotal);
            ILColor* fillColor = sparkStyle.stackColors[[data indexOfObject:datum]];
            
            switch (sparkStyle.meterStyle) {
                case ILSparkMeterTextStyle: {
                    NSString* valueString = [NSString stringWithFormat:@"%.1f%%", datumPercentage];
                    CGRect textRect = insetRect;
                    textRect.size.height = (sparkStyle.font.pointSize * 1.5); // baseline?
                    textRect.origin.y = (((insetRect.size.height - textRect.size.height) / 2) + insetRect.origin.y);
                    
                    CATextLayer* indicatorText = [CATextLayer layer];
                    indicatorText.frame = textRect;
                    indicatorText.string = valueString;
                    indicatorText.alignmentMode = kCAAlignmentCenter;
                    indicatorText.font = (__bridge CFTypeRef _Nullable)(sparkStyle.font.fontName);
                    indicatorText.fontSize = sparkStyle.font.pointSize;
                    indicatorText.zPosition = 1.0; // frontmost?
                    indicatorText.contentsGravity = kCAGravityCenter;
                    indicatorText.foregroundColor = sparkStyle.fill.CGColor;
                    indicatorText.truncationMode = kCATruncationEnd;
                    indicatorText.contentsScale = [[ILScreen mainScreen] scale];
                    indicatorText.hidden = NO;
                    
                    [stackLayer addSublayer:indicatorText];
                    break;
                }
                case ILSparkMeterVerticalStyle: {
                    CGFloat indicatorHeight = (insetRect.size.height * datumPercentage);
                    CGFloat indicatorOffset = (insetRect.origin.y + insetRect.size.height) - (dataOffset * insetRect.size.height) - indicatorHeight;
                    CGRect filledRect = CGRectMake(insetRect.origin.x, indicatorOffset, insetRect.size.width, indicatorHeight);
                    filledPath = [ILBezierPath bezierPathWithRect:filledRect];
                    // TODO add a shape layer and position in the view
                    break;
                }
                case ILSparkMeterHorizontalStyle: {
                    CGFloat indicatorWidth = (insetRect.size.width * datumPercentage);
                    CGFloat indicatorOffset = insetRect.origin.x + (insetRect.size.width * dataOffset);
                    CGRect filledRect = CGRectMake(insetRect.origin.x + indicatorOffset, insetRect.origin.y, indicatorWidth, insetRect.size.height);
                    filledPath = [ILBezierPath bezierPathWithRect:filledRect];
                    // TODO add a shape layer and position in the view
                    break;
                }
                case ILSparkMeterSquareStyle: {
                    CGRect squareRect = ILRectSquareInRect(insetRect);
                    CGFloat indicatorSideLength = (squareRect.size.width * datumPercentage) * 2;
                    CGFloat indicatorInset = (squareRect.size.width - indicatorSideLength) / 2; // ??? take the square root?
                    CGRect filledRect = CGRectInset(squareRect, indicatorInset, indicatorInset);
                    filledPath = [ILBezierPath bezierPathWithRect:filledRect];
                    // TODO add a shape layer and position in the view
                    break;
                }
                case ILSparkMeterCircleStyle: {
                    CGRect squareRect = ILRectSquareInRect(insetRect);
                    CGFloat indicatorSideLength = (squareRect.size.width * datumPercentage) * 2;
                    CGFloat indicatorInset = (squareRect.size.width - indicatorSideLength) / 2;
                    CGRect filledRect = CGRectInset(squareRect, indicatorInset, indicatorInset);
                    filledPath = [ILBezierPath bezierPathWithOvalInRect:filledRect];
                    // TODO add a shape layer and position in the view
                    break;
                }
                case ILSparkMeterRingStyle: {
                    CGRect squareRect = ILRectSquareInRect(insetRect);
                    CGFloat indicatorSideLength = (squareRect.size.height / 2) - ILPathlineWidth;
                    CGPoint squareCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2), squareRect.origin.y + (squareRect.size.height / 2));
                    CGPoint topDeadCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2), squareCenter.y - indicatorSideLength);
                    CGFloat firstAngle = ILZeroAngleRadians + ILPercentToRadians(dataOffset);
                    CGFloat secondAngle = firstAngle + ILPercentToRadians(datumPercentage);
                    filledPath = [ILBezierPath new];
                    [filledPath addArcWithCenter:squareCenter radius:indicatorSideLength startAngle:firstAngle endAngle:secondAngle clockwise:YES];
                    CGPoint outsideEndPoint = filledPath.currentPoint;
                    CGPoint insetPoint = ILPointOnLineToPointAtDistance(outsideEndPoint, squareCenter, sparkStyle.ringWidth);
                    [filledPath addLineToPoint:insetPoint];
                    [filledPath addArcWithCenter:squareCenter radius:(indicatorSideLength - sparkStyle.ringWidth) startAngle:secondAngle endAngle:firstAngle clockwise:NO];
                    [filledPath addLineToPoint:topDeadCenter];
                    // TODO add a shape layer and position in the view
                    break;
                }
                case ILSparkMeterPieStyle: {
                    CGRect squareRect = ILRectSquareInRect(insetRect);
                    CGFloat indicatorSideLength = (squareRect.size.height / 2) - ILPathlineWidth;
                    CGPoint squareCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2), squareRect.origin.y + (squareRect.size.height / 2));
                    CGPoint topDeadCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2),squareCenter.y - indicatorSideLength);
                    CGFloat firstAngle = ILZeroAngleRadians + ILPercentToRadians(dataOffset);
                    CGFloat secondAngle = firstAngle + ILPercentToRadians(datumPercentage);
                    filledPath = [ILBezierPath new];
                    // filledPath.usesEvenOddFillRule = YES;
                    // filledPath.windingRule = NSEvenOddWindingRule;
                    [filledPath addArcWithCenter:squareCenter radius:indicatorSideLength startAngle:firstAngle endAngle:secondAngle clockwise:YES];
                    [filledPath addLineToPoint:squareCenter];
                    [filledPath addLineToPoint:topDeadCenter];
                    // TODO add a shape layer and position in the view
                    break;
                }
                case ILSparkMeterDialStyle: {
                    CGRect squareRect = ILRectSquareInRect(insetRect);
                    CGFloat indicatorSideLength = (squareRect.size.height / 2) - sparkStyle.dialWidth;
                    CGPoint squareCenter = ILPointCenteredInRect(squareRect);
                    CGFloat indicatorAngle = ILZeroAngleRadians + ILPercentToRadians(datumPercentage);
                    filledPath = [ILBezierPath new];
                    [filledPath addArcWithCenter:squareCenter radius:indicatorSideLength startAngle:indicatorAngle endAngle:indicatorAngle clockwise:YES];
                    [filledPath addLineToPoint:squareCenter];
                    // TODO add a shape layer and position in the view
                    break;
                }
            }

            dataOffset += datumPercentage;

            if (filledPath) {
                CAShapeLayer* indicatorLayer = [CAShapeLayer layer];
                indicatorLayer.path = filledPath.CGPath;
                // self.indicatorLayer.mask = self.border;
                indicatorLayer.fillColor = fillColor.CGColor;
                indicatorLayer.zPosition = (1 - datumPercentage);
                
                if (sparkStyle.meterStyle == ILSparkMeterDialStyle) {
                    indicatorLayer.strokeColor = sparkStyle.fill.CGColor;
                    indicatorLayer.lineWidth = sparkStyle.dialWidth;
                    indicatorLayer.lineCap = @"round";
                } else {
                    indicatorLayer.strokeColor = sparkStyle.stroke.CGColor;
                    indicatorLayer.lineWidth = 0;
                }
                
                [stackLayer addSublayer:indicatorLayer];
                indicatorLayer.frame = stackLayer.bounds;
            }
        }
    }
    
    return stackLayer;
}

#pragma mark - ILSparkMeter Overrides

- (void)initView
{
    [super initView];
    self.stackDataSource = nil;
}

- (void)updateView
{
    [super updateView];
    self.stackLayer = [ILSparkStack sparkStackWithData:self.stackDataSource.data size:self.frame.size sparkStyle:self.style];
    self.stackLayer.frame = self.bounds;
    self.layer.sublayers = @[self.stackLayer];
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

@implementation ILSparkStyle (ILSparkStack)

- (NSArray<ILColor*>*) stackColors
{
    NSArray<ILColor*>* stackColors = [ILSparkStack defaultStackColors];
    if (self.hints[ILSparkStackColorsHint]) {
        stackColors = self.hints[ILSparkStackColorsHint];
    }
    return stackColors;
}

@end
