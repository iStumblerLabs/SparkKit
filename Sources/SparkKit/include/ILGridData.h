#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#ifdef SWIFT_PACKAGE
#import "KitBridge.h"
#else
#import <KitBridge/KitBridge.h>
#endif

@protocol ILGridDataDelegate;

typedef enum {
    ILGridDataByteType,
    ILGridDataIntegerType,
    ILGridDataFloatType,
    ILGridDataUnicharType
}   ILGridDataType;

/// ILGridData is a wrapper for NSMutableData which provides access to a 2d array of values or a given size
@interface ILGridData : NSObject
@property(nonatomic, retain) NSMutableData* data;
@property(nonatomic, assign) ILGridDataType dataType;
@property(nonatomic, readonly) size_t valueSize; // depends on type
@property(nonatomic, readonly) NSUInteger rows; // computed
@property(nonatomic, assign) NSUInteger columns;
@property(nonatomic, assign) NSObject<ILGridDataDelegate>* delegate;

// MARK: - Factory

+ (instancetype) gridWithDataType:(ILGridDataType)dataType rows:(NSUInteger)rows columns:(NSUInteger)columns;
+ (instancetype) byteGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns;
+ (instancetype) integerGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns;
+ (instancetype) floatGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns;
+ (instancetype) uniCharGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns;

// MARK: -

/// @designated initilizer
- (instancetype) initGridWithDataType:(ILGridDataType)dataType rows:(NSUInteger)rows columns:(NSUInteger)columns;

// MARK: - Properties

- (size_t) sizeOfRow;
- (void*) addressOfRow:(NSUInteger)row column:(NSUInteger)column;

- (uint8_t) byteAtRow:(NSUInteger)row column:(NSUInteger)column;
- (NSInteger) integerAtRow:(NSUInteger)row column:(NSUInteger)column;
- (CGFloat) floatAtRow:(NSUInteger)row column:(NSUInteger)column;
- (UniChar) uniCharAtRow:(NSUInteger)row column:(NSUInteger)column;

- (CGFloat) percentOfValueAtRow:(NSUInteger)row column:(NSUInteger)column inRange:(NSRange)range;

// MARK: - Setters

- (void) setValue:(void*)data ofSize:(size_t)valueSize atRow:(NSUInteger)row column:(NSUInteger)column;
- (void) setByte:(uint8_t) byteValue atRow:(NSUInteger)row column:(NSUInteger)column;
- (void) setInteger:(NSInteger) integerValue atRow:(NSUInteger)row column:(NSUInteger)column;
- (void) setFloat:(CGFloat) floatValue atRow:(NSUInteger) row column:(NSUInteger)column;
- (void) setUniChar:(UniChar) charValue atRow:(NSUInteger) row column:(NSUInteger)column;

// MARK: - Fill Grid with a Value

- (void) fillByteValue:(uint8_t) byteValue;
- (void) fillIntegerValue:(NSInteger) integerValue;
- (void) fillUniCharValue:(UniChar) unicharValue;
- (void) fillFloatValue:(CGFloat) floatValue;

// MARK: - String Representations

- (NSString*) integerGridRepresentation;
- (NSString*) jsonIntegerRepresentation; // arrays of arrays of numbers
- (NSString*) jsonFloatRepresentation; // arrays of arrays of numbers
- (NSString*) jsonUniCharRepresentation; // arrays of unichar strings

// MARK: - Image Representations

- (CGImageRef) grayscaleBitmapOfRow:(NSUInteger)thisRow withRange:(NSRange)range CF_RETURNS_RETAINED;
- (CGImageRef) grayscaleBitmapWithRange:(NSRange)range CF_RETURNS_RETAINED;
- (CGImageRef) alphaBitmapOfRow:(NSUInteger)thisRow withRange:(NSRange)range CF_RETURNS_RETAINED;
- (CGImageRef) alphaBitmapWithRange:(NSRange) range CF_RETURNS_RETAINED;

// MARK: - Slices

- (NSData*) dataAtRow:(NSUInteger)row;
- (void) setData:(NSData*)data atRow:(NSUInteger)row;
- (void) appendData:(NSData*) slice;
- (void) trimToRangeOfRows:(NSRange)rows;
- (void) extendToRow:(NSUInteger)rows;

// MARK: - Buckets

- (NSArray<NSNumber*>*) bucketsAtRow:(NSUInteger)row withRange:(NSRange)valueRange;

@end


// MARK: - ILGridDataDelegate

@protocol ILGridDataDelegate <NSObject>

// MARK: - Slice Operations

- (void) grid:(ILGridData*)grid didSetData:(NSData*)data atRow:(NSUInteger)row;
- (void) grid:(ILGridData*)grid didAppendedData:(NSData*)data asRow:(NSUInteger)row;
- (void) grid:(ILGridData*)grid willTrimToRangeOfRows:(NSRange)rows;

@end

#if IL_APP_KIT
// MARK: - Table Data Source Adapter


@interface ILGridTableDataSource : NSObject <NSTableViewDataSource>
@property(nonatomic, retain) ILGridData* grid;
@property(nonatomic, retain) NSArray* labels;
@property(nonatomic, assign) NSRange range;

@end
#endif
