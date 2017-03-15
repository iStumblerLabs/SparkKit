#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef enum
{
    ILGridDataByteType,
    ILGridDataIntegerType,
    ILGridDataFloatType,
    ILGridDataUnicharType
}
ILGridDataType;

@protocol ILGridDataDelegate;

@interface ILGridData : NSObject
{
    ILGridDataType gridType;
    NSMutableData* data;
    NSUInteger gridRows;
    NSUInteger gridColumns;
    NSUInteger gridValueSize;
    CGFloat gridMinValue;
    CGFloat gridMaxValue;
}
@property(readonly) NSUInteger rows;
@property(readonly) NSUInteger columns;
@property(readonly) NSUInteger valueSize;
@property(readonly) CGFloat minValue;
@property(readonly) CGFloat maxValue;
@property(readonly) ILGridDataType type;
@property(nonatomic, assign) NSObject<ILGridDataDelegate>* delegate;

#pragma mark -

+ (instancetype) integerGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns;
+ (instancetype) floatGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns;
+ (instancetype) uniCharGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns;

#pragma mark -

/** @designated initilizer */
- (instancetype) initGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns valueSize:(NSUInteger)size gridType:(ILGridDataType) type;

#pragma mark - Properties

- (NSUInteger)   sizeOfRow;
- (void*)     addressOfRow:(NSUInteger)row column:(NSUInteger)column;
- (uint8_t)      byteAtRow:(NSUInteger)row column:(NSUInteger)column;
- (NSInteger) integerAtRow:(NSUInteger)row column:(NSUInteger)column;
- (CGFloat)     floatAtRow:(NSUInteger)row column:(NSUInteger)column;
- (UniChar)   uniCharAtRow:(NSUInteger)row column:(NSUInteger)column;
- (CGFloat)   percentAtRow:(NSUInteger)row column:(NSUInteger)column;

#pragma mark - Setters

- (void) setValueAtRow:(NSUInteger)row column:(NSUInteger)column data:(void*)data length:(NSUInteger) length;
- (void) setByte:(uint8_t) byteValue atRow:(NSUInteger)row column:(NSUInteger)column;
- (void) setInteger:(NSInteger) integerValue atRow:(NSUInteger)row column:(NSUInteger)column;
- (void) setFloat:(CGFloat) floatValue atRow:(NSUInteger) row column:(NSUInteger)column;
- (void) setUniChar:(UniChar) charValue atRow:(NSUInteger) row column:(NSUInteger)column;

#pragma mark - Fill Grid with a Value

- (void) fillIntegerValue:(NSInteger) integerValue;
- (void) fillUniCharValue:(UniChar) unicharValue;
- (void) fillFloatValue:(CGFloat) floatValue;

#pragma mark - String Representations

- (NSString*) integerGridRepresentation;
- (NSString*) jsonIntegerRepresentation; // arrays of arrays of numbers
- (NSString*) jsonFloatRepresentation; // arrays of arrays of numbers
- (NSString*) jsonUniCharRepresentation; // arrays of unichar strings

#pragma mark - Image Representations

-(CGImageRef)newGrayscaleBitmapOfRow:(NSUInteger)thisRow;
-(CGImageRef)newGrayscaleBitmap;
-(CGImageRef)newAlphaBitmap;

#pragma mark - Slices

- (NSData*) dataAtRow:(NSUInteger)row;
- (void) setData:(NSData*)data atRow:(NSUInteger)row;
- (void) appendData:(NSData*) slice;
- (void) trimToRangeOfRows:(NSRange)rows;

@end

#pragma mark - ILDataStream

@protocol ILGridDataDelegate <NSObject>

#pragma mark - Slices

- (void) grid:(ILGridData*)grid didSetData:(NSData*)data atRow:(NSUInteger)row;
- (void) grid:(ILGridData*)grid didAppendedData:(NSData*)data asRow:(NSUInteger)row;
- (void) grid:(ILGridData*)grid willTrimToRangeOfRows:(NSRange)rows;

@end

#if IL_APP_KIT
#pragma mark - Table Data Source Adapter

@interface ILGridTableDataSource : NSObject <NSTableViewDataSource>
@property(nonatomic,retain) ILGridData* grid;
@property(nonatomic,retain) NSArray* labels;
@end
#endif
