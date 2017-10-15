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

    [[NSNotificationCenter defaultCenter] addObserverForName:NSViewFrameDidChangeNotification object:self queue:nil usingBlock:^(NSNotification* note) {
        self.labelsNeedUpdate = YES;
        [self updateView];
    }];
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

static const CGFloat labelMargin = 15;

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
    size_t imageBytesPerRow = CGImageGetBytesPerRow(gridBits);
    size_t imageWidth = CGImageGetWidth(gridBits);
    size_t imageHeight = CGImageGetHeight(gridBits);
    size_t imageBytes = (imageHeight * imageBytesPerRow);
    CATextLayer* debugLayer = [CATextLayer layer];
    debugLayer.string = [NSString stringWithFormat:@"%@ (grid %lu x %lu) [image %lu x %lu] %lu bytes on %lu layers in %0.8fs",
                                                   self.className, self.grid.columns, self.grid.rows, imageWidth, imageHeight, imageBytes,
                                                   (self.layer.sublayers.count + self.gridLayer.sublayers.count + self.labelLayer.sublayers.count), drawTime];
    ILFont* debugFont = [ILFont userFixedPitchFontOfSize:11];
    CGSize textSize = [debugLayer.string sizeWithAttributes:@{NSFontAttributeName: debugFont}];
    debugLayer.font = (__bridge CFTypeRef _Nullable)debugFont.fontName;
    debugLayer.fontSize = debugFont.pointSize;
    debugLayer.contentsScale = [[ILScreen mainScreen] scale];
    debugLayer.frame = CGRectMake(labelMargin, (self.gridLayer.bounds.size.height - (textSize.height + (labelMargin * 3))), textSize.width, textSize.height);
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

- (NSString*) stringForValue:(id)value units:(NSString*)units
{
    NSString* label = [value description];
    if (units) {
        label = [NSString stringWithFormat:@"%@ %@", value, units];
    }
    return label;
}

- (CATextLayer*) layerForLabel:(NSString*)label
{
    CATextLayer* labelLayer = [CATextLayer layer];
    labelLayer.string = label;
    labelLayer.contentsGravity = kCAGravityCenter;
    labelLayer.font = (__bridge CFTypeRef _Nullable)self.style.font.fontName;
    labelLayer.fontSize = self.style.font.pointSize;
    labelLayer.foregroundColor = self.style.fontColor.CGColor;
    labelLayer.contentsScale = [[ILScreen mainScreen] scale];
    labelLayer.backgroundColor = [ILColor colorWithDeviceWhite:1.0 alpha:0.25].CGColor;
    labelLayer.allowsFontSubpixelQuantization = YES;
    CGSize textSize = [label sizeWithAttributes:@{NSFontAttributeName: self.style.font}];
    labelLayer.bounds = CGRectMake(0, 0, textSize.width, textSize.height);
    [self.labelLayer addSublayer:labelLayer];
    return labelLayer;
}

- (void) updateLabels // TODO move these up to gauge kit
{
    if (self.labelsNeedUpdate) {
        [CATransaction setValue:@(0.1) forKey:kCATransactionAnimationDuration]; // TODO use the time between updates

        CGRect bounds = self.layer.bounds;
        self.labelLayer.frame = bounds;
        self.labelLayer.sublayers = nil;
        self.labelLayer.zPosition = 1.0; // frontmost
        
        if (self.errorString) { // put it on a text layer in the middle
            CATextLayer* errorLayer = [self layerForLabel:self.errorString];
            errorLayer.alignmentMode = kCAAlignmentCenter;
            errorLayer.position = ILPointCenteredInRect(self.labelLayer.frame);
    #if IL_APP_KIT
            NSLog(@"error: %@ frame: %@", self.errorString, NSStringFromRect(errorLayer.frame));
    #endif
        }
        else {
            if (self.yAxisLabels) {
                NSUInteger yLabelCount = self.yAxisLabels.count;
                if (yLabelCount == 1) { // top left
                    CATextLayer* label = [self layerForLabel:[self stringForValue:self.yAxisLabels.lastObject units:self.yAxisUnits]];
                    label.alignmentMode = kCAAlignmentLeft;
                    label.frame = CGRectMake(labelMargin, (bounds.size.height - (label.bounds.size.height + labelMargin)),
                                             label.bounds.size.width, label.bounds.size.height);
                }
                else if (yLabelCount == 2) { // in the corners
                    CATextLayer* topLabel = [self layerForLabel:[self stringForValue:self.yAxisLabels[0] units:self.yAxisUnits]];
                    topLabel.alignmentMode = kCAAlignmentLeft;
                    topLabel.frame = CGRectMake(labelMargin, (bounds.size.height - (topLabel.bounds.size.height + labelMargin)),
                                             topLabel.bounds.size.width, topLabel.bounds.size.height);
                    
                    if (self.xAxisLabels.count >= 2) { // special case to deal with collsions
                        if (![self.xAxisLabels[0] isEqual:self.yAxisLabels[1]]) { // skip the duplicate case
                            CGFloat bottomOffset = (labelMargin * 3); // offset the label above the x axis label
                            CATextLayer* bottomLabel = [self layerForLabel:[self stringForValue:self.yAxisLabels[1] units:self.yAxisUnits]];
                            bottomLabel.alignmentMode = kCAAlignmentLeft;
                            bottomLabel.frame = CGRectMake(labelMargin, bottomOffset, bottomLabel.bounds.size.width, bottomLabel.bounds.size.height);
                        }
                    }
                    else {
                        CATextLayer* bottomLabel = [self layerForLabel:[self stringForValue:self.yAxisLabels[1] units:self.yAxisUnits]];
                        bottomLabel.alignmentMode = kCAAlignmentLeft;
                        bottomLabel.frame = CGRectMake(labelMargin, labelMargin, bottomLabel.bounds.size.width, bottomLabel.bounds.size.height);
                    }
                }
                else if (yLabelCount == self.grid.rows) { // centered over each row
                    CGFloat labelGap = (bounds.size.height / yLabelCount);
                    CGFloat labelOffset = (labelGap / 2);
                    CGFloat labelIndex = 1;
                    for (id yLabel in self.yAxisLabels) {
                        CATextLayer* label = [self layerForLabel:[self stringForValue:yLabel units:self.yAxisUnits]];
                        label.alignmentMode = kCAAlignmentLeft;
                        CGFloat yPosition = bounds.size.height - ((labelGap * labelIndex) + (label.frame.size.height / 2) - labelOffset);
                        label.frame = CGRectMake(labelMargin, yPosition, label.bounds.size.width, label.bounds.size.height);
                        // check sitations with too many labels
                        if ((labelIndex == 1) && (labelGap < (label.bounds.size.height * 1.5))) { // too many vertical labels to print
                            // move it to the top-left position
                            label.frame = CGRectMake(labelMargin, (bounds.size.height - (label.bounds.size.height + labelMargin)),
                                                     label.bounds.size.width, label.bounds.size.height);

                            CATextLayer* bottomLabel = [self layerForLabel:[self stringForValue:self.yAxisLabels.lastObject units:self.yAxisUnits]];
                            CGFloat bottomOffset = (labelMargin * 3); // offset the label above the x axis label
                            bottomLabel.alignmentMode = kCAAlignmentLeft;
                            bottomLabel.frame = CGRectMake(labelMargin, bottomOffset, bottomLabel.bounds.size.width, bottomLabel.bounds.size.height);
                            break; // skip the rest
                        }
                        else if ((yLabel == self.yAxisLabels.lastObject) && (self.xAxisLabels.count >= 2) && (labelGap < (label.frame.size.height * 4))) {
                            [label removeFromSuperlayer]; // yoink
                        }
                        labelIndex++;
                        // NSLog(@"%@ -> %@", yLabel, ILStringFromCGRect(label.frame));
                    }
                }
                else if (yLabelCount > 2) {
                    CATextLayer* topLabel = [self layerForLabel:[self stringForValue:self.yAxisLabels[0] units:self.yAxisUnits]];
                    topLabel.alignmentMode = kCAAlignmentLeft;
                    topLabel.frame = CGRectMake(labelMargin, (bounds.size.height - (topLabel.bounds.size.height + labelMargin)),
                                                topLabel.bounds.size.width, topLabel.bounds.size.height);
                    
                    CGFloat labelGap = (bounds.size.height / (yLabelCount - 1));
                    if (self.xAxisLabels.count >= 2) { // deal with collsions
                        if (labelGap > (topLabel.bounds.size.height * 3)) { // scoot up, if there is room
                            CATextLayer* bottomLabel = [self layerForLabel:[self stringForValue:self.yAxisLabels.lastObject units:self.yAxisUnits]];
                            CGFloat bottomOffset = (labelMargin * 3); // offset the label above the x axis label
                            bottomLabel.alignmentMode = kCAAlignmentLeft;
                            bottomLabel.frame = CGRectMake(labelMargin, bottomOffset, bottomLabel.bounds.size.width, bottomLabel.bounds.size.height);
                        }
                    }
                    
                    NSUInteger labelIndex = 1;
                    while (labelIndex < (yLabelCount - 1)) {
                        CATextLayer* middleLabel = [self layerForLabel:[self stringForValue:self.yAxisLabels[labelIndex] units:self.yAxisUnits]];
                        CGFloat yPosition = ((labelGap * labelIndex) - (middleLabel.bounds.size.height / 2));
                        middleLabel.alignmentMode = kCAAlignmentLeft;
                        middleLabel.frame = CGRectMake(labelMargin, yPosition,
                                                       middleLabel.bounds.size.width, middleLabel.bounds.size.height);
                        labelIndex++;
                    }
                }
            }
            
            if (self.xAxisLabels) {
                NSUInteger xLabelCount = self.xAxisLabels.count;
                if (xLabelCount == 1) { // bottom left
                    CATextLayer* label = [self layerForLabel:[self stringForValue:self.xAxisLabels.lastObject units:self.xAxisUnits]];
                    label.alignmentMode = kCAAlignmentLeft;
                    label.frame = CGRectMake(labelMargin, labelMargin, label.bounds.size.width, label.bounds.size.height);
                }
                else if (xLabelCount == 2) { // in the corners
                    CATextLayer* leftLabel = [self layerForLabel:[self stringForValue:self.xAxisLabels[0] units:self.xAxisUnits]];
                    leftLabel.alignmentMode = kCAAlignmentLeft;
                    leftLabel.frame = CGRectMake(labelMargin, labelMargin, leftLabel.bounds.size.width, leftLabel.bounds.size.height);
                    
                    CATextLayer* rightLabel = [self layerForLabel:[self stringForValue:self.xAxisLabels[1] units:self.xAxisUnits]];
                    rightLabel.alignmentMode = kCAAlignmentRight;
                    rightLabel.frame = CGRectMake((bounds.size.width - rightLabel.bounds.size.width - labelMargin), labelMargin,
                                                   rightLabel.bounds.size.width, rightLabel.bounds.size.height);
                }
                else if (xLabelCount == self.grid.columns) { // centered over each column
                    CGFloat labelGap = (bounds.size.width / xLabelCount);
                    CGFloat labelOffset = (labelGap / 2);
                    CGFloat labelIndex = 1;
                    for (id xLabel in self.xAxisLabels) {
                        CATextLayer* label = [self layerForLabel:[self stringForValue:xLabel units:self.xAxisUnits]];
                        label.alignmentMode = kCAAlignmentCenter;
                        CGFloat xPosition = ((labelGap * (labelIndex - 1)) - (label.bounds.size.width / 2) + labelOffset);
                        label.frame = CGRectMake(xPosition, labelMargin, label.bounds.size.width, label.bounds.size.height);
                        if ((labelIndex == 1) && (labelGap < (label.bounds.size.width * 5))) {
                            label.frame = CGRectMake(labelMargin, labelMargin, label.bounds.size.width, label.bounds.size.height);

                            CATextLayer* rightLabel = [self layerForLabel:[self stringForValue:self.xAxisLabels.lastObject units:self.xAxisUnits]];
                            rightLabel.alignmentMode = kCAAlignmentRight;
                            rightLabel.frame = CGRectMake((bounds.size.width - rightLabel.bounds.size.width - labelMargin), labelMargin,
                                                          rightLabel.bounds.size.width, rightLabel.bounds.size.height);
                            break;
                        }
                        labelIndex++;
                        // NSLog(@"%@ -> %@", yLabel, ILStringFromCGRect(label.frame));
                    }
                }
                else if (xLabelCount > 2) {
                    CATextLayer* leftLabel = [self layerForLabel:[self stringForValue:self.xAxisLabels[0] units:self.xAxisUnits]];
                    leftLabel.alignmentMode = kCAAlignmentLeft;
                    leftLabel.frame = CGRectMake(labelMargin, labelMargin, leftLabel.bounds.size.width, leftLabel.bounds.size.height);
                    
                    CATextLayer* rightLabel = [self layerForLabel:[self stringForValue:self.xAxisLabels.lastObject units:self.xAxisUnits]];
                    rightLabel.alignmentMode = kCAAlignmentRight;
                    rightLabel.frame = CGRectMake((bounds.size.width - rightLabel.bounds.size.width - labelMargin), labelMargin,
                                                  rightLabel.bounds.size.width, rightLabel.bounds.size.height);

                    CGFloat labelGap = ((bounds.size.width - leftLabel.bounds.size.width - rightLabel.bounds.size.width) / (xLabelCount - 1)); // fencepost
                    if (labelGap > fmax(leftLabel.frame.size.width, rightLabel.frame.size.width)) { // we have room to draw the in-between values
                        CGFloat labelOffset = leftLabel.bounds.size.width;
                        NSUInteger labelIndex = 1; // skip first
                        while (labelIndex < (xLabelCount - 1)) { // skip last
                            CATextLayer* middleLabel = [self layerForLabel:[self stringForValue:self.xAxisLabels[labelIndex] units:self.xAxisUnits]];
                            CGFloat xPosition = labelOffset + ((labelGap * labelIndex) - (middleLabel.bounds.size.width / 2));
                            middleLabel.alignmentMode = kCAAlignmentCenter;
                            middleLabel.frame = CGRectMake(xPosition, labelMargin, middleLabel.bounds.size.width, middleLabel.bounds.size.height);
                            labelIndex++;
                        }
                    }
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
