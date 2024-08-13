@import KitBridge;
@import SparkKit;

#ifdef IL_UI_KIT
@interface SparkyController : UIViewController <ILSparkMeterDataSource, ILSparkStackDataSource, ILSparkLineDataSource, ILViews>
#else
@interface SparkyController : NSViewController <ILSparkMeterDataSource, ILSparkStackDataSource, ILSparkLineDataSource, ILViews>
#endif

// MARK: - Properties
@property(nonatomic, retain) ILGridData* gridData;
@property(nonatomic, retain) ILStreamData* streamData;
@property(nonatomic, retain) ILBucketData* bucketData;

// MARK: - IBOutlets
@property(nonatomic, retain) IBOutlet ILSparkBars* sparkBars;
@property(nonatomic, retain) IBOutlet ILSparkLine* sparkLine;
@property(nonatomic, retain) IBOutlet ILSparkGrid* sparkGrid;

// MARK: - Meters
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkText;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkVert;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkHorz;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkSquare;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkCircle;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkRing;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkPie;
@property(nonatomic, assign) IBOutlet ILSparkMeter* sparkDial;

// MARK: - Stacks
@property(nonatomic, assign) IBOutlet ILSparkStack* stackText;
@property(nonatomic, assign) IBOutlet ILSparkStack* stackVert;
@property(nonatomic, assign) IBOutlet ILSparkStack* stackHorz;
@property(nonatomic, assign) IBOutlet ILSparkStack* stackSquare;
@property(nonatomic, assign) IBOutlet ILSparkStack* stackCircle;
@property(nonatomic, assign) IBOutlet ILSparkStack* stackRing;
@property(nonatomic, assign) IBOutlet ILSparkStack* stackPie;
@property(nonatomic, assign) IBOutlet ILSparkStack* stackDial;

@end
