#import "ILGridView.h"
#import "ILGridData.h"
#import "ILSparkStyle.h"

#import <CoreServices/CoreServices.h>
#import <ImageIO/ImageIO.h>

@interface ILGridView ()

@property(nonatomic, retain) NSMutableArray* rowCache; // mutable array of row images or references maybe?
@property(nonatomic, retain) CALayer* gridLayer; // the grid data layer, an array of CALayer rows
@property(nonatomic, retain) CALayer* labelLayer; // text and labels ??? move labeling up to GaugeKit?

@end

#pragma mark -

@implementation ILGridView

-(CGFloat)rowHeight
{
    return ((self.frame.size.height > self.grid.rows) ? (self.frame.size.height / self.grid.rows) : 1.0);
}

-(CGFloat)columnWidth
{
    return ((self.frame.size.width > self.grid.columns) ? (self.frame.size.width / self.grid.columns) : 1.0);
}

-(CGSize)cellSize
{
   return CGSizeMake([self rowHeight], [self columnWidth]);
}

-(CGRect)rectOfRow:(NSUInteger)thisRow
{
    CGFloat rowHeight = [self rowHeight];
    return CGRectMake(0, (rowHeight * thisRow), self.frame.size.width, rowHeight);
}

-(CGImageRef)bitmapOfRow:(NSUInteger)thisRow
{
    static struct CGColorSpace* grayscale;
    if (!grayscale) {
        grayscale = CGColorSpaceCreateDeviceGray();
    }

    size_t channelDepth = 8;
    size_t channelCount = CGColorSpaceGetNumberOfComponents(grayscale);
    size_t pixelBits = (channelDepth * channelCount);
    CGSize rowSize = CGSizeMake(self.grid.columns, 1);
    NSMutableData* imageData = [NSMutableData dataWithLength:(pixelBits * rowSize.width)];
    CGContextRef rowContext = CGBitmapContextCreate(imageData.mutableBytes, rowSize.width, rowSize.height, pixelBits, imageData.length, grayscale, kCGImageAlphaNone);
    CGContextSetFillColorSpace(rowContext, grayscale);

    NSUInteger thisColumn = 0;
    while (thisColumn < self.grid.columns) {
        CGFloat percentValue = [self.grid percentAtRow:thisRow column:thisColumn];
        const CGFloat percentComponents[] = {(1.0 - percentValue),  1.0};
        CGContextSetFillColor(rowContext, (const CGFloat*)&percentComponents);
        // CGContextSetAlpha(rowContext, (1.0 - percentValue));
        CGContextFillRect(rowContext, CGRectMake(thisColumn, 0, 1, rowSize.height)); // single pixel
        thisColumn++;
    }

    CGImageRef rowBitMap = CGBitmapContextCreateImage(rowContext);
    CGContextRelease(rowContext);
exit:
    return rowBitMap;
}

#pragma mark - ILViews

-(void)initView
{
#if IL_APP_KIT
    [self setLayer:[CALayer new]];
    [self setWantsLayer:YES];
#endif

    self.grid = nil;
    self.style = [ILSparkStyle defaultStyle];
    self.rowCache = [NSMutableArray new];
}

-(void)updateGrid
{
    // NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    NSUInteger thisRow = 0;
    while (thisRow < self.grid.rows) {
        CGImageRef rowImage = [self bitmapOfRow:thisRow];
        CALayer* rowLayer = [CALayer new];
        [self.layer addSublayer:rowLayer];
        rowLayer.contents = CFBridgingRelease(rowImage);
        rowLayer.frame = [self rectOfRow:thisRow];
        // rowLayer.magnificationFilter = kCAFilterLinear; // kCAFilterNearest;

        // rowLayer.mask = [CALayer new];
        // rowLayer.mask.contentsGravity = kCAGravityResize;
        // rowLayer.mask.frame = rowLayer.bounds;

        /*
        CFURLRef imageURL = CFBridgingRetain([NSURL fileURLWithPath:
            [NSString stringWithFormat:[@"~/Desktop/Grid/at-%f-row-%lu.png" stringByExpandingTildeInPath], now, thisRow]]);
        CGImageDestinationRef rowDestination = CGImageDestinationCreateWithURL(imageURL, kUTTypePNG, 1, NULL);
        CGImageDestinationAddImage(rowDestination, rowImage, NULL);
        CGImageDestinationFinalize(rowDestination);
        */
        
        // NSLog(@"row: %lu %@ %@", thisRow, NSStringFromRect(rowLayer.frame), rowLayer.contents);
        thisRow++;
    }
    // NSLog(@"sublayers: %lu", self.layer.sublayers.count);
}

-(void)updateLabels
{
    if (!self.labelLayer) {
        self.labelLayer = [CALayer new];
    }
    
    [self.layer addSublayer:self.labelLayer];
    self.labelLayer.sublayers = nil;
    self.labelLayer.frame = self.frame;
    
    if (self.errorString) { // put it on a text layer in the middle
        CATextLayer* errorLayer = [CATextLayer new];
        errorLayer.contentsGravity = kCAGravityCenter;
        errorLayer.string = self.errorString;
        errorLayer.font = CFBridgingRetain(self.style.font.fontName);
        [self.labelLayer addSublayer:errorLayer];
        errorLayer.position = CGPointMake((self.frame.size.width / 2), (self.frame.size.height / 2)); // No CGPointCenteredInRect?
#if IL_APP_KIT
        NSLog(@"error: %@ frame: %@", self.errorString, NSStringFromRect(errorLayer.frame));
#endif
    }
    else {
        if (self.yAxisLabels && self.yAxisLabels.count > 0) {
            CGFloat ySpacing = (self.frame.size.width / (self.yAxisLabels.count + 1)); // fencepost
            NSUInteger yIndex = 1; // fencepost
            for (NSString* yLabel in self.yAxisLabels) {
                CATextLayer* labelLayer = [CATextLayer new];
                labelLayer.string = yLabel;
                labelLayer.contentsGravity = @"center";
                labelLayer.frame = CGRectMake(10,(ySpacing * yIndex), 100, 100);
                [self.labelLayer addSublayer:labelLayer];
                yIndex++;
            }
        }
        
        if (self.xAxisLabels) {
            CGFloat xSpacing = (self.frame.size.width / (self.yAxisLabels.count + 1)); // fencepost
            NSUInteger xIndex = 1; // fencepost
            for (NSString* xLabel in self.yAxisLabels) {
                CATextLayer* labelLayer = [CATextLayer new];
                labelLayer.string = xLabel;
                labelLayer.contentsGravity = @"center";
                labelLayer.frame = CGRectMake((xSpacing * xIndex), 10, 100, 100);
                [self.labelLayer addSublayer:labelLayer];
                xIndex++;
            }
        }
    }
    
}

-(void)updateView
{
    self.layer.sublayers = nil; // TODO use the gridLayer
    // self.layer.backgroundColor = self.style.fill.CGColor;

    CGSize cellSize = CGSizeMake((self.frame.size.width / self.grid.columns), (self.frame.size.height / self.grid.rows));

    if (!self.grid) {
        self.errorString = @"No Data";
    }
    else if (cellSize.width < 1 || cellSize.height < 1) {
        self.errorString = @"Too Much Data";
    }
    else if ( self.grid.rows == 0 || self.grid.columns == 0) {
        self.errorString = @"Not Enough Data";
    }
    else {
        [self updateGrid];
    }

    [self updateLabels];
}

#pragma mark - NSCoding

- (nullable instancetype) initWithCoder:(NSCoder*)aDecoder; // NS_DESIGNATED_INITIALIZER
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initView];
    }
    return self;
}

#if IL_APP_KIT

#pragma mark - NSView

- (instancetype) initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

#pragma mark - NSNibAwakening

- (void) awakeFromNib
{
    [self initView];
}

#endif

#if NO

#pragma mark -

- (void) drawError:(NSString*)errorString
{
    NSCell* labelCell = [[NSCell alloc] initTextCell:errorString];
    NSMutableParagraphStyle* centered = [NSMutableParagraphStyle new];
    centered.alignment = NSCenterTextAlignment;
    NSDictionary* labelAttrs = @{
        NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]],
        NSForegroundColorAttributeName: [NSColor controlTextColor],
        NSParagraphStyleAttributeName: centered
    };
    
    NSAttributedString* tooSmall = [[NSAttributedString alloc] initWithString:errorString attributes:labelAttrs];
    NSRect tooSmallRect = NSMakeRect(0,0,tooSmall.size.width*2,tooSmall.size.height*2);
    tooSmallRect = NSOffsetRect(tooSmallRect,
        ((self.frame.size.width-tooSmall.size.width)/2),
        ((self.frame.size.height-tooSmall.size.height)/2));
    [labelCell setAttributedStringValue:tooSmall];
    [labelCell drawInteriorWithFrame:tooSmallRect inView:self];
}

#pragma mark - NSView

- (void) drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    [self.style.background setFill]; // assume 'average' and show deviation from it as lighter to darker values
    [NSBezierPath fillRect:dirtyRect];
    [NSGraphicsContext restoreGraphicsState];

    NSCell* labelCell = [[NSCell alloc] initTextCell:@""];
    
    if (self.grid ) {
        NSSize cellSize = NSMakeSize(self.frame.size.width/self.grid.columns,self.frame.size.height/self.grid.rows);
        
        if (cellSize.width < 1 || cellSize.height < 1) {
            [self drawError:@"Too Much Data"];
            return;
        }
        else if ( self.grid.rows == 0 || self.grid.columns == 0) {
            [self drawError:@"Not Enough Data"];
            return;
        }
        
        NSDate* start = [NSDate date];
        NSUInteger thisRow = 0;
        NSInteger drawCount = 0;

        while (thisRow < self.grid.rows) {
            NSUInteger thisColumn = 0;
            while (thisColumn < self.grid.columns) {
                NSRect thisRect = NSMakeRect(
                    (cellSize.width * thisColumn), (cellSize.height * thisRow),
                    cellSize.width, cellSize.height);
                // thisRect = NSInsetRect(thisRect, self.cellInsets.width, self.cellInsets.height);
                thisRect = NSIntegralRect(thisRect);
                float percentValue = [self.grid percentAtRow:thisRow column:thisColumn];
                NSColor* thisColor = [self.style.gradient interpolatedColorAtLocation:percentValue];
                // NSLog(@"grid (%lu,%lu) ((%li - %li) / %li) -> %f -> %@",
                //    thisColumn, thisRow, thisValue, self.minValue, self.maxValue, thisFloat, thisColor);
                [NSGraphicsContext saveGraphicsState];
                [thisColor setFill];
                [NSBezierPath fillRect:thisRect];
                [NSGraphicsContext restoreGraphicsState];
                drawCount++;
                thisColumn++;
            }
            thisRow++;
        }
        
        if (fabs([start timeIntervalSinceNow]) > 0.1) { // 10fps
            NSLog(@"slow draw of: %@ (%lu,%lu) %li ops in in %0.4fs",
                  self.grid, (unsigned long)self.grid.columns, (unsigned long)self.grid.rows, (long)drawCount, fabs([start timeIntervalSinceNow]));
        }

        if (self.yAxisLabels) { // draw these along the y axis
            NSMutableParagraphStyle* left = [NSMutableParagraphStyle new];
            left.alignment = NSLeftTextAlignment;
            NSDictionary* labelAttrs = @{
                NSFontAttributeName: self.style.font,
                NSForegroundColorAttributeName: [NSColor lightGrayColor],
                NSParagraphStyleAttributeName: left
            };
            
            NSUInteger labelIndex = 0;
            while( labelIndex < self.yAxisLabels.count && cellSize.height > 8)
            {
                NSRect labelRect = NSMakeRect(8,(cellSize.height*labelIndex)-16,100,cellSize.height);
                labelRect = NSIntegralRect(labelRect);
                NSObject* object = self.yAxisLabels[labelIndex];
                NSString* label = [object description];
                NSAttributedString* yLabel = [[NSAttributedString alloc] initWithString:label attributes:labelAttrs];
                [labelCell setAttributedStringValue:yLabel];
                [labelCell drawInteriorWithFrame:labelRect inView:self];
                labelIndex++;
            }
        }
        
        if (self.xAxisLabels) { // draw these along the x axis
            NSMutableParagraphStyle* centered = [NSMutableParagraphStyle new];
            centered.alignment = NSCenterTextAlignment;
            NSDictionary* labelAttrs = @{
                NSFontAttributeName: self.style.font,
                NSForegroundColorAttributeName: [NSColor lightGrayColor],
                NSParagraphStyleAttributeName: centered
            };
            
            NSUInteger labelIndex = 0;
            while (labelIndex < self.xAxisLabels.count) {
                NSRect labelRect = NSMakeRect(cellSize.width*labelIndex,self.frame.size.height-26,cellSize.width,22);
                NSObject* object = self.xAxisLabels[labelIndex];
                NSString* label = [object description];
                NSAttributedString* xLabel = [[NSAttributedString alloc] initWithString:label attributes:labelAttrs];
                [labelCell setAttributedStringValue:xLabel];
                [labelCell drawInteriorWithFrame:labelRect inView:self];
                // NSLog(@" %@ -> %@", label, NSStringFromSize(labelSize));
                labelIndex++;
            }
        }
    }
    else {
        [self drawError:@"No Data"];
        return;
    }
}

#endif

@end
