#import <SparkKit/ILBridgeKit.h>
#import <SparkKit/ILSparkStyle.h>

#if IL_APP_KIT

@class ILGridData;

@interface ILGridView : ILView

@property(nonatomic,retain) ILGridData* grid;
@property(nonatomic,retain) NSGradient* gradient;
@property(nonatomic,assign) CGSize cellInsets;
@property(nonatomic,retain) NSColor* background;
@property(nonatomic,retain) NSFont* labelFont;
@property(nonatomic,retain) NSArray* yAxisLabels;
@property(nonatomic,retain) NSString* yAxisUnits;
@property(nonatomic,retain) NSArray* xAxisLabels;
@property(nonatomic,retain) NSString* xAxisUnits;

@end

#pragma mark - Table Data Source

@interface ILGridTableDataSource : NSObject <NSTableViewDataSource,NSOutlineViewDataSource>
@property(nonatomic,retain) ILGridData* grid;
@property(nonatomic,retain) NSArray* labels;
@end

#endif
