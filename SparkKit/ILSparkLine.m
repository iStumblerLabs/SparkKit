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

    // TODO add falloff to style and implement gaps in the line
    // CGMutablePathRef gaps = CGPathCreateMutable();
    // CGPathMoveToPoint(path, nil, start.x, start.y);
    for (NSDate* sampleDate in data.sampleDates) {
        NSTimeInterval sampleInterval = fabs([sampleDate timeIntervalSinceDate:startDate]);
        CGFloat samplePercent = [data sampleValueAtIndex:sampleIndex];
        CGFloat sampleX = size.width - (sampleInterval / style.scale);
        CGFloat sampleY = size.height - (size.height * samplePercent);
        CGPoint samplePoint = CGPointMake(fmin(sampleX,size.width),fmin(sampleY,size.height));

        // TODO implement filled drawing
        if (!lastDate) {
            CGPoint origin = CGPointMake(sampleX,fmin(sampleY,size.height));
            CGPathMoveToPoint(path, NULL, origin.x, origin.y);
        }

        CGPathAddLineToPoint(path, NULL, samplePoint.x, samplePoint.y);
        lastDate = sampleDate;
        sampleIndex++;

        if (fabs([lastDate timeIntervalSinceDate:startDate]) > visibleInterval) {
            break;
        }
    }

    shape.frame = CGRectMake(0, 0, size.width, size.height);
    shape.strokeColor = style.stroke.CGColor;
    shape.lineWidth = style.width;
    shape.fillColor = style.fill.CGColor;
    if (style.outline) {
        shape.borderColor = style.stroke.CGColor;
        shape.borderWidth = ILPathlineWidth;
    }
    [shape setPath:path];
    return shape;
}

#pragma mark - ILSparkView

- (void) updateView {
    for (CALayer* layer in self.layer.sublayers) { // remove all sublayers
        [layer removeFromSuperlayer];
    }

    CGSize viewSize = self.frame.size;
    CAShapeLayer* sparkLine = [ILSparkLine timeSeriesWithData:[self dataSource] size:viewSize style:self.style];
    [self.layer addSublayer:sparkLine];
    sparkLine.frame = CGRectMake(0,0,viewSize.width,viewSize.height);
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
