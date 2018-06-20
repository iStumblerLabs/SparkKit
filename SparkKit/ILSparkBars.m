#import "ILSparkBars.h"
#import "ILBucketData.h"

@interface ILSparkBars ()
@property(nonatomic,retain) CALayer* barsLayer;
@end

#pragma mark -

@implementation ILSparkBars

- (void) initView
{
    [super initView];

    self.barsLayer = [CALayer new];
    [self.layer addSublayer:self.barsLayer];
    self.barsLayer.frame = self.layer.bounds;
    self.barsLayer.contentsGravity = kCAGravityResize;
}

- (void) updateView
{
    [CATransaction begin];
    [CATransaction setValue:@(1 / 60) forKey:kCATransactionAnimationDuration]; // TODO use the time between updates
    // TODO a style preference and vertical buckets
    self.barsLayer.frame = self.layer.bounds;
    self.barsLayer.backgroundColor = self.style.background.CGColor;
    self.barsLayer.sublayers = nil;
    
    if (self.dataSource) {
        NSUInteger bucketCount = self.dataSource.buckets.count;
        NSUInteger bucketIndex = 0;
        CGRect insetRect = self.borderInset;
        CGFloat bucketWidth = self.frame.size.width / bucketCount;
        
        if (bucketWidth < 1.0) { // we got problems, deal with it later
            NSLog(@"invalid bucket width: %f view width: %f bucket count: %lu", bucketWidth, self.frame.size.width, (unsigned long)bucketCount);
        }
        
        while (bucketIndex < bucketCount) {
            CGFloat bucketHeight = [self.dataSource bucketValue:bucketIndex] * insetRect.size.height;
            if (bucketHeight > 0.0) { // draw it, otherwise just skip ahead
                CGFloat bucketXOffset = insetRect.origin.x + (bucketWidth * bucketIndex);
                CGFloat bucketYOffset = insetRect.origin.y + (insetRect.size.height - bucketHeight);
                CGRect bucketRect = CGRectMake(bucketXOffset, bucketYOffset, bucketWidth, bucketHeight);
                CAShapeLayer* bucketLayer = [CAShapeLayer new];
                CGPathRef bucketPath = CGPathCreateWithRect(bucketRect, nil);
                bucketLayer.path = bucketPath;
                bucketLayer.fillColor = self.style.fill.CGColor;
                bucketLayer.strokeColor = self.style.stroke.CGColor;
                [self.barsLayer addSublayer:bucketLayer];
                CGPathRelease(bucketPath);
            }
            bucketIndex++;
        }
    }
    else {
        NSLog(@"no bucket data");
    }

    [super updateView];
    [CATransaction commit];
}

#pragma mark - ILBucketDataDelegate

- (void) bucketDataDidUpdate:(ILBucketData*) data
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self updateView];
    }];
}

@end
