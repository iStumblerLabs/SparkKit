#import <KitBridge/KitBridge.h>
#import <QuartzCore/QuartzCore.h>
#import <SparkKit/ILGridData.h>
#import <SparkKit/ILSparkView.h>

@class ILSparkStyle;


@interface ILSparkGrid : ILSparkView <ILViews, ILGridDataDelegate>

/*! @brief style information */
@property(nonatomic, retain) ILSparkStyle* style;

/*! @brief border layer */
@property(nonatomic, readonly) CAShapeLayer* border;

@property(nonatomic, retain) ILGridData* grid;
@property(nonatomic, assign) NSRange valueRange;

@end
