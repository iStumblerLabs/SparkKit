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

// MARK: -

@implementation ILSparkGrid

// MARK: - Properties

-(ILGridData*)grid {
    return self.gridStorage;
}

-(void)setGrid:(ILGridData*)gridData {
    self.gridStorage = gridData;
    gridData.delegate = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self clearGrid];
        [self updateView];
    }];
}

// MARK: - Computed Properties

-(CGFloat)rowHeight {
    return ((self.frame.size.height > self.grid.rows) ? (self.frame.size.height / self.grid.rows) : 1.0);
}

-(CGFloat)columnWidth {
    return ((self.frame.size.width > self.grid.columns) ? (self.frame.size.width / self.grid.columns) : 1.0);
}

-(CGSize)cellSize {
   return CGSizeMake([self rowHeight], [self columnWidth]);
}

-(CGRect)rectOfRow:(NSUInteger)thisRow {
    CGFloat rowHeight = [self rowHeight];
    return CGRectIntegral(CGRectMake(0, (self.frame.size.height - (rowHeight * (thisRow + 1))), self.frame.size.width, rowHeight));
}

-(CGRect)rectOfColumn:(NSUInteger)thisColumn {
    CGFloat columnWidth = [self columnWidth];
    return CGRectMake((columnWidth * thisColumn), 0, columnWidth, self.frame.size.height);
}

// MARK: - ILViews

-(void)initView {
    [super initView];

    self.grid = nil;
    self.style = [ILSparkStyle defaultStyle];
    
    self.gridLayer = [CALayer new];
    [self.layer addSublayer:self.gridLayer];
    self.gridLayer.frame = self.layer.bounds;
    self.gridLayer.contentsGravity = kCAGravityResize;
}

-(void)clearGrid {
    self.gridLayer.sublayers = nil; // clear grid layer
    self.gridLayer.contents = nil;
}

-(void)drawGrid { // one shot, redraw the entire grid into self.gridLayer
    [CATransaction begin];
    [CATransaction setValue:@(1 / 60) forKey:kCATransactionAnimationDuration]; // TODO use the time between updates
#if DEBUG
    NSTimeInterval drawStart = NSDate.timeIntervalSinceReferenceDate;
#endif
    self.gridLayer.frame = self.layer.bounds;
    self.gridLayer.sublayers = nil; // TODO retain existing layer and only draw new ones
    self.gridLayer.backgroundColor = self.style.fill.CGColor;

    
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
    NSTimeInterval drawDone = NSDate.timeIntervalSinceReferenceDate;
    NSTimeInterval drawTime = (drawDone - drawStart);
    if (drawTime > (1.0f / 15)) { // warn if we drop below 15 fps
        NSLog(@"%@ [%lu x %lu] %lu tiles in %0.6fs", self, (unsigned long)self.grid.columns, (unsigned long)self.grid.rows, (unsigned long)(self.grid.columns * self.grid.rows), drawTime);
    }
#endif

    [CATransaction commit];
}

-(void)updateGrid {
    [CATransaction begin];
    [CATransaction setValue:@(0.1) forKey:kCATransactionAnimationDuration]; // TODO use the time between updates
    NSUInteger thisRow = 0;
    for (CALayer* rowLayer in self.gridLayer.sublayers) {
        rowLayer.frame = [self rectOfRow:thisRow];
        thisRow++;
    }
    [CATransaction commit];
}

-(void)updateView {
    // self.layer.sublayers = nil; // TODO use the gridLayer
    // self.layer.backgroundColor = self.style.background.CGColor;

    if (!self.grid || self.grid.rows == 0 || self.grid.columns == 0) {
        NSString* errorString = @"No Data";
        if (self.style.L10Nbundle) {
            errorString = [self.style.L10Nbundle localizedStringForKey:errorString value:errorString table:nil];
        }
        self.errorString = errorString;
        [self clearGrid];
    }
    else {
        self.errorString = nil;
        [self drawGrid];
    }

    [super updateView];
}

// MARK: - NSCoding

- (nullable instancetype) initWithCoder:(NSCoder*)aDecoder { // NS_DESIGNATED_INITIALIZER
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initView];
    }
    return self;
}

#if IL_APP_KIT

// MARK: - NSView

- (instancetype) initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

// MARK: - NSNibAwakening

- (void) awakeFromNib {
    [self initView];
}

#endif

// MARK: - ILGridDataDelegate

- (void) grid:(ILGridData*)grid didSetData:(NSData*)data atRow:(NSUInteger)row {
    NSLog(@"grid:%@ didSetData:%lu Bytes atRow:%lu", grid, (unsigned long)data.length, (unsigned long)row);
    // TODO udpate the gridLayer
}

- (void) grid:(ILGridData*)grid didAppendedData:(NSData*)data asRow:(NSUInteger)rowIndex {
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        NSUInteger layerIndex = 0;
        NSMutableArray* oldLayers = NSMutableArray.new;
        CALayer* sliceLayer = CALayer.new;
        CGImageRef sliceImage = [self.grid alphaBitmapOfRow:rowIndex withRange:self.valueRange];
        sliceLayer.contents = CFBridgingRelease(sliceImage);
        sliceLayer.magnificationFilter = kCAFilterNearest;
        sliceLayer.backgroundColor = self.style.background.CGColor;

        // move the existing rows down inside of an animation context
        [CATransaction begin];
        NSUInteger layerCount = self.gridLayer.sublayers.count;
        for (CALayer* rowLayer in self.gridLayer.sublayers) {
            if (layerCount > (rowIndex + 1)) { // remove the layer
                [oldLayers addObject:rowLayer];
                layerCount--;
            }
            else { // move the layer into place
                rowLayer.frame = [self rectOfRow:++layerIndex];
            }
        }
        
        for (CALayer* rowLayer in oldLayers) {
            [rowLayer removeFromSuperlayer];
        }

        // now add the new row
        [self.gridLayer addSublayer:sliceLayer];
        sliceLayer.frame = [self rectOfRow:rowIndex];

        [CATransaction commit];
        // NSLog(@"grid:%@ didAppendedData: %lu Bytes atRow:%lu height:%f", grid, data.length, rowIndex, self.rowHeight);
        [super updateView];
    }];
}

- (void) grid:(ILGridData*)grid willTrimToRangeOfRows:(NSRange)rows {
//    NSLog(@"grid:%@ willTrimToRangeOfRows:(%lu,%lu)", grid, rows.location, rows.length);
    // TODO update the gridLayer
}

@end
