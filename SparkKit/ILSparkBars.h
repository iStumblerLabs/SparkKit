#import <SparkKit/ILSparkView.h>

@class ILBucketData;
@protocol ILBucketDataDelegate;

/*! @class ILSparkLine provides a time-series view for iOS and macOS */
@interface ILSparkBars : ILSparkView <ILBucketDataDelegate>
@property(nonatomic,retain) ILBucketData* dataSource;

@end
