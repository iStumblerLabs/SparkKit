#import "ILSparkGrid.h"
#import "ILGridData.h"
#import "ILSparkStyle.h"

#import <ImageIO/ImageIO.h>

#if IL_APP_KIT
#import <CoreServices/CoreServices.h>
#endif

@interface ILSparkGrid ()
@property(nonatomic, retain) ILGridData* gridStorage;
@property(nonatomic, retain) NSArray* yAxisLabelStorage;
@property(nonatomic, retain) NSString* yAxisUnitStorage;
@property(nonatomic, retain) NSArray* xAxisLabelStorage;
@property(nonatomic, retain) NSString* xAxisUnitStorage;
@property(nonatomic, retain) NSString* errorStringStorage;

@property(nonatomic, retain) CALayer* gridLayer; // the grid data layer, an array of CALayer rows
@property(nonatomic, retain) CALayer* labelLayer; // text and labels ??? move labeling up to GaugeKit?
@property(nonatomic, assign) BOOL labelsNeedUpdate; // have the labels been updated?

@end

#pragma mark -

@implementation ILSparkGrid

#pragma mark - Properties

-(ILGridData*)grid
{
    return self.gridStorage;
}

-(void)setGrid:(ILGridData*)gridData
{
    self.gridStorage = gridData;
    gridData.delegate = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self clearGrid];
        [self updateView];
    }];
}

-(NSArray*)yAxisLabels
{
    return self.yAxisLabelStorage;
}

-(void)setYAxisLabels:(NSArray*)yAxisLabels
{
    self.yAxisLabelStorage = yAxisLabels;
    self.labelsNeedUpdate = YES;
}

-(NSString*)yAxisUnits
{
    return self.yAxisUnitStorage;
}

-(void)setYAxisUnits:(NSString*)yAxisUnits
{
    self.yAxisUnitStorage = yAxisUnits;
    self.labelsNeedUpdate = YES;
}

-(NSArray*)xAxisLabels
{
    return self.xAxisLabelStorage;
}

-(void)setXAxisLabels:(NSArray*)xAxisLabels
{
    self.xAxisLabelStorage = xAxisLabels;
    self.labelsNeedUpdate = YES;
}

-(NSString*)xAxisUnits
{
    return self.xAxisUnitStorage;
}

-(void)setXAxisUnits:(NSString*)xAxisUnits
{
    self.xAxisUnitStorage = xAxisUnits;
    self.labelsNeedUpdate = YES;
}

-(NSString*)errorString
{
    return self.errorStringStorage;
}

-(void)setErrorString:(NSString*)errorString
{
    NSString* oldError = self.errorStringStorage;
    self.errorStringStorage = errorString;
    if (oldError != errorString) { // only mark the view for updates if the error string changed
        self.labelsNeedUpdate = YES;
    }
}

#pragma mark - Computed Properties

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

#pragma mark - ILViews

-(void)initView
{
#if IL_APP_KIT
    [self setLayer:[CALayer new]];
    [self setWantsLayer:YES];
#endif

    self.grid = nil;
    self.style = [ILSparkStyle defaultStyle];
    
    self.gridLayer = [CALayer new];
    [self.layer addSublayer:self.gridLayer];
    self.gridLayer.frame = self.layer.bounds;
    self.gridLayer.contentsGravity = kCAGravityResize;

    self.labelLayer = [CALayer new];
    [self.layer addSublayer:self.labelLayer];
    self.labelLayer.frame = self.layer.bounds;
}

-(void)clearGrid
{
    self.gridLayer.sublayers = nil; // clear grid layer
    self.gridLayer.contents = nil;
}

-(void)drawGrid // one shot, redraw the entire grid into self.gridLayer
{
#if DEBUG
    NSTimeInterval drawStart = [[NSDate new] timeIntervalSinceReferenceDate];
#endif
    BOOL drawAlpha = YES;
    
    [CATransaction setValue:@(0.01) forKey:kCATransactionAnimationDuration]; // TODO use the time between updates
    self.gridLayer.frame = self.layer.bounds;

    CGImageRef gridBits = nil;
    
    if (drawAlpha) {
        gridBits = [self.grid alphaBitmapWithRange:self.valueRange];
        
        // create a mask layer
        CALayer* maskLayer = [CALayer new];
        maskLayer.contents = CFBridgingRelease(gridBits);
        maskLayer.magnificationFilter = kCAFilterNearest;
        maskLayer.frame = self.layer.bounds;
        
        // make sure the color are updated
        self.layer.backgroundColor = self.style.background.CGColor;
        self.gridLayer.backgroundColor = self.style.fill.CGColor;
        
        self.gridLayer.mask = maskLayer;
    }
    else {
        gridBits = [self.grid grayscaleBitmapWithRange:self.valueRange];
        self.gridLayer.contents = CFBridgingRelease(gridBits);
        self.gridLayer.magnificationFilter = kCAFilterNearest; // kCAFilterLinear;
    }

#if DEBUG
    NSTimeInterval drawDone = [[NSDate new] timeIntervalSinceReferenceDate];
    NSTimeInterval drawTime = (drawDone - drawStart);
    CATextLayer* debugLayer = [CATextLayer new];
    size_t imageBytesPerRow = CGImageGetBytesPerRow(gridBits);
    size_t imageWidth = CGImageGetWidth(gridBits);
    size_t imageHeight = CGImageGetHeight(gridBits);
    size_t imageBytes = (imageHeight * imageBytesPerRow);
    debugLayer.string = [NSString stringWithFormat:@"%@ (grid %lu x %lu) [image %lu x %lu] %lu bytes on %lu layers in %fs",
                         self.className, self.grid.columns, self.grid.rows, imageWidth, imageHeight, imageBytes,
                         (self.layer.sublayers.count + self.gridLayer.sublayers.count + self.labelLayer.sublayers.count), drawTime];
    debugLayer.font = (__bridge CFTypeRef _Nullable)self.style.font.fontName;
    debugLayer.fontSize = 14;
    debugLayer.frame = CGRectMake(10, (self.frame.size.height - 25), (self.frame.size.width - 10), 20);
    self.gridLayer.sublayers = nil;
    [self.gridLayer addSublayer:debugLayer];
#endif

    [CATransaction commit];

    /*
    self.gridLayer.sublayers = nil;

    NSUInteger thisRow = 0;
    while (thisRow < self.grid.rows) {
        CALayer* rowLayer = [CALayer new];
        [self.gridLayer addSublayer:rowLayer];
        rowLayer.contents = CFBridgingRelease([self.grid grayscaleBitmapOfRow:thisRow]);
        rowLayer.frame = [self rectOfRow:thisRow];
        rowLayer.magnificationFilter = kCAFilterNearest; // kCAFilterLinear;
        thisRow++;
    }
    */
}

-(void)updateGrid
{
    [CATransaction begin];
    [CATransaction setValue:@(0.1) forKey:kCATransactionAnimationDuration]; // TODO use the time between updates
    NSUInteger thisRow = 0;
    for (CALayer* rowLayer in self.gridLayer.sublayers) {
        rowLayer.frame = [self rectOfRow:thisRow];
        thisRow++;
    }
    [CATransaction commit];
}

-(void)updateLabels
{
    if (self.labelsNeedUpdate) {
        [CATransaction setValue:@(0.1) forKey:kCATransactionAnimationDuration]; // TODO use the time between updates

        self.labelLayer.frame = self.layer.bounds;
        self.labelLayer.sublayers = nil;
        self.labelLayer.zPosition = 1.0; // frontmost
        
        if (self.errorString) { // put it on a text layer in the middle
            CATextLayer* errorLayer = [CATextLayer layer];
            [self.labelLayer addSublayer:errorLayer];
            errorLayer.bounds = CGRectMake(0,0,200,50);
            errorLayer.contentsGravity = kCAGravityCenter;
            errorLayer.string = self.errorString;
            errorLayer.font = (__bridge CFTypeRef _Nullable)self.style.font.fontName;
            errorLayer.fontSize = self.style.font.pointSize;
            errorLayer.foregroundColor = self.style.fontColor.CGColor;
            errorLayer.alignmentMode = kCAAlignmentCenter;
            errorLayer.position = ILPointCenteredInRect(self.labelLayer.frame);
    #if IL_APP_KIT
            NSLog(@"error: %@ frame: %@", self.errorString, NSStringFromRect(errorLayer.frame));
    #endif
        }
        else {
            // TODO special case for single value, place it at the bottom left
            if (self.yAxisLabels && self.yAxisLabels.count > 0) {
                CGFloat ySpacing = (self.labelLayer.frame.size.height / (self.yAxisLabels.count + 1)); // fencepost
                NSUInteger yIndex = 1; // fencepost
                for (NSString* yLabel in self.yAxisLabels) {
                    CATextLayer* labelLayer = [CATextLayer layer];
                    [self.labelLayer addSublayer:labelLayer];
                    if (self.yAxisUnits) {
                        labelLayer.string = [NSString stringWithFormat:@"%@ %@", yLabel, self.yAxisUnits];
                    }
                    else {
                        labelLayer.string = yLabel;
                    }
                    labelLayer.contentsGravity = kCAGravityCenter;
                    labelLayer.font = (__bridge CFTypeRef _Nullable)(self.style.font.fontName);
                    labelLayer.fontSize = self.style.font.pointSize;
                    labelLayer.foregroundColor = self.style.fontColor.CGColor;
                    labelLayer.frame = CGRectMake(10,(ySpacing * yIndex), 100, 25);
                    yIndex++;
                }
            }
            
            if (self.xAxisLabels && self.xAxisLabels.count > 0) {
                CGFloat xSpacing = (self.labelLayer.frame.size.width / (self.xAxisLabels.count + 1)); // fencepost
                NSUInteger xIndex = 1; // fencepost
                for (NSString* xLabel in self.xAxisLabels) {
                    CATextLayer* labelLayer = [CATextLayer layer];
                    [self.labelLayer addSublayer:labelLayer];
                    if (self.xAxisUnits) {
                        labelLayer.string = [NSString stringWithFormat:@"%@ %@", xLabel, self.xAxisUnits];
                    }
                    else {
                        labelLayer.string = xLabel;
                    }
                    labelLayer.font = (__bridge CFTypeRef _Nullable)(self.style.font.fontName);
                    labelLayer.fontSize = self.style.font.pointSize;
                    labelLayer.foregroundColor = self.style.fontColor.CGColor;
                    labelLayer.contentsGravity = kCAGravityCenter;
                    labelLayer.frame = CGRectMake((xSpacing * xIndex), 5, 50, 25);
                    xIndex++;
                }
            }
        }
        
        [CATransaction commit];
        self.labelsNeedUpdate = NO;
    }
}

-(void)updateView
{
    // self.layer.sublayers = nil; // TODO use the gridLayer
    self.layer.backgroundColor = self.style.background.CGColor;

    if (!self.grid) {
        self.errorString = @"No Data";
        [self clearGrid];
    }
    else if ( self.grid.rows == 0 || self.grid.columns == 0) {
        self.errorString = @"Not Enough Data";
        [self clearGrid];
    }
    else {
        self.errorString = nil;
        [self drawGrid];
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

#pragma mark - ILGridDataDelegate

- (void) grid:(ILGridData*)grid didSetData:(NSData*)data atRow:(NSUInteger)row
{
    NSLog(@"grid:%@ didSetData:%lu Bytes atRow:%lu", grid, (unsigned long)data.length, row);
    // TODO udpate the gridLayer
}

- (void) grid:(ILGridData*)grid didAppendedData:(NSData*)data asRow:(NSUInteger)row
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self updateView];
    }];
/*
    self.gridLayer.frame = self.layer.bounds;

    // TODO move this to a different queue???
    CGImageRef rowImage = [self bitmapOfRow:row];

    // move the existing rows down inside of an animation context
        [CATransaction begin];
        [self updateGrid];
        
        CALayer* rowLayer = [CALayer new];
        [self.gridLayer addSublayer:rowLayer];
        rowLayer.frame = [self rectOfRow:row];
        rowLayer.contents = CFBridgingRelease(rowImage);
        
        NSLog(@"grid:%@ didAppendedData:%lu Bytes asRow:%lu", grid, data.length, row);
        [CATransaction commit];
*/
}

- (void) grid:(ILGridData*)grid willTrimToRangeOfRows:(NSRange)rows
{
//    NSLog(@"grid:%@ willTrimToRangeOfRows:(%lu,%lu)", grid, rows.location, rows.length);
    // TODO update the gridLayer
}

@end
