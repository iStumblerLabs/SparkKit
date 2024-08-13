#if SWIFT_PACKAGE
#import "ILSparkView.h"
#import "ILBucketData.h"
#else
#import <SparkKit/ILSparkView.h>
#import <SparkKit/ILBucketData.h>
#endif

/// ILSparkBuckegts is a view for showing ILBucketData
@interface ILSparkBars : ILSparkView <ILBucketDataDelegate>
@property(nonatomic,retain) ILBucketData* dataSource;

@end
