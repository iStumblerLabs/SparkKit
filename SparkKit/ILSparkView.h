#import <SparkKit/ILDefines.h>
#import <SparkKit/ILSparkStyle.h>

/*! @return the largest square centered in the provided rectangle */
CGRect ILRectSquareInRect(CGRect rect);

/*! @return the points in vector form */
CGVector ILVectorFromPointToPoint(CGPoint from, CGPoint to);

/*! @return the length of the vector using the pythagorian therom */
CGFloat ILVectorLength(CGVector delta);

/*! @return the angle of the vector in radians */
CGFloat ILVectorRadians(CGVector delta);

/*! @brief project a point the provided distance along the vector provided */
CGPoint ILPointOnLineToPointAtDistance(CGPoint from, CGPoint to, CGFloat distance);

#pragma mark -

/*! @class ILSparkView
    @brief base class for all SparkKit views */
@interface ILSparkView : ILView

/*! @brief style information */
@property(nonatomic, retain) ILSparkStyle* style;

/*! @brief run from initWithFrame: and initWithCoder: override to initilzize the view */
- (void) initView;

/*! @brief have the view query it's delgate and redraw */
- (void) updateView;

@end
