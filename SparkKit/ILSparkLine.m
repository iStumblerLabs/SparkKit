#import "ILSparkLine.h"

typedef struct {
    NSTimeInterval beginning;
    NSTimeInterval duration;
}
ILTimePeriod;

#pragma mark -

@implementation ILSparkLine

+ (CAShapeLayer*) timeSeriesWithDates:(id<ILSparkLineDataSource>)data withSize:(CGSize)size dateRange:(ILTimePeriod)range
{
    CAShapeLayer* shape = [CAShapeLayer new];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint start = CGPointMake(0, 0);
    CGPathMoveToPoint(path, nil, start.x, start.y);



    [shape setPath:path];
    return shape;
}

- (void) updateView
{
    
}

@end

#if !(TARGET_OS_IPHONE || TARGET_OS_TV)

#pragma mark -

@implementation ILSparkLineCell

- (id) init
{
    if( self = [super init]) {
        self.style = [ILSparkStyle defaultStyle];
    }
    return self;
}

- (id) initWithCoder:(NSCoder*)decoder
{
    return [self init]; // TODO NSCoding?
}

- (id) initTextCell:(NSString*)aString
{
    return [self init]; // TODO put the text somewhere in the cell for reference
}

- (id) initImageCell:(NSImage*)anImage
{
    return [self init]; // TODO make the image the background of the cell
}

- (void) updateView
{
    
}

@end

#endif
