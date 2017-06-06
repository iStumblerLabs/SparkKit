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

@end
