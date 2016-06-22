#import "ILSparkLine.h"

#pragma mark -

@implementation ILSparkLine

+ (CAShapeLayer*) timeSeriesWithData:(id<ILSparkLineDataSource>)data size:(CGSize)size style:(ILSparkStyle*)style
{
    CAShapeLayer* shape = [CAShapeLayer new];
    CGMutablePathRef path = CGPathCreateMutable();
    NSTimeInterval visibleInterval = (size.width * style.scale);
    NSUInteger sampleIndex = 0;
    NSDate* startDate = [NSDate date];
    NSDate* lastDate = nil;
    CGPoint firstPoint = CGPointZero;
    CGPoint lastPoint = CGPointZero;

    // TODO add falloff to style and implement gaps in the line
    // CGMutablePathRef gaps = CGPathCreateMutable();
    // CGPathMoveToPoint(path, nil, start.x, start.y);
    for (NSDate* sampleDate in data.sampleDates) {
        NSTimeInterval sampleInterval = fabs([sampleDate timeIntervalSinceDate:startDate]);
        CGFloat samplePercent = [data sampleValueAtIndex:sampleIndex];
        CGFloat sampleX = size.width - (sampleInterval / style.scale);
        CGFloat sampleY = size.height - (size.height * samplePercent);
        lastPoint = CGPointMake(fmin(sampleX,size.width),fmin(sampleY,size.height));

        // TODO implement filled drawing
        if (!lastDate) {
            if (style.filled) {
                firstPoint = CGPointMake(lastPoint.x, 0);
                CGPathMoveToPoint(path, NULL, firstPoint.x, firstPoint.y);
            }

            CGPathMoveToPoint(path, NULL, lastPoint.x, lastPoint.y);
        }

        // NSLog(@"line to -> %f,%f", sampleX, sampleY);

        CGPathAddLineToPoint(path, NULL, lastPoint.x, lastPoint.y);
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

    shape.strokeColor = style.stroke.CGColor;
    shape.lineWidth = style.width;
    shape.fillColor = (style.filled ? style.fill.CGColor : style.background.CGColor);
    [shape setPath:path];
    return shape;
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
