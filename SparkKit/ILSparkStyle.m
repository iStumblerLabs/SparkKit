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
        style.fill = [ILColor darkGrayColor];
        style.stroke = [ILColor blackColor];
        style.border = [ILColor lightGrayColor];
        style.background = [ILColor clearColor];
        style.gradient = nil; // [[ILGradient alloc] initWithStartingColor:[ILColor blackColor] endingColor:[ILColor whiteColor]];
        style.filled = NO;
        style.bordered = YES;
        style.width = ILPathlineWidth;
        style.scale = 1.0;
        style.falloff = 0.0;
    }
    return style;
}

#pragma mark - NSObject

- (NSString*) description
{
    return [NSString stringWithFormat:@"<%@: %p fill=%@ stroke=%@ background=%@ gradient=%@ filled=%i bordered=%i width=%f scale=%f falloff-%f>",
            [self class], self, self.fill, self.stroke, self.background, self.gradient, self.filled, self.bordered, self.width, self.scale, self.falloff];
}

@end
