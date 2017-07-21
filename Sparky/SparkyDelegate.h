@import SparkKit;

@class SparkyController;

@interface SparkyDelegate : ILResponder <ILApplicationDelegate>
@property(nonatomic, retain) NSTimer* updateTimer;
@property(nonatomic, retain) ILWindow* window;
@property(nonatomic, retain) SparkyController* viewController;

@end

