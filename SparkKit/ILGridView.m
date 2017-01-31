#import "ILGridView.h"
#import "ILGridData.h"

#if IL_APP_KIT

@interface ILGridView ()

@property(nonatomic,retain) NSMutableArray* rowCache; // mutable array of row images which 

@end

#pragma mark -

@implementation ILGridView

-(void)initView
{
    self.grid = nil;
    self.gradient = [[NSGradient alloc] initWithColors:@[
        [NSColor controlBackgroundColor],
        [[NSColor orangeColor] blendedColorWithFraction:0.666 ofColor:[NSColor blackColor]]]];
    self.background = [NSColor controlBackgroundColor];
    self.cellInsets = NSMakeSize(0,0); // each cell is inset, total grid line is 2x this value
    self.labelFont = [NSFont systemFontOfSize:8];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

#pragma mark NSNibAwakening

-(void)awakeFromNib
{
    [self initView];
}

#pragma mark -

- (void) drawError:(NSString*) errorString
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

- (void)drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    [self.background setFill]; // assume 'average' and show deviation from it as lighter to darker values
    [NSBezierPath fillRect:dirtyRect];
    [NSGraphicsContext restoreGraphicsState];
    NSDate* start = [NSDate date];
    NSInteger drawCount = 0;
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
        
        NSUInteger thisRow = 0;
        while (thisRow < self.grid.rows ) {
            NSUInteger thisColumn = 0;
            while (thisColumn < self.grid.columns) {
                NSRect thisRect = NSMakeRect(
                    cellSize.width*thisColumn, cellSize.height*thisRow,
                    cellSize.width, cellSize.height);
                thisRect = NSInsetRect(thisRect, self.cellInsets.width, self.cellInsets.height);
//                thisRect = NSIntegralRect(thisRect);
                float percentValue = [self.grid percentAtRow:thisRow column:thisColumn];
                NSColor* thisColor = [self.gradient interpolatedColorAtLocation:percentValue];
// NSLog(@"grid (%lu,%lu) ((%li - %li) / %li) -> %f -> %@", thisColumn, thisRow, thisValue, self.minValue, self.maxValue, thisFloat, thisColor);
                [NSGraphicsContext saveGraphicsState];
                [thisColor setFill];
                [NSBezierPath fillRect:thisRect];
                [NSGraphicsContext restoreGraphicsState];
                drawCount++;
                thisColumn++;
            }
            thisRow++;
        }

        if( self.yAxisLabels ) // draw these along the y axis
        {
            NSMutableParagraphStyle* left = [NSMutableParagraphStyle new];
            left.alignment = NSLeftTextAlignment;
            NSDictionary* labelAttrs = @{
                NSFontAttributeName: self.labelFont,
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
                NSFontAttributeName: self.labelFont,
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
    
    if ( fabs([start timeIntervalSinceNow]) > 0.1) {
        NSLog(@"slow draw of: %@ (%lu,%lu) %li ops in in %0.4fs",
              self.grid, (unsigned long)self.grid.columns, (unsigned long)self.grid.rows, (long)drawCount, fabs([start timeIntervalSinceNow]));
    }
}

@end

#pragma mark -

@implementation ILGridTableDataSource

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.grid.rows;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    id value = nil;
    NSUInteger columnIndex = [tableView.tableColumns indexOfObject:tableColumn];

    if (columnIndex == 0) {
        value = self.labels[row];
    }
    else {
        if (self.grid.type == ILGridDataIntegerType) {
            value = [NSNumber numberWithDouble:[self.grid percentAtRow:row column:columnIndex-1]];
            // value = [NSNumber numberWithInteger:[self.grid integerAtRow:row column:columnIndex-1]];
        }
        else if (self.grid.type == ILGridDataFloatType) {
            value = [NSNumber numberWithDouble:[self.grid floatAtRow:row column:columnIndex-1]];
        }
        else if (self.grid.type == ILGridDataUnicharType) {
            value = [NSString stringWithFormat:@"%C", [self.grid uniCharAtRow:row column:columnIndex-1]];
        }
    }
    
    return value;
}

@end

#endif
