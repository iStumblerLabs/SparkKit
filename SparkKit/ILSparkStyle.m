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
    }
    return style;
}

#pragma mark -

- (void) addHints:(NSDictionary*)additionalHints
{
    if (self.hints) {
        NSMutableDictionary* merged = [self.hints mutableCopy];
        [merged addEntriesFromDictionary:additionalHints];
        self.hints = [NSDictionary dictionaryWithDictionary:merged];
    }
    else {
        self.hints = additionalHints;
    }
}


#pragma mark - NSObject

- (NSString*) description
{
    return [NSString stringWithFormat:@"<%@: %p fill=%@ stroke=%@ background=%@ gradient=%@ filled=%i bordered=%i width=%f>",
            [self class], self, self.fill, self.stroke, self.background, self.gradient, self.filled, self.bordered, self.width];
}

@end
