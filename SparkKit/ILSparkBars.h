#import <SparkKit/ILSparkView.h>
#import <SparkKit/ILBucketData.h>

/*! @class ILSparkBuckegts is a view for showing ILBucketData */
@interface ILSparkBars : ILSparkView <ILBucketDataDelegate>
@property(nonatomic,retain) ILBucketData* dataSource;

@end
