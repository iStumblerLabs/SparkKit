#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol ILBucketDataDelegate;

/*! @class ILBucketData
    @brief Data which can be devided into equal sized buckets,
    either in time (e.g. one minute) or space (e.g. one mile) etc.
    A bar chart with time buckets is a histogram
    A bar chart with frequency buckets is a frequency analyzer
*/
@interface ILBucketData : NSObject
@property(nonatomic, assign) NSObject<ILBucketDataDelegate>* delegate;
@property(nonatomic, readonly) NSUInteger bucketCount;

- (CGFloat) bucketValue:(NSUInteger) bucketIndex;

@end

#pragma mark -

/*! @protocol ILBucketDataDelegate
    @brief notifications for the view when the datat is updated
*/
@protocol ILBucketDataDelegate <NSObject>
@optional

- (void) bucketDataDidUpdate:(ILBucketData*) data;
- (void) bucketDataDidUpdate:(ILBucketData*) data inRange:(NSRange) range;

@end
