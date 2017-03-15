#import <SparkKit/ILKitBridge.h>
#import <SparkKit/ILGridData.h>

@class ILSparkStyle;

@interface ILGridView : ILView <ILViews, ILGridDataDelegate>

/*! @brief style information */
@property(nonatomic, retain) ILSparkStyle* style;

/*! @brief border layer */
@property(nonatomic, readonly) CAShapeLayer* border;

@property(nonatomic,retain) ILGridData* grid;
@property(nonatomic,retain) NSArray* yAxisLabels;
@property(nonatomic,retain) NSString* yAxisUnits;
@property(nonatomic,retain) NSArray* xAxisLabels;
@property(nonatomic,retain) NSString* xAxisUnits;
@property(nonatomic,retain) NSString* errorString;

@end
