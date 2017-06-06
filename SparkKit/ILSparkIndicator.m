#import "ILSparkIndicator.h"

static CGFloat const IndicatorRingWidth = 15;

#pragma mark - Private

@interface ILSparkIndicator ()
@property (nonatomic, retain) CATextLayer *indicatorText;
@property (nonatomic, retain) CAShapeLayer *indicatorLayer;

@end

#pragma mark -

@implementation ILSparkIndicator

#ifdef IL_UI_KIT
#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.indicatorLayer.frame = self.bounds;
//    NSLog(@"<%@ %p layoutSubviews frame: %@ layer frame: %@ layer bounds: %@>",
//        self.class, self, NSStringFromCGRect(self.frame),
//        NSStringFromCGRect(self.style == ILIndicatorStyleText ? self.indicatorText.frame : self.indicatorLayer.frame),
//        NSStringFromCGRect(self.style == ILIndicatorStyleText ? self.indicatorText.bounds : self.indicatorLayer.bounds));
}
#endif

#pragma mark - ILBorderedView

- (void)initView
{
    [super initView];
    self.style = ILIndicatorStyleText;
    self.dataSource = nil;

    self.indicatorLayer = [CAShapeLayer new];
    [self.layer addSublayer:self.indicatorLayer];

    self.indicatorText = [CATextLayer new];
    [self.layer addSublayer:self.indicatorText];
}

- (void)updateView
{
    [super updateView];

    ILBezierPath* filledPath = nil;

    self.indicatorLayer.hidden = (self.style == ILIndicatorStyleText);
    self.indicatorText.hidden = (self.style != ILIndicatorStyleText);

    CGFloat datum = self.dataSource.datum;
    if (self.dataSource) {        
        switch (self.indicatorStyle) {
            case ILIndicatorStyleText: {
                NSString* valueString = [NSString stringWithFormat:@"%.1f%%", datum * 100];
                NSMutableParagraphStyle* valueStyle = [NSMutableParagraphStyle new];
                valueStyle.alignment = NSTextAlignmentCenter;

                NSAttributedString* attributedValueString = [[NSAttributedString alloc] initWithString:valueString attributes:@{
                    NSParagraphStyleAttributeName: valueStyle,
                    NSFontAttributeName: [ILFont systemFontOfSize:self.style.font.pointSize],
                    NSForegroundColorAttributeName: self.style.stroke
                }];

                // compute the string size and offsets
                CGSize stringSize = attributedValueString.size;
                CGFloat xOffset = (self.bounds.size.width-stringSize.width)/2;
                CGFloat yOffset = (self.bounds.size.height-stringSize.height)/2;
                CGRect stringRect = CGRectIntegral(CGRectMake(xOffset, yOffset, stringSize.width, stringSize.height));

                // set text properties and mask
                // self.indicatorText.mask = self.borderMask;
                self.indicatorText.string = attributedValueString;
                self.indicatorText.frame = stringRect;
                break;
            }
            case ILIndicatorStyleVertical: {
                CGFloat indicatorPosition = self.bounds.size.height - (self.bounds.size.height * datum);
                CGRect filledRect = CGRectMake(0, indicatorPosition, self.bounds.size.width, (self.bounds.size.height - indicatorPosition));
                filledPath = [ILBezierPath bezierPathWithRect:CGRectInset(filledRect, self.style.width, self.style.width)];
                break;
            }
            case ILIndicatorStyleHorizontal: {
                CGFloat indicatorPosition = (self.bounds.size.width * datum);
                CGRect filledRect = CGRectMake(0, 0, indicatorPosition, self.bounds.size.height);
                filledPath = [ILBezierPath bezierPathWithRect:CGRectInset(filledRect,self.style.width,self.style.width)];
                break;
            }
            case ILIndicatorStyleSquare: {
                CGRect squareRect = CGRectInset(ILRectSquareInRect(self.bounds), ILPathlineWidth, ILPathlineWidth);
                CGFloat indicatorSideLength = (squareRect.size.height * self.dataSource.datum);
                CGFloat indicatorInset = (squareRect.size.width-indicatorSideLength)/2; // ??? take the square root?
                CGRect filledRect = CGRectInset(squareRect, indicatorInset, indicatorInset);
                filledPath = [ILBezierPath bezierPathWithRect:filledRect];
                break;
            }
            case ILIndicatorStyleCircle: {
                CGFloat squareInsets = ILPathlineWidth + self.style.width;
                CGRect squareRect = CGRectInset(ILRectSquareInRect(self.bounds), squareInsets, squareInsets);
                CGFloat indicatorSideLength = (squareRect.size.height * datum);
                CGFloat indicatorInset = (squareRect.size.width-indicatorSideLength)/2; // equal area?
                CGRect filledRect = CGRectInset(squareRect, indicatorInset, indicatorInset);
                filledPath = [ILBezierPath bezierPathWithOvalInRect:filledRect];
                break;
            }
            case ILIndicatorStyleRing: {
                CGFloat squareInsets = ILPathlineWidth + self.style.width;
                CGRect squareRect = CGRectInset(ILRectSquareInRect(self.bounds), squareInsets, squareInsets);
                CGFloat indicatorSideLength = (squareRect.size.height / 2.0f) - squareInsets;
                CGPoint squareCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2.0f), squareRect.origin.y + (squareRect.size.height / 2.0f));
                CGPoint topDeadCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2.0f), squareCenter.y - indicatorSideLength);
                CGFloat firstAngle = (CGFloat) -(M_PI / 2.0f);
                CGFloat secondAngle = (CGFloat) ((2.0f * M_PI) * datum) - (CGFloat) (M_PI / 2.0f);
                filledPath = [ILBezierPath new];
                [filledPath addArcWithCenter:squareCenter radius:indicatorSideLength startAngle:firstAngle endAngle:secondAngle clockwise:YES];
                CGPoint outsideEndPoint = filledPath.currentPoint;
                CGPoint insetPoint = ILPointOnLineToPointAtDistance(outsideEndPoint,squareCenter,IndicatorRingWidth);
                [filledPath addLineToPoint:insetPoint];
                [filledPath addArcWithCenter:squareCenter radius:indicatorSideLength-IndicatorRingWidth startAngle:secondAngle endAngle:firstAngle clockwise:NO];
                [filledPath addLineToPoint:topDeadCenter];
                break;
            }
            case ILIndicatorStylePie: {
                CGFloat squareInsets = ILPathlineWidth + self.style.width;
                CGRect squareRect = CGRectInset(ILRectSquareInRect(self.bounds), squareInsets, squareInsets);
                CGFloat indicatorSideLength = (squareRect.size.height/2)-squareInsets;
                CGPoint squareCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2), squareRect.origin.y + (squareRect.size.height / 2));
                CGPoint topDeadCenter = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2),squareCenter.y - indicatorSideLength);
                CGFloat firstAngle = (CGFloat) -(M_PI / 2.0);
                CGFloat secondAngle = (CGFloat) ((2.0 * M_PI) * datum) - (CGFloat) (M_PI / 2.0);
                filledPath = [ILBezierPath new];
                [filledPath addArcWithCenter:squareCenter radius:indicatorSideLength startAngle:firstAngle endAngle:secondAngle clockwise:YES];
                [filledPath addLineToPoint:squareCenter];
                [filledPath addLineToPoint:topDeadCenter];
                break;
            }
            case ILIndicatorStyleDial: {
                CGFloat squareInsets = ILPathlineWidth + self.style.width;
                CGRect squareRect = CGRectInset(ILRectSquareInRect(self.bounds), squareInsets, squareInsets);
                CGFloat indicatorSideLength = (squareRect.size.height / 2) - squareInsets;
                CGPoint squareCenter = ILPointCenteredInRect(squareRect);
                CGFloat indicatorAngle = (CGFloat) ((2 * M_PI) * self.dataSource.datum) - (CGFloat) (M_PI / 2);
                filledPath = [ILBezierPath new];
                [filledPath addArcWithCenter:squareCenter radius:indicatorSideLength startAngle:indicatorAngle endAngle:indicatorAngle clockwise:YES];
                [filledPath addLineToPoint:squareCenter];
                // XXX don't really want to force this, more of a default setting
                self.style.width = ILBoldlineWidth;
                break;
            }
        }
    }

    self.indicatorLayer.path = filledPath.CGPath;
    // self.indicatorLayer.mask = self.borderMask;
    self.indicatorLayer.fillColor = self.style.fill.CGColor;
    self.indicatorLayer.strokeColor = self.style.stroke.CGColor;
    self.indicatorLayer.lineWidth = self.style.width;
}

- (BOOL) isCircular
{
    return (self.indicatorStyle == ILIndicatorStyleCircle)
        || (self.indicatorStyle == ILIndicatorStyleRing)
        || (self.indicatorStyle == ILIndicatorStylePie)
        || (self.indicatorStyle == ILIndicatorStyleDial);
}

@end

