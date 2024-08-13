#import <QuartzCore/QuartzCore.h>
#ifdef SWIFT_PACKAGE
#import "KitBridge.h"
#import "ILGridData.h"
#import "ILSparkView.h"
#else
#import <KitBridge/KitBridge.h>
#import <SparkKit/ILGridData.h>
#import <SparkKit/ILSparkView.h>
#endif

@class ILSparkStyle;


@interface ILSparkGrid : ILSparkView <ILViews, ILGridDataDelegate>

@property(nonatomic, retain) ILGridData* grid;
@property(nonatomic, assign) NSRange valueRange;

@end
