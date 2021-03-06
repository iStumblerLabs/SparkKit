#import <KitBridge/KitBridge.h>
#import <SparkKit/ILSparkStyle.h>


/*! @class ILSparkView
    @brief base class for all SparkKit views */
@interface ILSparkView : ILView <ILViews, ILSparkStyle>

#pragma mark - ILSparkStyle

/*! @brief view style */
@property(nonatomic, retain) ILSparkStyle* style;

/*! @brief border layer */
@property(nonatomic, readonly) CAShapeLayer* border;

/*! @brief is the bortder circular? */
@property(nonatomic, readonly) BOOL isCircular;

/*! @brief inset of border rectangle, effective drawable area */
@property(nonatomic, readonly) CGRect borderInset;

#pragma mark - Labels

@property(nonatomic, retain) NSArray* yAxisLabels;
@property(nonatomic, retain) NSString* yAxisUnits;
@property(nonatomic, assign) BOOL yAxisLabelsCenteredOnRows;
@property(nonatomic, retain) NSArray* xAxisLabels;
@property(nonatomic, retain) NSString* xAxisUnits;
@property(nonatomic, assign) BOOL xAxisLabelsCenteredOnColumns;
@property(nonatomic, retain) NSString* errorString;

@end
