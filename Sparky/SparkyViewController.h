@import SparkKit;

#ifdef IL_APP_KIT
@interface SparkyViewController : NSViewController <ILSparkIndicatorDataSource, ILSparkLineDataSource, ILViews>
#else
@interface SparkyViewController : UIViewController <ILSparkIndicatorDataSource, ILSparkLineDataSource, ILViews>
#endif
@property(nonatomic, retain) IBOutlet ILSparkLine* sparkLine;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkText;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkVert;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkHorz;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkSquare;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkCircle;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkRing;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkPie;
@property(nonatomic, assign) IBOutlet ILSparkIndicator* sparkDial;

@end

