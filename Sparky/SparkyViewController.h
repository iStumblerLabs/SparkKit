@import SparkKit;

#ifdef IL_APP_KIT
@interface SparkyViewController : NSViewController <ILSparkGaugeDataSource, ILSparkLineDataSource, ILViews>
#else
@interface SparkyViewController : UIViewController <ILSparkGaugeDataSource, ILSparkLineDataSource, ILViews>
#endif

#pragma mark - Properties
@property(nonatomic, retain) ILGridData* gridData;

#pragma mark - IBOutlets
@property(nonatomic, retain) IBOutlet ILSparkLine* sparkLine;
@property(nonatomic, retain) IBOutlet ILSparkGrid* sparkGrid;

@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkText;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkVert;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkHorz;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkSquare;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkCircle;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkRing;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkPie;
@property(nonatomic, assign) IBOutlet ILSparkGauge* sparkDial;

@end
