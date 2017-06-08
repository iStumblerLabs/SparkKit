@import SparkKit;

@class SparkyViewController;

@interface SparkyDelegate : NSObject <ILApplicationDelegate>
@property(nonatomic, retain) NSTimer* updateTimer;
@property(nonatomic, retain) ILWindow* window;
@property(nonatomic, retain) SparkyViewController* viewController;

@end

