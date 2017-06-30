#import "ILBucketData.h"

@implementation ILBucketData

- (NSUInteger) bucketCount
{
    return 5;
}

- (CGFloat) bucketValue:(NSUInteger) bucketIndex
{
    return 0.5;
}

@end
