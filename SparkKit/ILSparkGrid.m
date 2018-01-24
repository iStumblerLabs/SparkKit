#import "ILSparkGrid.h"
#import "ILGridData.h"
#import "ILSparkStyle.h"

#import <ImageIO/ImageIO.h>

#if IL_APP_KIT
#import <CoreServices/CoreServices.h>
#endif

@interface ILSparkGrid ()
@property(nonatomic, retain) ILGridData* gridStorage;
@property(nonatomic, retain) CALayer* gridLayer; // the grid data layer, an array of CALayer rows

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
    return CGRectIntegral(CGRectMake(0, (self.frame.size.height - (rowHeight * (thisRow + 1))), self.frame.size.width, rowHeight));
}

-(CGRect)rectOfColumn:(NSUInteger)thisColumn
{
    CGFloat columnWidth = [self columnWidth];
    return CGRectMake((columnWidth * thisColumn), 0, columnWidth, self.frame.size.height);
}

#pragma mark - ILViews

-(void)initView
{
    [super initView];

    self.grid = nil;
    self.style = [ILSparkStyle defaultStyle];
    
    self.gridLayer = [CALayer new];
    [self.layer addSublayer:self.gridLayer];
    self.gridLayer.frame = self.layer.bounds;
    self.gridLayer.contentsGravity = kCAGravityResize;
}

-(void)clearGrid
{
    self.gridLayer.sublayers = nil; // clear grid layer
    self.gridLayer.contents = nil;
}

-(void)drawGrid // one shot, redraw the entire grid into self.gridLayer
{
    [CATransaction begin];
    [CATransaction setValue:@(0.1) forKey:kCATransactionAnimationDuration]; // TODO use the time between updates
#if DEBUG
    NSTimeInterval drawStart = [[NSDate new] timeIntervalSinceReferenceDate];
#endif
    self.gridLayer.frame = self.layer.bounds;
    self.gridLayer.sublayers = nil; // TODO retain existing layer and only draw new ones
    self.gridLayer.backgroundColor = self.style.fill.CGColor;

    CGImageRef gridBits = nil;
    
    NSUInteger rowIndex = 0;
    while (rowIndex < self.grid.rows) {
        CGImageRef sliceImage = [self.grid alphaBitmapOfRow:rowIndex withRange:self.valueRange];
        CALayer* sliceLayer = [CALayer new];
        sliceLayer.contents = CFBridgingRelease(sliceImage);
        sliceLayer.magnificationFilter = kCAFilterNearest;
        sliceLayer.backgroundColor = self.style.background.CGColor;
        [self.gridLayer addSublayer:sliceLayer];
        sliceLayer.frame = [self rectOfRow:rowIndex];
        rowIndex++;
    }

#if DEBUG
    NSTimeInterval drawDone = [[NSDate new] timeIntervalSinceReferenceDate];
    NSTimeInterval drawTime = (drawDone - drawStart);
    size_t imageBytesPerRow = CGImageGetBytesPerRow(gridBits);
    size_t imageWidth = CGImageGetWidth(gridBits);
    size_t imageHeight = CGImageGetHeight(gridBits);
    size_t imageBytes = (imageHeight * imageBytesPerRow);
    CATextLayer* debugLayer = [CATextLayer layer];
    debugLayer.string = [NSString stringWithFormat:@"%@ (grid %lu x %lu) [image %lu x %lu] %lu bytes in %0.8fs",
                                                   self, self.grid.columns, self.grid.rows, imageWidth, imageHeight, imageBytes, drawTime];
    ILFont* debugFont = [ILFont userFixedPitchFontOfSize:11];
    CGSize textSize = [debugLayer.string sizeWithAttributes:@{NSFontAttributeName: debugFont}];
    debugLayer.font = (__bridge CFTypeRef _Nullable)debugFont.fontName;
    debugLayer.fontSize = debugFont.pointSize;
    debugLayer.contentsScale = [[ILScreen mainScreen] scale];
    debugLayer.frame = CGRectMake((debugFont.pointSize * 4), (self.gridLayer.bounds.size.height - (textSize.height + (debugFont.pointSize * 4))), textSize.width, textSize.height);
    [self.gridLayer addSublayer:debugLayer];
#endif

    [CATransaction commit];
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

-(void)updateView
{
    // self.layer.sublayers = nil; // TODO use the gridLayer
    // self.layer.backgroundColor = self.style.background.CGColor;

    if (!self.grid || self.grid.rows == 0 || self.grid.columns == 0) {
        self.errorString = NSLocalizedString(@"No Data", @"No Data Avaliable to Graph");
        [self clearGrid];
    }
    else {
        self.errorString = nil;
        [self drawGrid];
    }

    [super updateView];
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
