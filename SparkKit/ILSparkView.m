#import "ILSparkView.h"
#import "ILSparkStyle.h"


#pragma mark -

@interface ILSparkView ()
@property(nonatomic, retain) ILSparkStyle* styleStorage;
@property(nonatomic, retain) CAShapeLayer* borderLayerStorage;
@property(nonatomic, retain) CALayer* labelLayer;
@property(nonatomic, assign) BOOL labelsNeedUpdate;
@property(nonatomic, retain) NSArray* yAxisLabelStorage;
@property(nonatomic, retain) NSString* yAxisUnitStorage;
@property(nonatomic, retain) NSArray* xAxisLabelStorage;
@property(nonatomic, retain) NSString* xAxisUnitStorage;
@property(nonatomic, retain) NSString* errorStringStorage;

@end

@implementation ILSparkView

- (ILSparkStyle*) style
{
    ILSparkStyle* effectiveStyle = nil;
    
    if (self.styleStorage) {
        effectiveStyle = self.styleStorage;
    }
    else {
        effectiveStyle = [ILSparkStyle defaultStyle];
    }
    
    return effectiveStyle;
}

- (void) setStyle:(ILSparkStyle *)style
{
    self.styleStorage = style;
}

#pragma mark - Labels

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

- (NSString*) stringForValue:(id)value units:(NSString*)units
{
    NSString* label = [value description];
    if (units) {
        label = [NSString stringWithFormat:@"%@ %@", value, units];
    }
    return label;
}

static const CGFloat labelAlpha = 0.3;
static const CGFloat labelRadius = 6;
static const CGFloat labelMargin = 12;

- (CATextLayer*) layerForLabel:(NSString*)label
{
    CATextLayer* labelLayer = [CATextLayer layer];
    labelLayer.string = label;
    labelLayer.contentsGravity = kCAGravityCenter;
    labelLayer.font = (__bridge CFTypeRef _Nullable)self.style.font.fontName;
    labelLayer.fontSize = self.style.font.pointSize;
    labelLayer.foregroundColor = self.style.fontColor.CGColor;
    labelLayer.contentsScale = [[ILScreen mainScreen] scale];
    labelLayer.backgroundColor = [ILColor colorWithDeviceWhite:1.0 alpha:labelAlpha].CGColor;
    labelLayer.allowsFontSubpixelQuantization = YES;
    labelLayer.cornerRadius = labelRadius;
    labelLayer.alignmentMode = kCAAlignmentCenter;

    CGSize textSize = [label sizeWithAttributes:@{NSFontAttributeName: self.style.font}];
    labelLayer.bounds = CGRectMake(0, 0, (textSize.width + labelMargin), textSize.height);
    [self.labelLayer addSublayer:labelLayer];
    return labelLayer;
}

#pragma mark - ILView

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    
    return self;
}

#pragma mark - NSCoder

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initView];
    }
    
    return self;
}

#ifdef IL_APP_KIT
#pragma mark - NSView

- (void)setFrameSize:(NSSize)newSize;
{
    [super setFrameSize:newSize];
    self.borderLayerStorage = nil;
    [self updateView];
}

- (BOOL) isFlipped
{
    return YES;
}
#endif

#pragma mark - border

- (CAShapeLayer*) border
{
    if (!self.borderLayerStorage) {
        if (self.isCircular) {
            self.borderLayerStorage = [CAShapeLayer new];
            CGRect square = CGRectInset(ILRectSquareInRect(self.bounds), (self.style.width / 2), (self.style.width / 2));
            CGPathRef squarePath = CGPathCreateWithEllipseInRect(square, NULL);
            self.borderLayerStorage.path = squarePath;
            CGPathRelease(squarePath);
        }
        else {
            self.borderLayerStorage = [CAShapeLayer new];
            CGRect insetRect = CGRectInset(self.bounds, (self.style.width / 2), (self.style.width / 2));
            CGPathRef borderPath = CGPathCreateWithRect(insetRect, NULL);
            self.borderLayerStorage.path = borderPath;
            CGPathRelease(borderPath);
        }
    }
    return self.borderLayerStorage;
}

- (BOOL) isCircular
{
    return NO;
}

- (CGRect) borderInset
{
    CGRect insetRect = CGRectZero;

    if (self.style.bordered) {
        CGFloat inset = (self.style.width * 2);
        insetRect = CGRectInset(self.bounds, inset, inset);
    }
    else {
        insetRect = self.bounds;
    }

    return insetRect;
}

#pragma mark - ILViews

- (void) initView
{
#if IL_APP_KIT
    [self setLayer:[CALayer new]];
    [self setWantsLayer:YES];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSViewFrameDidChangeNotification object:self queue:nil usingBlock:^(NSNotification* note) {
        self.labelsNeedUpdate = YES;
        [self updateView];
    }];
#endif

    self.style = [ILSparkStyle defaultStyle];

    self.labelLayer = [CALayer new];
    [self.layer addSublayer:self.labelLayer];
    self.labelLayer.frame = self.layer.bounds;
}

- (void) updateView
{
    [CATransaction begin];
    [CATransaction setValue:@(0.1) forKey:kCATransactionAnimationDuration]; // TODO use the time between updates

    if (self.labelsNeedUpdate) {
        CGRect bounds = self.layer.bounds;
        self.labelLayer.frame = bounds;
        self.labelLayer.sublayers = nil;
        self.labelLayer.zPosition = 1.0; // frontmost
        
        if (self.errorString) { // put it on a text layer in the middle
            CATextLayer* errorLayer = [self layerForLabel:self.errorString];
            errorLayer.position = ILPointCenteredInRect(self.labelLayer.frame);
            // NSLog(@"%@ error: %@ frame: %@", self.className, self.errorString, ILStringFromCGRect(errorLayer.frame));
        }
        else {
            if (self.yAxisLabels) {
                NSUInteger yLabelCount = self.yAxisLabels.count;
                if (self.yAxisLabelsCenteredOnRows) { // centered over each row
                    CGFloat labelGap = (bounds.size.height / yLabelCount);
                    CGFloat labelOffset = (labelGap / 2);
                    CGFloat labelIndex = 0;
                    for (id yLabel in self.yAxisLabels) {
                        CATextLayer* label = [self layerForLabel:[self stringForValue:yLabel units:self.yAxisUnits]];
                        CGFloat yPosition = ((labelGap * labelIndex) + labelOffset - (label.bounds.size.height / 2));
                        label.frame = CGRectMake(labelMargin, yPosition, label.bounds.size.width, label.bounds.size.height);
                        // check sitations with too many labels
                        if ((labelIndex == 0) && (labelGap < (label.bounds.size.height * 1.5))) { // too many vertical labels to print
                            // move it to the top-left position
                            label.frame = CGRectMake(labelMargin, labelMargin, label.bounds.size.width, label.bounds.size.height);
                            
                            CATextLayer* bottomLabel = [self layerForLabel:[self stringForValue:self.yAxisLabels.lastObject units:self.yAxisUnits]];
                            CGFloat bottomOffset = (labelMargin * 3); // offset the label above the x axis label
                            bottomLabel.frame = CGRectMake(labelMargin,
                                                           (bounds.size.height - bottomLabel.bounds.size.height - bottomOffset),
                                                           bottomLabel.bounds.size.width,
                                                           bottomLabel.bounds.size.height);
                            break; // skip the rest
                        }
                        else if ((yLabel == self.yAxisLabels.lastObject) && (self.xAxisLabels.count >= 2) && (labelGap < (label.frame.size.height * 4))) {
                            [label removeFromSuperlayer]; // yoink
                        }
                        labelIndex++;
                        // NSLog(@"%@ -> %@", yLabel, ILStringFromCGRect(label.frame));
                    }
                }
                else if (yLabelCount > 0) { // top left
                    CATextLayer* topLabel = [self layerForLabel:[self stringForValue:self.yAxisLabels[0] units:self.yAxisUnits]];
                    topLabel.frame = CGRectMake(labelMargin, labelMargin, topLabel.bounds.size.width, topLabel.bounds.size.height);

                    if (yLabelCount >= 2) {
                        CGFloat labelGap = (bounds.size.height / (yLabelCount - 1));
                        if (self.xAxisLabels.count >= 2) { // deal with collsions
                            if (![self.xAxisLabels[0] isEqual:self.yAxisLabels[1]] // skip the duplicate case
                             && (labelGap > (topLabel.bounds.size.height * 4))) { // scoot up, if there is room
                                CATextLayer* bottomLabel = [self layerForLabel:[self stringForValue:self.yAxisLabels.lastObject units:self.yAxisUnits]];
                                CGFloat bottomOffset = (labelMargin * 3); // offset the label above the x axis label
                                bottomLabel.frame = CGRectMake(labelMargin,
                                                               (bounds.size.height - bottomLabel.bounds.size.height - bottomOffset),
                                                               bottomLabel.bounds.size.width,
                                                               bottomLabel.bounds.size.height);
                            }
                        }
                        else {
                            CATextLayer* bottomLabel = [self layerForLabel:[self stringForValue:self.yAxisLabels[1] units:self.yAxisUnits]];
                            bottomLabel.frame = CGRectMake(labelMargin, labelMargin, bottomLabel.bounds.size.width, bottomLabel.bounds.size.height);
                        }

                        if ((yLabelCount > 2) && (labelGap > (topLabel.bounds.size.height * 1.5))) { // add middle values if there's room
                            NSUInteger labelIndex = 1;
                            while (labelIndex < (yLabelCount - 1)) {
                                CATextLayer* middleLabel = [self layerForLabel:[self stringForValue:self.yAxisLabels[labelIndex] units:self.yAxisUnits]];
                                CGFloat yPosition = ((labelGap * labelIndex) - (middleLabel.bounds.size.height / 2));
                                middleLabel.frame = CGRectMake(labelMargin, yPosition,
                                                               middleLabel.bounds.size.width, middleLabel.bounds.size.height);
                                labelIndex++;
                            }
                        }
                    }
                }
            }
            
            if (self.xAxisLabels) {
                NSUInteger xLabelCount = self.xAxisLabels.count;
                if (self.xAxisLabelsCenteredOnColumns) { // centered over each column
                    CGFloat labelGap = (bounds.size.width / xLabelCount);
                    CGFloat labelOffset = (labelGap / 2);
                    CGFloat labelIndex = 1;
                    for (id xLabel in self.xAxisLabels) {
                        CATextLayer* label = [self layerForLabel:[self stringForValue:xLabel units:self.xAxisUnits]];
                        CGFloat xPosition = ((labelGap * (labelIndex - 1)) - (label.bounds.size.width / 2) + labelOffset);
                        label.frame = CGRectMake(xPosition, labelMargin, label.bounds.size.width, label.bounds.size.height);
                        if ((labelIndex == 1) && (labelGap < (label.bounds.size.width * 5))) {
                            label.frame = CGRectMake(labelMargin,
                                                     (bounds.size.height - label.bounds.size.height - labelMargin),
                                                     label.bounds.size.width,
                                                     label.bounds.size.height);
                            
                            CATextLayer* rightLabel = [self layerForLabel:[self stringForValue:self.xAxisLabels.lastObject units:self.xAxisUnits]];
                            rightLabel.frame = CGRectMake((bounds.size.width - rightLabel.bounds.size.width - labelMargin),
                                                          (bounds.size.height - rightLabel.bounds.size.height - labelMargin),
                                                          rightLabel.bounds.size.width,
                                                          rightLabel.bounds.size.height);
                            break;
                        }
                        labelIndex++;
                        // NSLog(@"%@ -> %@", yLabel, ILStringFromCGRect(label.frame));
                    }
                }
                else if (xLabelCount > 0) {
                    CATextLayer* leftLabel = [self layerForLabel:[self stringForValue:self.xAxisLabels[0] units:self.xAxisUnits]];
                    leftLabel.frame = CGRectMake(labelMargin, (bounds.size.height - leftLabel.bounds.size.height - labelMargin), leftLabel.bounds.size.width, leftLabel.bounds.size.height);
                    
                    if (xLabelCount >= 2) {
                        CATextLayer* rightLabel = [self layerForLabel:[self stringForValue:self.xAxisLabels.lastObject units:self.xAxisUnits]];
                        rightLabel.frame = CGRectMake((bounds.size.width - rightLabel.bounds.size.width - labelMargin),
                                                      (bounds.size.height - rightLabel.bounds.size.height - labelMargin),
                                                      rightLabel.bounds.size.width,
                                                      rightLabel.bounds.size.height);
                        
                        CGFloat labelGap = ((bounds.size.width - leftLabel.bounds.size.width - rightLabel.bounds.size.width) / (xLabelCount - 1)); // fencepost
                        if ((xLabelCount > 2) && (labelGap > fmax(leftLabel.frame.size.width, rightLabel.frame.size.width))) { // we have room to draw the in-between values
                            CGFloat labelOffset = leftLabel.bounds.size.width;
                            NSUInteger labelIndex = 1; // skip first
                            while (labelIndex < (xLabelCount - 1)) { // skip last
                                CATextLayer* middleLabel = [self layerForLabel:[self stringForValue:self.xAxisLabels[labelIndex] units:self.xAxisUnits]];
                                CGFloat xPosition = labelOffset + ((labelGap * labelIndex) - (middleLabel.bounds.size.width / 2));
                                middleLabel.frame = CGRectMake(xPosition,
                                                               (bounds.size.height - middleLabel.bounds.size.height - labelMargin),
                                                               middleLabel.bounds.size.width,
                                                               middleLabel.bounds.size.height);
                                labelIndex++;
                            }
                        }
                    }
                }
            }
        }
        
        self.labelsNeedUpdate = NO;
    }

    // udpate the border view
    if (self.style.bordered) {
        CAShapeLayer* borderLayer = self.border;
        borderLayer.fillColor = self.style.background.CGColor;
        borderLayer.lineWidth = self.style.width;
        borderLayer.strokeColor = self.style.border.CGColor;
        borderLayer.zPosition = -1;
        if (![self.layer.sublayers containsObject:borderLayer]) {
            [self.layer addSublayer:borderLayer];
        }
    }

    [CATransaction commit];
}

@end
