#import "ILSparkStyle.h"

NSString* const ILSparkStyleFill = @"Fill";
NSString* const ILSparkStyleStroke = @"Stroke";
NSString* const ILSparkStyleBackground = @"Background";
NSString* const ILSparkStyleBorder = @"Border";
NSString* const ILSparkStyleGradient = @"Gradient";
NSString* const ILSparkStyleIsFilled = @"IsFilled";
NSString* const ILSparkStyleIsBordered = @"IsBordered";
NSString* const ILSparkStyleWidth = @"Width";
NSString* const ILSparkStyleHints = @"Hints";

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
        style.fill = [ILColor grayColor];
        style.stroke = [ILColor darkGrayColor];
        style.border = [ILColor lightGrayColor];
        style.background = [ILColor clearColor];
        style.gradient = nil; // [[ILGradient alloc] initWithStartingColor:[ILColor blackColor] endingColor:[ILColor whiteColor]];
        style.filled = NO;
        style.bordered = YES;
        style.width = ILPathlineWidth;
        style.font = [ILFont fontWithName:@"Helvetica" size:12];
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
