#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol ILBucketDataDelegate;

/// Data which can be devided into equal sized buckets,
/// either in time (e.g. one minute) or space (e.g. one mile) etc.
/// A bar chart with time buckets is a histogram
/// A bar chart with frequency buckets is a frequency analyzer
@interface ILBucketData : NSObject

/// delegate for data update notifications
@property(nonatomic, assign) NSObject<ILBucketDataDelegate>* delegate;

/// array of numbers representing each bucket
@property(nonatomic, retain) NSArray<NSNumber*>* buckets;

- (CGFloat) bucketValue:(NSUInteger) bucketIndex;

@end

// MARK: -

/// notifications for the view when the data is updated
@protocol ILBucketDataDelegate <NSObject>
@optional

- (void) bucketDataDidUpdate:(ILBucketData*) data;

@end
