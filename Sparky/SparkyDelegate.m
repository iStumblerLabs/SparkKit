#import "SparkyDelegate.h"
#import "SparkyViewController.h"

#ifdef IL_APP_KIT
@interface SparkyDelegate ()

@end
#endif

@implementation SparkyDelegate

- (void) update
{
    [self.viewController updateView];
}

#ifdef IL_UI_KIT
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
#else
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
#endif
{
    ILSparkStyle* defaultStyle = [ILSparkStyle defaultStyle];
    defaultStyle.bordered = YES;
    defaultStyle.filled = YES;
    defaultStyle.width = 2;
    [defaultStyle addHints:@{ILSparkLineFalloffInterval: @(30.0)}];
    
#ifdef IL_UI_KIT
    UIStoryboard* sparkyStoryboard = [UIStoryboard storyboardWithName:@"Sparky" bundle:nil];
    self.viewController = sparkyStoryboard.instantiateInitialViewController;
    self.window.rootViewController = self.viewController;
#else
    self.viewController = [[SparkyViewController alloc] initWithNibName:@"Sparky" bundle:[NSBundle mainBundle]];
#endif
    
    [self.viewController initView];
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [self.updateTimer fire];

#ifdef IL_UI_KIT
    return YES;
#endif
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end

#pragma mark -


int main(int argc, char* _Nonnull argv[]) {
#ifdef IL_APP_KIT
    return NSApplicationMain(argc, (const char* _Nonnull*) argv);
#elif IL_UI_KIT
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SparkyDelegate class]));
    }
#endif
}

