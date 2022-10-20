#import "ILGridData.h"

size_t ILSizeOfGridType(ILGridDataType dataType)
{
    size_t typeSize = 0;
    
    switch (dataType) {
        case ILGridDataByteType:    typeSize = sizeof(uint8_t);     break;
        case ILGridDataIntegerType: typeSize = sizeof(NSInteger);   break;
        case ILGridDataFloatType:   typeSize = sizeof(CGFloat);     break;
        case ILGridDataUnicharType: typeSize = sizeof(UniChar);     break;
    }
    
    return typeSize;
}

#pragma mark - Private

@interface ILGridData ()
@property(nonatomic, assign) CGFloat minValueStorage;
@property(nonatomic, assign) BOOL minValueSet;
@property(nonatomic, assign) CGFloat maxValueStorage;
@property(nonatomic, assign) BOOL maxValueSet;

@end

#pragma mark -

@implementation ILGridData

/*
+ (void) mutableGridTest
{
    MutableGrid* integerTestGrid = [MutableGrid integerGridWithRows:10 columns:10];

    // put in a recognizable pattern
    NSUInteger count = 0;
    while ( count < 10 )
    {
        [integerTestGrid setInteger:(count+1) atRow:count column:count];
        count++;
    }

    NSLog(@"integerTestGrid: \n%@", [integerTestGrid integerGridRepresentation]);

    MutableGrid* unicharTestGrid = [MutableGrid uniCharGridWithRows:5 columns:5];
    [unicharTestGrid setUniChar:'H' atRow:0 column:0];
    [unicharTestGrid setUniChar:'e' atRow:0 column:1];
    [unicharTestGrid setUniChar:'l' atRow:0 column:2];
    [unicharTestGrid setUniChar:'l' atRow:0 column:3];
    [unicharTestGrid setUniChar:'o' atRow:0 column:4];
    [unicharTestGrid setUniChar:'W' atRow:3 column:0];
    [unicharTestGrid setUniChar:'o' atRow:3 column:1];
    [unicharTestGrid setUniChar:'r' atRow:3 column:2];
    [unicharTestGrid setUniChar:'l' atRow:3 column:3];
    [unicharTestGrid setUniChar:'d' atRow:3 column:4];
    
    NSLog(@"unicharTestGrid: \n%@", [unicharTestGrid jsonUniCharRepresentation]);
    
    MutableGrid* floatTestGrid = [MutableGrid floatGridWithRows:20 columns:20];
    count = 0;
    while ( count < MIN(floatTestGrid.self.columns,floatTestGrid.self.rows))
    {
        [floatTestGrid setFloat:sinf(count) atRow:count column:count];
        count++;
    }
    NSLog(@"floatTestGrid: \n%@", [floatTestGrid jsonFloatRepresentation]);

}
*/

- (NSUInteger) rows
{
    return (self.columns > 0 ? (self.data.length / self.sizeOfRow) : 0); // TODO throw if there's any modulo
}

#pragma mark - Factory Methods

+ (ILGridData*) gridWithDataType:(ILGridDataType)dataType rows:(NSUInteger)rows columns:(NSUInteger)columns
{
    ILGridData* dataGrid = [[ILGridData alloc] initGridWithDataType:dataType rows:rows columns:columns];
    return dataGrid;
}

+ (ILGridData*) byteGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    ILGridData* byteGrid = [[ILGridData alloc] initGridWithDataType:ILGridDataByteType rows:rows columns:columns];
    [byteGrid fillByteValue:0];
    return byteGrid;
}

+ (ILGridData*) integerGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    ILGridData* integerGrid = [[ILGridData alloc] initGridWithDataType:ILGridDataIntegerType rows:rows columns:columns];
    [integerGrid fillIntegerValue:0];
    return integerGrid;
}

+ (ILGridData*) floatGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    ILGridData* floatGrid = [[ILGridData alloc] initGridWithDataType:ILGridDataFloatType rows:rows columns:columns];
    [floatGrid fillFloatValue:0.0];
    return floatGrid;
}

+ (ILGridData*) uniCharGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    ILGridData* unicharGrid = [[ILGridData alloc] initGridWithDataType:ILGridDataUnicharType rows:rows columns:columns];
    [unicharGrid fillUniCharValue:' '];
    return unicharGrid;
}

#pragma mark - Designated Initilizer

/** designated initilizer */
- (instancetype) initGridWithDataType:(ILGridDataType)dataType rows:(NSUInteger)rows columns:(NSUInteger)columns;
{
    size_t typeSize = ILSizeOfGridType(dataType);
    size_t gridSize = (rows * columns * typeSize);
    if (self = [super init]) {
        self.data = [NSMutableData dataWithCapacity:gridSize];
        self.dataType = dataType;
        self.columns = columns;
        bzero((void*)self.data.bytes, gridSize);
    }
    return self;
}

#pragma mark -

- (size_t) valueSize
{
    return ILSizeOfGridType(self.dataType);
}

- (size_t) sizeOfRow
{
    return (self.valueSize * self.columns);
}

- (void*) addressOfRow:(NSUInteger)row column:(NSUInteger)column
{
    if ((row > self.rows) || (column > self.columns)){
        [[NSException exceptionWithName:NSRangeException reason:[NSString stringWithFormat:@"row: %lu or column: %lu out of range: %lu x %lu", (unsigned long)row, (unsigned long)column, (unsigned long)self.rows, (unsigned long)self.columns] userInfo:nil] raise];
    }
    
    NSUInteger offset = ((row * self.sizeOfRow) + (column * self.valueSize)); // offset in bytes
    
/*   NSLog(@"grid %lu x %lu = %lu",row,column,offset);
    if( offset > [data length]) // range check so we don't send a pointer to hyperspace
    {
        [[NSException exceptionWithName:NSRangeException reason:[NSString stringWithFormat:@"offset: %lu larger than data: %lu", offset, [data length]] userInfo:nil] raise];
    }
*/
    return [self.data mutableBytes] + offset;
}

- (uint8_t) byteAtRow:(NSUInteger)row column:(NSUInteger)column
{
    if (self.valueSize != sizeof(uint8_t)) {
        [[NSException exceptionWithName:NSRangeException reason:nil userInfo:nil] raise];
    }
    void* valueAddress = [self addressOfRow:row column:column];
    uint8_t byteValue = 0;
    memcpy(&byteValue, valueAddress, self.valueSize);
    return byteValue;
}

- (NSInteger) integerAtRow:(NSUInteger)row column:(NSUInteger)column
{
    if (self.valueSize != sizeof(NSInteger)) {
        [[NSException exceptionWithName:NSRangeException reason:nil userInfo:nil] raise];
    }
    void* valueAddress = [self addressOfRow:row column:column];
    NSInteger integerValue = 0;
    memcpy(&integerValue, valueAddress, self.valueSize);
    return integerValue;
}

- (CGFloat) floatAtRow:(NSUInteger)row column:(NSUInteger)column
{
    if (self.valueSize != sizeof(CGFloat)) {
        [[NSException exceptionWithName:NSRangeException reason:nil userInfo:nil] raise];
    }
    void* valueAddress = [self addressOfRow:row column:column];
    CGFloat floatValue = 0;
    memcpy(&floatValue, valueAddress, self.valueSize);
    return floatValue;
}

- (UniChar) uniCharAtRow:(NSUInteger)row column:(NSUInteger)column
{
    if (self.valueSize != sizeof(UniChar)) {
        [[NSException exceptionWithName:NSRangeException reason:nil userInfo:nil] raise];
    }
    void* valueAddress = [self addressOfRow:row column:column];
    UniChar unicharValue = 0;
    memcpy(&unicharValue, valueAddress, self.valueSize);
    return unicharValue;
}

- (CGFloat) percentOfValueAtRow:(NSUInteger) row column:(NSUInteger) col inRange:(NSRange) range // TODO negative and floating point ranges
{
    // TODO? CGFloat minValue = range.location;
    CGFloat maxValue = range.location + range.length;
    CGFloat percent = 0.0;
    
    if (self.valueSize == sizeof(uint8_t)) {
        uint8_t thisValue = [self byteAtRow:row column:col];
        percent = (thisValue / maxValue);
    }
    else if (self.valueSize == sizeof(NSInteger)) {
        NSInteger thisValue = [self integerAtRow:row column:col];
        if (thisValue > 0) {
            percent = (thisValue / maxValue);
        }
        else if (thisValue < 0) {
            percent = (labs(thisValue) / maxValue);
        }
    }
    
    return percent;
}

#pragma mark - setters

- (void) setValue:(void*)dataPtr ofSize:(size_t)length atRow:(NSUInteger)row column:(NSUInteger)column;
{
    void* valueAddress = [self addressOfRow:row column:column];
    memcpy(valueAddress, dataPtr, length);
}

- (void) setByte:(uint8_t) byteValue atRow:(NSUInteger)row column:(NSUInteger)column
{
    [self setValue:&byteValue ofSize:sizeof(uint8_t) atRow:row column:column];
}

- (void) setInteger:(NSInteger) integerValue atRow:(NSUInteger)row column:(NSUInteger)column
{
    [self setValue:&integerValue ofSize:sizeof(NSInteger) atRow:row column:column];
}

- (void) setFloat:(CGFloat) floatValue atRow:(NSUInteger) row column:(NSUInteger)column
{
    [self setValue:&floatValue ofSize:sizeof(CGFloat) atRow:row column:column];
}

- (void) setUniChar:(UniChar) charValue atRow:(NSUInteger) row column:(NSUInteger)column
{
    [self setValue:&charValue ofSize:sizeof(UniChar) atRow:row column:column];
}

#pragma mark -  fill routines

- (void) fillByteValue:(uint8_t) byteValue
{
    NSUInteger row = 0;
    NSUInteger col = 0;
    while (row < self.rows) {
        while (col < self.columns) {
            [self setByte:byteValue atRow:row column:col];
            col++;
        }
        col = 0;
        row++;
    }
}

- (void) fillIntegerValue:(NSInteger) integerValue
{
    NSUInteger row = 0;
    NSUInteger col = 0;
    while (row < self.rows) {
        while (col < self.columns) {
            [self setInteger:integerValue atRow:row column:col];
            col++;
        }
        col = 0;
        row++;
    } //*/
}

- (void) fillUniCharValue:(UniChar) unicharValue
{
    NSUInteger row = 0;
    NSUInteger col = 0;
    while (row < self.rows) {
        while (col < self.columns) {
            [self setUniChar:unicharValue atRow:row column:col];
            col++;
        }
        col = 0;
        row++;
    }
}

- (void) fillFloatValue:(CGFloat) floatValue
{
    NSUInteger row = 0;
    NSUInteger col = 0;
    while (row < self.rows) {
        while (col < self.columns) {
            [self setFloat:floatValue atRow:row column:col];
            col++;
        }
        col = 0;
        row++;
    }
}

#pragma mark -

- (NSString*) integerGridRepresentation
{
    NSMutableString* gridRep = [NSMutableString stringWithString:@""];
    NSUInteger rowIndex = 0;
    while (rowIndex < self.rows) {
        NSUInteger columnIndex = 0; // reset to zero for each row
        while (columnIndex < self.columns) {
            NSInteger datum = [self integerAtRow:rowIndex column:columnIndex];
            [gridRep appendFormat:@"% 5li", (long)datum];
//            [gridRep appendFormat:@"% 3li,% 3li", rowIndex, columnIndex];
            if (columnIndex++ < (self.columns - 1)) {
                [gridRep appendString:@" "];
            }
        }

        if (rowIndex++ < (self.rows - 1)) {
            [gridRep appendString:@",\n"];
        }
    }
    return gridRep;
}

- (NSString*) jsonIntegerRepresentation
{
    NSMutableString* jsonRep = [NSMutableString stringWithString:@""];
    NSUInteger rowIndex = 0;
    [jsonRep appendString:@"["];
    while( rowIndex < self.rows )
    {
        NSUInteger columnIndex = 0; // reset to zero for each row
        [jsonRep appendString:@"["];
        while ( columnIndex < self.columns )
        {
            NSInteger datum = [self integerAtRow:rowIndex column:columnIndex];
            [jsonRep appendFormat:@"%li", (long)datum];
            if ( columnIndex++ < (self.columns-1) )
                [jsonRep appendString:@","];
        }
        [jsonRep appendString:@"]"];
        if ( rowIndex++ < (self.rows-1) )
            [jsonRep appendString:@",\n"];

    }
    [jsonRep appendString:@"]"];
    return jsonRep;
} // arrays of arrays of numbers

- (NSString*) jsonFloatRepresentation
{
    NSMutableString* jsonRep = [NSMutableString stringWithString:@""];
    NSUInteger rowIndex = 0;
    [jsonRep appendString:@"["];
    while( rowIndex < self.rows )
    {
        NSUInteger columnIndex = 0; // reset to zero for each row
        [jsonRep appendString:@"["];
        while ( columnIndex < self.columns )
        {
            CGFloat datum = [self floatAtRow:rowIndex column:columnIndex];
            [jsonRep appendFormat:@"'%lf'", datum];
            if ( columnIndex++ < (self.columns-1) )
                [jsonRep appendString:@","];
        }
        [jsonRep appendString:@"]"];
        if ( rowIndex++ < (self.rows-1) )
            [jsonRep appendString:@",\n"];
        
    }
    [jsonRep appendString:@"]"];
    return jsonRep;
} // arrays of arrays of numbers

- (NSString*) jsonUniCharRepresentation
{
    NSMutableString* jsonRep = [NSMutableString stringWithString:@""];
    NSUInteger rowIndex = 0;
    [jsonRep appendString:@"["];
    while( rowIndex < self.rows )
    {
        NSUInteger columnIndex = 0; // reset to zero for each row
        [jsonRep appendString:@"["];
        while ( columnIndex < self.columns )
        {
            UniChar datum = [self uniCharAtRow:rowIndex column:columnIndex];
            [jsonRep appendFormat:@"'%C'", datum];
            if ( columnIndex++ < (self.columns-1) )
                [jsonRep appendString:@","];
        }
        [jsonRep appendString:@"]"];
        if ( rowIndex++ < (self.rows-1) )
            [jsonRep appendString:@",\n"];
        
    }
    [jsonRep appendString:@"]"];
    return jsonRep;
} // arrays of unichar strings

#pragma mark - Image Representations

-(CGImageRef)grayscaleBitmapOfRow:(NSUInteger)thisRow withRange:(NSRange)range
{
    CGImageRef rowBitMap = nil;
    @synchronized (self) {
        CGColorSpaceRef grayscale = CGColorSpaceCreateDeviceGray();
        size_t channelDepth = 8;
        size_t channelCount = CGColorSpaceGetNumberOfComponents(grayscale);
        size_t pixelBits = (channelDepth * channelCount);
        CGSize rowSize = CGSizeMake(self.columns, 1);
        size_t imageSize = (pixelBits * rowSize.width);
        void* imageData = calloc(1, imageSize);
        CGContextRef rowContext = CGBitmapContextCreate(imageData, rowSize.width, rowSize.height, pixelBits, imageSize, grayscale, kCGImageAlphaNone);
        CGContextSetFillColorSpace(rowContext, grayscale);

        NSUInteger thisColumn = 0;
        while (thisColumn < self.columns) {
            CGFloat percentValue = [self percentOfValueAtRow:thisRow column:thisColumn inRange:range];
            const CGFloat percentComponents[] = {(1.0 - percentValue),  1.0};
            CGContextSetFillColor(rowContext, (const CGFloat*)&percentComponents);
            // CGContextSetAlpha(rowContext, (1.0 - percentValue));
            CGContextFillRect(rowContext, CGRectMake(thisColumn, 0, 1, 1)); // single pixel
            thisColumn++;
        }

        rowBitMap = CGBitmapContextCreateImage(rowContext);
exit:
        CGContextRelease(rowContext);
        CGColorSpaceRelease(grayscale);
        free(imageData);
        // CFAutorelease(rowBitMap);
    }
    
    return rowBitMap;
}

-(CGImageRef)grayscaleBitmapWithRange:(NSRange)range
{
    CGImageRef rowBitMap = nil;
    @synchronized (self) {
        CGSize gridSize = CGSizeMake(self.columns, self.rows);
        CGColorSpaceRef grayscale = CGColorSpaceCreateDeviceGray();
        size_t bitsPerComponent = 8;
        size_t channelCount = CGColorSpaceGetNumberOfComponents(grayscale);
        size_t bytesPerRow = (channelCount * gridSize.width);
        size_t imageBytes =  (bytesPerRow * gridSize.height);
        CFMutableDataRef imageData = CFDataCreateMutable(kCFAllocatorDefault, imageBytes);
        CGContextRef gridContext = CGBitmapContextCreate((void*)CFDataGetMutableBytePtr(imageData), gridSize.width, gridSize.height, bitsPerComponent, bytesPerRow, grayscale, kCGImageAlphaNone);
        CGContextSetFillColorSpace(gridContext, grayscale);

        NSUInteger thisRow = 0;
        while (thisRow < gridSize.height) {
        NSUInteger thisColumn = 0;
            while (thisColumn < gridSize.width) {
                CGFloat percentValue = [self percentOfValueAtRow:thisRow column:thisColumn inRange:range];
                const CGFloat percentComponents[] = {(1.0 - percentValue),  1.0};
                CGContextSetFillColor(gridContext, (const CGFloat*)&percentComponents);
                CGContextFillRect(gridContext, CGRectMake(thisColumn, thisRow, 1, 1)); // single pixel
                thisColumn++;
            }
            thisRow++;
        }

        rowBitMap = CGBitmapContextCreateImage(gridContext);
exit:
        CGContextRelease(gridContext);
        CGColorSpaceRelease(grayscale);
        CFRelease(imageData);
        // CFAutorelease(rowBitMap);
    }

    return rowBitMap;
}

- (CGImageRef) alphaBitmapOfRow:(NSUInteger)thisRow withRange:(NSRange)range
{
    CGImageRef rowBitMap = nil;
    @synchronized (self) {
        CGSize rowSize = CGSizeMake(self.columns, 1);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        size_t bitsPerComponent = 8;
        size_t channelCount = CGColorSpaceGetNumberOfComponents(colorSpace);
        size_t bytesPerRow = (channelCount * rowSize.width);
        size_t imageSize = (bytesPerRow * rowSize.height);
        CFMutableDataRef imageData = CFDataCreateMutable(kCFAllocatorDefault, imageSize);
        CGContextRef maskContext = CGBitmapContextCreate((void*)CFDataGetMutableBytePtr(imageData), rowSize.width, rowSize.height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaOnly);
        CGContextSetFillColorSpace(maskContext, colorSpace);
        
        NSUInteger thisColumn = 0;
        while (thisColumn < self.columns) {
            CGFloat percentValue = [self percentOfValueAtRow:thisRow column:thisColumn inRange:range];
            const CGFloat percentComponents[] = {percentValue,  1.0};
            CGContextSetFillColor(maskContext, (const CGFloat*)&percentComponents);
            CGContextSetAlpha(maskContext, percentValue);
            CGContextFillRect(maskContext, CGRectMake(thisColumn, 0, 1, 1)); // single pixel
            thisColumn++;
        }
        
        rowBitMap = CGBitmapContextCreateImage(maskContext);
    exit:
        CGContextRelease(maskContext);
        CGColorSpaceRelease(colorSpace);
        CFRelease(imageData);
        // CFAutorelease(rowBitMap);
    }
    
    return rowBitMap;
}

- (CGImageRef) alphaBitmapWithRange:(NSRange) range
{
    CGImageRef maskBitMap = nil;
    @synchronized (self) {
        CGSize gridSize = CGSizeMake(self.columns, self.rows);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        size_t bitsPerComponent = 8;
        size_t channelCount = CGColorSpaceGetNumberOfComponents(colorSpace);
        size_t bytesPerRow = (channelCount * gridSize.width);
        size_t imageSize =  (bytesPerRow * gridSize.height);
        CFMutableDataRef imageData = CFDataCreateMutable(kCFAllocatorDefault, imageSize);
        CGContextRef maskContext = CGBitmapContextCreate((void*)CFDataGetMutableBytePtr(imageData), gridSize.width, gridSize.height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaOnly);
        CGDataProviderRef maskDataProvider = CGDataProviderCreateWithCFData(imageData);
        CGContextSetFillColorSpace(maskContext, colorSpace);

        NSUInteger thisRow = 0;
        while (thisRow < gridSize.height) {
            NSUInteger thisColumn = 0;
            while (thisColumn < gridSize.width) {
                CGFloat percentValue = [self percentOfValueAtRow:thisRow column:thisColumn inRange:range];
                // const CGFloat percentComponents[] = {1.0,  percentValue};
                // CGContextSetFillColor(maskContext, (const CGFloat*)&percentComponents);
                CGContextSetAlpha(maskContext, percentValue);
                CGContextFillRect(maskContext, CGRectMake(thisColumn, thisRow, 1, 1)); // single pixel
                thisColumn++;
            }
            thisRow++;
        }

        maskBitMap = CGImageMaskCreate(gridSize.width, gridSize.height, bitsPerComponent, bitsPerComponent, bytesPerRow, maskDataProvider, nil, NO);
exit:
        CGContextRelease(maskContext);
        CGColorSpaceRelease(colorSpace);
        CGDataProviderRelease(maskDataProvider);
        CFRelease(imageData);
        // CFAutorelease(maskBitMap);
    }
    
    return maskBitMap;
}

#pragma mark - Slices

- (NSData*) dataAtRow:(NSUInteger)row
{
    return [NSData dataWithBytes:[self addressOfRow:row column:0] length:[self sizeOfRow]];
}

- (void) setData:(NSData*) slice atRow:(NSUInteger)row
{
    @synchronized (self) {
        NSInteger index = (row * [self sizeOfRow]);
        if ((index + [self sizeOfRow]) <= self.data.length) {
            [self.data replaceBytesInRange:NSMakeRange(index, [self sizeOfRow]) withBytes:[slice bytes]];
        }
        else {
            [[NSException
                exceptionWithName:NSRangeException
                reason:[NSString stringWithFormat:@"%@ setData:atRow: slice lands outside of data range: %@ row %lu", self, slice, (unsigned long)row]
                userInfo:nil] raise];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(grid:didSetData:atRow:)]) {
            [self.delegate grid:self didSetData:slice atRow:row];
        }
    }
}

- (void) appendData:(NSData*) slice
{
    @synchronized (self) {
        if (self.columns > 0 && self.valueSize > 0) {
            NSInteger sliceColumns = (slice.length / self.valueSize);
            if ((sliceColumns % self.columns) == 0) { // allow appending 0-N rows at a time
                [self.data appendData:slice];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(grid:didAppendedData:asRow:)]) {
                    [self.delegate grid:self didAppendedData:slice asRow:(self.rows - 1)];
                }
            }
            else NSLog(@"EXCEPTION appending data: %@, wrong sized slice: %lu bytes for grid: %@", slice, (unsigned long)slice.length, self);
        }
        else NSLog(@"EXCEPTION appending data: %@ to a grid with 0 columns or no value size: %@", slice, self);
    }
}

- (void) trimToRangeOfRows:(NSRange)rowRange
{
    @synchronized (self) {
        if ((rowRange.location + rowRange.length) <= self.rows) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(grid:willTrimToRangeOfRows:)]) {
                [self.delegate grid:self willTrimToRangeOfRows:rowRange];
            }
            
            size_t rowSize = [self sizeOfRow];
            NSRange byteRange = NSMakeRange((rowRange.location * rowSize), (rowRange.length * rowSize));
            NSData* trimmedData = [self.data subdataWithRange:byteRange];
            
            if (self.columns > 0 && ((trimmedData.length % self.columns) != 0)) {
                NSLog(@"EXCEPTION byte range (%lu,%lu) invalid data length: %lu", (unsigned long)byteRange.location, (unsigned long)byteRange.length, (unsigned long)trimmedData.length);
            }
            
            [self.data setData:trimmedData];
        }
        else NSLog(@"EXCEPTION trimmed range (%lu,%lu) exceeds grid size: %lu", (unsigned long)rowRange.location, (unsigned long)rowRange.length, (unsigned long)self.rows);
    }
}

- (void) extendToRow:(NSUInteger)rows
{
    @synchronized (self) {
        NSUInteger row = self.rows;
        while (row < rows) {
            NSMutableData* extendedData = [NSMutableData dataWithLength:self.sizeOfRow];
            bzero((void*)extendedData.bytes, extendedData.length);
            [self appendData:extendedData];
            row++;
        }
    }
}

#pragma mark - Buckets

- (NSArray<NSNumber*>*) bucketsAtRow:(NSUInteger)row withRange:(NSRange)valueRange
{
    NSMutableArray<NSNumber*>* buckets = [NSMutableArray arrayWithCapacity:self.columns];
    @synchronized (self) {
        NSUInteger thisColumn = 0;
        while (thisColumn < self.columns) {
            CGFloat percentValue = [self percentOfValueAtRow:row column:thisColumn inRange:valueRange];
            buckets[thisColumn] = @(percentValue);
            thisColumn++;
        }
    }
    
    return buckets;
}

@end

#if IL_APP_KIT
#pragma mark -

@implementation ILGridTableDataSource

#pragma mark - NSTableViewDataSource

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.grid.rows;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    id value = nil;
    NSUInteger columnIndex = [tableView.tableColumns indexOfObject:tableColumn];

    if (columnIndex == 0) {
        value = self.labels[row];
    }
    else {
        if (self.grid.dataType == ILGridDataIntegerType) {
            value = [NSNumber numberWithDouble:[self.grid percentOfValueAtRow:row column:(columnIndex - 1) inRange:self.range]];
            // value = [NSNumber numberWithInteger:[self.grid integerAtRow:row column:columnIndex-1]];
        }
        else if (self.grid.dataType == ILGridDataByteType) {
            value = [NSNumber numberWithUnsignedShort:[self.grid byteAtRow:row column:(columnIndex - 1)]];
        }
        else if (self.grid.dataType == ILGridDataFloatType) {
            value = [NSNumber numberWithDouble:[self.grid floatAtRow:row column:columnIndex-1]];
        }
        else if (self.grid.dataType == ILGridDataUnicharType) {
            value = [NSString stringWithFormat:@"%C", [self.grid uniCharAtRow:row column:(columnIndex - 1)]];
        }
    }
    
    return value;
}

@end
#endif
