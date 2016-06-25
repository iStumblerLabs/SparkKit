#import "ILSparkStyle.h"

CGFloat const ILHairlineWidth = 0.25;
CGFloat const ILFinelineWidth = 0.5;
CGFloat const ILPathlineWidth = 1;
CGFloat const ILBoldlineWidth = 2;

@implementation ILSparkStyle

+ (ILSparkStyle*) defaultStyle
{
    static ILSparkStyle* style = nil;
    if (!style) {
        style = [ILSparkStyle new];
        style.fill = [ILColor blackColor];
        style.stroke = [ILColor blackColor];
        style.background = [ILColor clearColor];
        style.filled = NO;
        style.bordered = YES;
        style.width = ILPathlineWidth;
        style.scale = 1.0;
        style.falloff = 0.0;
    }
    return style;
}

@end
