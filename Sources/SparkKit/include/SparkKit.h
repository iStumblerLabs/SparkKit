/// SparkKit Umbrella Header */
#if SWIFT_PACKAGE
/// View Classes
#import "ILSparkStyle.h"
#import "ILSparkView.h"
#import "ILSparkMeter.h"
#import "ILSparkBars.h"
#import "ILSparkLine.h"
#import "ILSparkGrid.h"
#import "ILSparkStack.h"

/// Data Sources
#import "ILBucketData.h"
#import "ILGridData.h"
#import "ILStreamData.h"
#else

/// View Classes
#import <SparkKit/ILSparkStyle.h>
#import <SparkKit/ILSparkView.h>
#import <SparkKit/ILSparkMeter.h>
#import <SparkKit/ILSparkBars.h>
#import <SparkKit/ILSparkLine.h>
#import <SparkKit/ILSparkGrid.h>
#import <SparkKit/ILSparkStack.h>

/// Data Sources
#import <SparkKit/ILGridData.h>
#import <SparkKit/ILStreamData.h>
#import <SparkKit/ILBucketData.h>
#endif
