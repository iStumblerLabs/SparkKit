#import "ILSparkLine.h"

#pragma mark -

@implementation ILSparkLine

+ (CAShapeLayer*) timeSeriesWithData:(id<ILSparkLineDataSource>)data size:(CGSize)size style:(ILSparkStyle*)style
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGMutablePathRef gaps = CGPathCreateMutable();
    NSTimeInterval visibleInterval = (size.width * style.scale);
    NSUInteger sampleIndex = 0;
    NSDate* startDate = [NSDate date];
    NSDate* lastDate = nil;
    CGPoint firstPoint = CGPointZero;
    CGPoint lastPoint = CGPointZero;

    for (NSDate* sampleDate in data.sampleDates) {
        NSTimeInterval sampleInterval = fabs([sampleDate timeIntervalSinceDate:startDate]);
        CGFloat samplePercent = [data sampleValueAtIndex:sampleIndex];
        CGFloat sampleX = size.width - (sampleInterval / style.scale);
        CGFloat sampleY = size.height - (size.height * samplePercent);
        CGPoint thisPoint = CGPointMake(fmin(sampleX,size.width),fmin(sampleY,size.height));

        if (!lastDate) {
            if (style.filled) {
                firstPoint = CGPointMake(thisPoint.x, 0);
                CGPathMoveToPoint(path, NULL, firstPoint.x, firstPoint.y);
            }

            CGPathMoveToPoint(path, NULL, thisPoint.x, thisPoint.y);
        }

        // NSLog(@"line to -> %f,%f", sampleX, sampleY);
        if (lastDate && (style.falloff > 0) && ((lastPoint.x - thisPoint.x) > style.falloff)) {
            if (style.filled) {
                CGPathMoveToPoint(path, NULL, lastPoint.x, 0); // drop it do the baseline
                CGPathMoveToPoint(path, NULL, thisPoint.x, 0); // move along to the current point
            }
            else {
                CGPathMoveToPoint(path, NULL, thisPoint.x, thisPoint.y);
            }
            // draw the gap segment
            CGPathMoveToPoint(gaps, NULL, lastPoint.x, lastPoint.y);
            CGPathAddLineToPoint(gaps, NULL, thisPoint.x, thisPoint.y);
        }
        else {
            CGPathAddLineToPoint(path, NULL, thisPoint.x, thisPoint.y);
        }

        lastPoint = thisPoint;
        lastDate = sampleDate;
        sampleIndex++;

        if (fabs([lastDate timeIntervalSinceDate:startDate]) > visibleInterval) {
            break;
        }
    }

    if (style.filled) { // bring the line back to the baseline
        CGPathAddLineToPoint(path, NULL, lastPoint.x, 0);
        CGPathAddLineToPoint(path, NULL, firstPoint.x, 0);
    }

    CAShapeLayer* pathLayer = [CAShapeLayer new];
    pathLayer.strokeColor = style.stroke.CGColor;
    pathLayer.lineWidth = style.width;
    pathLayer.fillColor = (style.filled ? style.fill.CGColor : style.background.CGColor);
    [pathLayer setPath:path];

    if (style.falloff >  0) {
        CAShapeLayer* gapsLayer = [CAShapeLayer new];
        gapsLayer.strokeColor = [ILColor redColor].CGColor;
        gapsLayer.lineWidth = style.width;
        gapsLayer.lineDashPattern = @[@(1), @(1)];
        gapsLayer.frame = CGRectMake(0,0,size.width,size.height);
        [pathLayer addSublayer:gapsLayer];
    }
exit:
    CFRelease(path);
    CFRelease(gaps);

    return pathLayer;
}

#pragma mark - ILSparkView

- (void) updateView {
    [super updateView];

    CGSize viewSize = self.frame.size;
    CAShapeLayer* sparkLine = [ILSparkLine timeSeriesWithData:[self dataSource] size:viewSize style:self.style];
    [self.layer addSublayer:sparkLine];
    sparkLine.frame = self.bounds;
}

@end

#if !(TARGET_OS_IPHONE || TARGET_OS_TV)

#pragma mark -

@implementation ILSparkLineCell

#pragma mark - NSObject

- (id) init
{
    if( self = [super init]) {
        self.style = [ILSparkStyle defaultStyle];
    }
    return self;
}

#pragma mark - NSCell

- (id) initTextCell:(NSString*)aString
{
    return [self init]; // TODO put the text somewhere in the cell for reference
}

- (id) initImageCell:(NSImage*)anImage
{
    return [self init]; // TODO make the image the background of the cell
}

- (void)drawWithFrame:(NSRect)rect inView:(NSView *)view
{
    if ([[self representedObject] conformsToProtocol:@protocol(ILSparkLineDataSource)]) {
        CAShapeLayer* sparkLine = [ILSparkLine timeSeriesWithData:[self representedObject] size:rect.size style:self.style];
        [[view layer] addSublayer:sparkLine];
        sparkLine.frame = rect;
    }
}

@end

#endif
