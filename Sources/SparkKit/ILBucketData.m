#import "ILBucketData.h"

@interface ILBucketData ()
@property(nonatomic, retain) NSArray<NSNumber*>* bucketsStorage;

@end

// MARK: -

@implementation ILBucketData

- (NSArray<NSNumber*>*) buckets {
    return self.bucketsStorage;
}

- (void) setBuckets:(NSArray<NSNumber*>*)buckets {
    self.bucketsStorage = buckets;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bucketDataDidUpdate:)]) {
        [self.delegate bucketDataDidUpdate:self];
    }
}

- (CGFloat) bucketValue:(NSUInteger) bucketIndex {
    return [self.buckets[bucketIndex] doubleValue];
}

@end
