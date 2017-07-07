@import SparkKit;

@class SparkyController;

@interface SparkyDelegate : NSObject <ILApplicationDelegate>
@property(nonatomic, retain) NSTimer* updateTimer;
@property(nonatomic, retain) ILWindow* window;
@property(nonatomic, retain) SparkyController* viewController;

@end

