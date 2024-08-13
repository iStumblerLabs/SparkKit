#import "ILSparkLine.h"

NSString* const ILSparkLineScaleFactor = @"ILSparkLineScaleFactor";
NSString* const ILSparkLineFalloffInterval = @"ILSparkLineFalloffTInterval";

// MARK: -

@interface ILSparkStyle (ILSparkLine)
@property(nonatomic, readonly) CGFloat scale;
@property(nonatomic, readonly) NSTimeInterval falloff;

@end

// MARK: -

@implementation ILSparkLine

+ (CALayer*) timeSeriesWithData:(NSObject<ILSparkLineDataSource>*)data size:(CGSize)size style:(ILSparkStyle*)style {
    CALayer* seriesLayer = [CALayer new];
    NSArray* sampleDates = nil;
    NSDate* startDate = [NSDate date];
    NSDate* lastDate = nil;
    CGMutablePathRef path = CGPathCreateMutable();
    CGMutablePathRef gaps = CGPathCreateMutable();
    NSTimeInterval visibleInterval = (size.width * style.scale);
    NSUInteger sampleIndex = 0;
    CGPoint firstPoint = CGPointZero;
    CGPoint lastPoint = CGPointZero;
    BOOL wasGap = NO; // YES if the last segment was a gap

    if ([data respondsToSelector:@selector(sampleDatesInPeriod:)]) {
        NSDate* earliestDate = [startDate dateByAddingTimeInterval:-visibleInterval];
        ILTimePeriod visiblePeriod = {[earliestDate timeIntervalSince1970], visibleInterval};
        sampleDates = [data sampleDatesInPeriod:visiblePeriod];
    }
    else {
        sampleDates = data.sampleDates;
    }

    for (NSDate* sampleDate in sampleDates) {
        NSTimeInterval sampleInterval = fabs([sampleDate timeIntervalSinceDate:startDate]);
        CGFloat samplePercent = [data sampleValueAtIndex:sampleIndex];
        CGFloat sampleX = size.width - (sampleInterval / style.scale);
        CGFloat sampleY = (size.height * samplePercent);
        CGPoint thisPoint = CGPointMake(fmin(sampleX,size.width),fmin(sampleY,size.height));

        if (!lastDate) {
            firstPoint = thisPoint;
            if (style.filled) {
                CGPathMoveToPoint(path, NULL, firstPoint.x, size.height); // start at the baseline
                CGPathAddLineToPoint(path, NULL, thisPoint.x, thisPoint.y);
            }
            else {
                CGPathMoveToPoint(path, NULL, thisPoint.x, thisPoint.y);
            }
        }

        // NSLog(@"line to -> %f,%f", sampleX, sampleY);
        if (lastDate && (style.falloff > 0) && ((lastPoint.x - thisPoint.x) > style.falloff)) {
            if (style.filled) {
                CGPathAddLineToPoint(path, NULL, lastPoint.x, size.height); // drop it to the baseline
                CGPathMoveToPoint(path, NULL, thisPoint.x, size.height); // move along to the current point
            }
            else {
                CGPathMoveToPoint(path, NULL, thisPoint.x, thisPoint.y);
            }
            // draw the gap segment
            CGPathMoveToPoint(gaps, NULL, lastPoint.x, lastPoint.y);
            CGPathAddLineToPoint(gaps, NULL, thisPoint.x, thisPoint.y);
            wasGap = YES;
        }
        else {
            if (wasGap && style.filled) {
                CGPathAddLineToPoint(path, NULL, lastPoint.x, lastPoint.y);
            }
            CGPathAddLineToPoint(path, NULL, thisPoint.x, thisPoint.y);
            wasGap = NO;
        }

        lastPoint = thisPoint;
        lastDate = sampleDate;
        sampleIndex++;

        // have we reached the edge of the view?
        if (fabs([lastDate timeIntervalSinceDate:startDate]) > visibleInterval) {
            if (style.filled) {
                CGPathAddLineToPoint(path, NULL, thisPoint.x, size.height); // drop it do the baseline
            }
            break;
        }
    }

    if (style.filled) { // bring the line back to the baseline
        CGPathAddLineToPoint(path, NULL, lastPoint.x, size.height);
        CGPathAddLineToPoint(path, NULL, firstPoint.x, size.height);
    }


    CAShapeLayer* pathLayer = [CAShapeLayer new];
    pathLayer.path = path;
    pathLayer.strokeColor = style.stroke.CGColor;
    pathLayer.lineWidth = style.width;
    pathLayer.fillColor = (style.filled ? style.fill.CGColor : style.background.CGColor);
    [seriesLayer addSublayer:pathLayer];

    if (style.falloff >  0) {
        CAShapeLayer* gapsLayer = [CAShapeLayer new];
        gapsLayer.path = gaps;
        gapsLayer.strokeColor = [ILColor grayColor].CGColor;
        gapsLayer.lineWidth = style.width;
        gapsLayer.lineDashPattern = @[@(3), @(2)];
        gapsLayer.frame = CGRectMake(0,0,size.width,size.height);
        [seriesLayer addSublayer:gapsLayer];
    }

exit:
    CFRelease(path);
    CFRelease(gaps);

    return seriesLayer;
}

// MARK: - ILSparkView

- (void) updateView {
    [CATransaction begin];
    [CATransaction setValue:@(1 / 60) forKey:kCATransactionAnimationDuration]; // TODO use the time between updates

    for (CALayer* layer in [self.layer.sublayers copy]) { // remove all sublayers
       [layer removeFromSuperlayer];
    }

    [super updateView];

    CGRect insetRect = self.borderInset;
    CALayer* sparkLine = [ILSparkLine timeSeriesWithData:[self dataSource] size:insetRect.size style:self.style];
    [self.layer addSublayer:sparkLine];
    sparkLine.frame = insetRect;
    [CATransaction commit];
}

@end

// MARK: -

@implementation ILSparkStyle (ILSparkLine)

- (CGFloat) scale {
    CGFloat scale = 1.0;
    if (self.hints[ILSparkLineScaleFactor]) {
        scale = [self.hints[ILSparkLineScaleFactor] doubleValue];
    }
    return scale;
}

- (NSTimeInterval) falloff {
    NSTimeInterval falloff = 0.0;
    if (self.hints[ILSparkLineFalloffInterval]) {
        falloff = [self.hints[ILSparkLineFalloffInterval] doubleValue];
    }
    return falloff;
}

@end


#if IL_APP_KIT

// MARK: -

@implementation ILSparkLineCell

- (void) initCell {
    self.style = [ILSparkStyle defaultStyle];
}

// MARK: - NSObject

- (id) init {
    if (self = [super init]) {
        [self initCell];
    }
    return self;
}

// MARK: - NSCell

- (id) initTextCell:(NSString*)aString {
    if (self = [super initTextCell:aString]) {
        [self initCell];
    }
    return self;
}

- (id) initImageCell:(NSImage*)anImage {
    if (self = [super initImageCell:anImage]) {
        [self initCell];
    }
    return self;
}

- (void)drawWithFrame:(NSRect)rect inView:(NSView *)view {
    if ([self.representedObject conformsToProtocol:@protocol(ILSparkLineDataSource)]) {
        CALayer* sparkLine = [ILSparkLine timeSeriesWithData:[self representedObject] size:rect.size style:self.style];
        [[view layer] addSublayer:sparkLine];
        sparkLine.frame = rect;
    }
}

@end

#endif
