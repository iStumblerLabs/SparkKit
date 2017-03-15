#import "ILGridData.h"

@implementation ILGridData

- (NSUInteger) rows
{
    return gridRows;
}

- (NSUInteger) columns
{
    return gridColumns;
}

- (NSUInteger) valueSize
{
    return gridValueSize;
}

- (CGFloat) minValue
{
    return gridMinValue;
}

- (CGFloat) maxValue
{
    return gridMaxValue;
}

- (ILGridDataType) type
{
    return gridType;
}

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
    while ( count < MIN(floatTestGrid.gridColumns,floatTestGrid.gridRows))
    {
        [floatTestGrid setFloat:sinf(count) atRow:count column:count];
        count++;
    }
    NSLog(@"floatTestGrid: \n%@", [floatTestGrid jsonFloatRepresentation]);

}
*/

#pragma mark -

+ (ILGridData*) byteGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    ILGridData* byteGrid = [[ILGridData alloc] initGridWithRows:rows columns:columns valueSize:sizeof(uint8_t) gridType:ILGridDataByteType];
    [byteGrid fillByteValue:0];
    return byteGrid;
}

+ (ILGridData*) integerGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    ILGridData* integerGrid = [[ILGridData alloc] initGridWithRows:rows columns:columns valueSize:sizeof(NSInteger) gridType:ILGridDataIntegerType];
    [integerGrid fillIntegerValue:0];
    return integerGrid;
}

+ (ILGridData*) floatGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    ILGridData* floatGrid = [[ILGridData alloc] initGridWithRows:rows columns:columns valueSize:sizeof(CGFloat) gridType:ILGridDataFloatType];
    [floatGrid fillFloatValue:0.0];
    return floatGrid;
}

+ (ILGridData*) uniCharGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    ILGridData* unicharGrid = [[ILGridData alloc] initGridWithRows:rows columns:columns valueSize:sizeof(UniChar) gridType:ILGridDataUnicharType];
    
    [unicharGrid fillUniCharValue:' '];
    return unicharGrid;
}

#pragma mark -

/** designated initilizer */
- (ILGridData*) initGridWithRows:(NSUInteger)rows columns:(NSUInteger)columns valueSize:(NSUInteger)size gridType:(ILGridDataType) type
{
    NSUInteger gridSize = (rows * columns * size);
//    NSLog(@"MutableGrid rows: %lu columns: %lu size: %lu", rows, columns, gridSize);
    if (self = [super init]) {
        data = [NSMutableData dataWithLength:gridSize];
        gridRows = rows;
        gridColumns = columns;
        gridValueSize = size;
        gridType = type;
        gridMinValue = 0;
        gridMaxValue = -1500; // this negative case has to work for samples in DBm, and it should anyway

        bzero((void*)[data bytes], gridSize);
    }
    return self;
}

#pragma mark -

- (size_t) sizeOfRow
{
    return (gridColumns * gridValueSize);
}

- (void*) addressOfRow:(NSUInteger)row column:(NSUInteger)column
{
    if ((row > gridRows) || (column > gridColumns)){
        [[NSException exceptionWithName:NSRangeException reason:[NSString stringWithFormat:@"row: %lu or column: %lu out of range: %lu x %lu", row, column, self.rows, self.columns] userInfo:nil] raise];
    }
    
    NSUInteger columnWidth = gridColumns * gridValueSize;
    NSUInteger offset = (row*columnWidth) + (column*gridValueSize); // offset in bytes
    
/*   NSLog(@"grid %lu x %lu = %lu",row,column,offset);
    if( offset > [data length]) // range check so we don't send a pointer to hyperspace
    {
        [[NSException exceptionWithName:NSRangeException reason:[NSString stringWithFormat:@"offset: %lu larger than data: %lu", offset, [data length]] userInfo:nil] raise];
    }
*/
    return [data mutableBytes] + offset;
}

- (uint8_t) byteAtRow:(NSUInteger)row column:(NSUInteger)column
{
    if (gridValueSize != sizeof(uint8_t)) {
        [[NSException exceptionWithName:NSRangeException reason:nil userInfo:nil] raise];
    }
    void* valueAddress = [self addressOfRow:row column:column];
    uint8_t byteValue = 0;
    memcpy(&byteValue, valueAddress, gridValueSize);
    return byteValue;
}

- (NSInteger) integerAtRow:(NSUInteger)row column:(NSUInteger)column
{
    if (gridValueSize != sizeof(NSInteger)) {
        [[NSException exceptionWithName:NSRangeException reason:nil userInfo:nil] raise];
    }
    void* valueAddress = [self addressOfRow:row column:column];
    NSInteger integerValue = 0;
    memcpy(&integerValue, valueAddress, gridValueSize);
    return integerValue;
}

- (CGFloat) floatAtRow:(NSUInteger)row column:(NSUInteger)column
{
    if (gridValueSize != sizeof(CGFloat)) {
        [[NSException exceptionWithName:NSRangeException reason:nil userInfo:nil] raise];
    }
    void* valueAddress = [self addressOfRow:row column:column];
    CGFloat floatValue = 0;
    memcpy(&floatValue, valueAddress, gridValueSize);
    return floatValue;
}

- (UniChar) uniCharAtRow:(NSUInteger)row column:(NSUInteger)column
{
    if (gridValueSize != sizeof(UniChar)) {
        [[NSException exceptionWithName:NSRangeException reason:nil userInfo:nil] raise];
    }
    void* valueAddress = [self addressOfRow:row column:column];
    UniChar unicharValue = 0;
    memcpy(&unicharValue, valueAddress, gridValueSize);
    return unicharValue;
}

- (CGFloat) percentAtRow:(NSUInteger) row column:(NSUInteger) col
{
    CGFloat percent = 0.0;
    
    if (gridType == ILGridDataIntegerType) {
        NSInteger thisValue = [self integerAtRow:row column:col];
        if( thisValue > 0) {
            percent = fabs(thisValue / gridMaxValue);
        }
        else {
            percent = fabs(thisValue / gridMinValue);
        }
    }
    else if( gridType == ILGridDataByteType) {
        uint8_t thisValue = [self byteAtRow:row column:col];
        percent = (CGFloat)thisValue/256;
    }
    else if( gridType == ILGridDataFloatType) {
        CGFloat thisValue = [self floatAtRow:row column:col];
        percent = (thisValue / gridMaxValue);
    }
    
    return percent;
}

- (void) setValueAtRow:(NSUInteger)row column:(NSUInteger)column data:(void*)dataPtr length:(NSUInteger) length
{
    void* valueAddress = [self addressOfRow:row column:column];
//    NSLog(@"setValueAtRow: %lu column: %lu data: %p length: %lu valueAddress: %p", row, column, dataPtr, length, valueAddress);
    memcpy(valueAddress, dataPtr, length);
}

- (void) setByte:(uint8_t) byteValue atRow:(NSUInteger)row column:(NSUInteger)column
{
    if (byteValue > gridMaxValue) {
        gridMaxValue = byteValue;
    }

    if (byteValue < gridMinValue) {
        gridMinValue = byteValue;
    }
    
//    NSLog(@"setByte: 0x%X atRow: %lu column: %lu", integerValue, row, column);
    [self setValueAtRow:row column:column data:&byteValue length:gridValueSize];
}

- (void) setInteger:(NSInteger) integerValue atRow:(NSUInteger)row column:(NSUInteger)column
{
    if (integerValue > gridMaxValue) {
        gridMaxValue = integerValue;
    }

    if (integerValue < gridMinValue) {
        gridMinValue = integerValue;
    }
    
//    NSLog(@"setInteger: %li atRow: %lu column: %lu", integerValue, row, column);
    [self setValueAtRow:row column:column data:&integerValue length:gridValueSize];
}

- (void) setFloat:(CGFloat) floatValue atRow:(NSUInteger) row column:(NSUInteger)column
{
    if (floatValue > gridMaxValue) {
        gridMaxValue = floatValue;
    }
    
    if (floatValue < gridMinValue) {
        gridMinValue = floatValue;
    }

    [self setValueAtRow:row column:column data:&floatValue length:gridValueSize];
}

- (void) setUniChar:(UniChar) charValue atRow:(NSUInteger) row column:(NSUInteger)column
{
    [self setValueAtRow:row column:column data:&charValue length:gridValueSize];
}

#pragma mark -
#pragma mark fill routines

- (void) fillByteValue:(uint8_t) byteValue
{
    NSUInteger row = 0;
    NSUInteger col = 0;
    while (row < gridRows) {
        while (col < gridColumns) {
            [self setByte:byteValue atRow:row column:col];
            col++;
        }
        col = 0;
        row++;
    }
    gridMinValue = byteValue;
    gridMaxValue = byteValue;
}

- (void) fillIntegerValue:(NSInteger) integerValue
{
    NSUInteger row = 0;
    NSUInteger col = 0;
    while (row < gridRows) {
        while (col < gridColumns) {
            [self setInteger:integerValue atRow:row column:col];
            col++;
        }
        col = 0;
        row++;
    } //*/
    gridMinValue = integerValue;
    gridMaxValue = integerValue;
}

- (void) fillUniCharValue:(UniChar) unicharValue
{
    NSUInteger row = 0;
    NSUInteger col = 0;
    while (row < gridRows) {
        while (col < gridColumns) {
            [self setUniChar:unicharValue atRow:row column:col];
            col++;
        }
        col = 0;
        row++;
    }
    gridMinValue = unicharValue;
    gridMaxValue = unicharValue;
}

- (void) fillFloatValue:(CGFloat) floatValue
{
    NSUInteger row = 0;
    NSUInteger col = 0;
    while (row < gridRows) {
        while (col < gridColumns) {
            [self setFloat:floatValue atRow:row column:col];
            col++;
        }
        col = 0;
        row++;
    }
    gridMinValue = floatValue;
    gridMaxValue = floatValue;
}

#pragma mark -

- (NSString*) integerGridRepresentation
{
    NSMutableString* gridRep = [NSMutableString stringWithString:@""];
    NSUInteger rowIndex = 0;
    while (rowIndex < gridRows) {
        NSUInteger columnIndex = 0; // reset to zero for each row
        while (columnIndex < gridColumns) {
            NSInteger datum = [self integerAtRow:rowIndex column:columnIndex];
            [gridRep appendFormat:@"% 5li", datum];
//            [gridRep appendFormat:@"% 3li,% 3li", rowIndex, columnIndex];
            if (columnIndex++ < (gridColumns - 1)) {
                [gridRep appendString:@" "];
            }
        }

        if (rowIndex++ < (gridRows - 1)) {
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
    while( rowIndex < gridRows )
    {
        NSUInteger columnIndex = 0; // reset to zero for each row
        [jsonRep appendString:@"["];
        while ( columnIndex < gridColumns )
        {
            NSInteger datum = [self integerAtRow:rowIndex column:columnIndex];
            [jsonRep appendFormat:@"%li", datum];
            if ( columnIndex++ < (gridColumns-1) )
                [jsonRep appendString:@","];
        }
        [jsonRep appendString:@"]"];
        if ( rowIndex++ < (gridRows-1) )
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
    while( rowIndex < gridRows )
    {
        NSUInteger columnIndex = 0; // reset to zero for each row
        [jsonRep appendString:@"["];
        while ( columnIndex < gridColumns )
        {
            CGFloat datum = [self floatAtRow:rowIndex column:columnIndex];
            [jsonRep appendFormat:@"'%lf'", datum];
            if ( columnIndex++ < (gridColumns-1) )
                [jsonRep appendString:@","];
        }
        [jsonRep appendString:@"]"];
        if ( rowIndex++ < (gridRows-1) )
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
    while( rowIndex < gridRows )
    {
        NSUInteger columnIndex = 0; // reset to zero for each row
        [jsonRep appendString:@"["];
        while ( columnIndex < gridColumns )
        {
            UniChar datum = [self uniCharAtRow:rowIndex column:columnIndex];
            [jsonRep appendFormat:@"'%C'", datum];
            if ( columnIndex++ < (gridColumns-1) )
                [jsonRep appendString:@","];
        }
        [jsonRep appendString:@"]"];
        if ( rowIndex++ < (gridRows-1) )
            [jsonRep appendString:@",\n"];
        
    }
    [jsonRep appendString:@"]"];
    return jsonRep;
} // arrays of unichar strings

#pragma mark - Image Representations

-(CGImageRef)newGrayscaleBitmapOfRow:(NSUInteger)thisRow
{
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
        CGFloat percentValue = [self percentAtRow:thisRow column:thisColumn];
        const CGFloat percentComponents[] = {(1.0 - percentValue),  1.0};
        CGContextSetFillColor(rowContext, (const CGFloat*)&percentComponents);
        // CGContextSetAlpha(rowContext, (1.0 - percentValue));
        CGContextFillRect(rowContext, CGRectMake(thisColumn, 0, 1, 1)); // single pixel
        thisColumn++;
    }

    CGImageRef rowBitMap = CGBitmapContextCreateImage(rowContext);
exit:
    CGContextRelease(rowContext);
    CGColorSpaceRelease(grayscale);
    free(imageData);
    return rowBitMap;
}

-(CGImageRef)newGrayscaleBitmap
{
    CGColorSpaceRef grayscale = CGColorSpaceCreateDeviceGray();
    CGSize gridSize = CGSizeMake(self.columns, self.rows);
    size_t bitsPerComponent = 8;
    size_t channelCount = CGColorSpaceGetNumberOfComponents(grayscale);
    size_t bytesPerRow = (channelCount * gridSize.width);
    size_t imageBytes =  (bytesPerRow * gridSize.height);
    void* imageData = calloc(1, imageBytes);
    CGContextRef gridContext = CGBitmapContextCreate(imageData, gridSize.width, gridSize.height, bitsPerComponent, bytesPerRow, grayscale, kCGImageAlphaNone);
    CGContextSetFillColorSpace(gridContext, grayscale);

    NSUInteger thisRow = 0;
    while (thisRow < self.rows) {
    NSUInteger thisColumn = 0;
        while (thisColumn < self.columns) {
            CGFloat percentValue = [self percentAtRow:thisRow column:thisColumn];
            const CGFloat percentComponents[] = {(1.0 - percentValue),  1.0};
            CGContextSetFillColor(gridContext, (const CGFloat*)&percentComponents);
            // CGContextSetAlpha(rowContext, (1.0 - percentValue));
            CGContextFillRect(gridContext, CGRectMake(thisColumn, thisRow, 1, 1)); // single pixel
            thisColumn++;
        }
        thisRow++;
    }

    CGImageRef rowBitMap = CGBitmapContextCreateImage(gridContext);
exit:
    CGContextRelease(gridContext);
    CGColorSpaceRelease(grayscale);
    free(imageData);
    return rowBitMap;
}

-(CGImageRef)newAlphaBitmap
{
    CGColorSpaceRef grayscale = CGColorSpaceCreateDeviceGray();
    CGSize gridSize = CGSizeMake(self.columns, self.rows);
    size_t bitsPerComponent = 8;
    size_t channelCount = CGColorSpaceGetNumberOfComponents(grayscale);
    size_t bytesPerRow = (channelCount * gridSize.width);
    size_t imageBytes =  (bytesPerRow * gridSize.height);
    void* imageData = calloc(1, imageBytes);
    CGContextRef maskContext = CGBitmapContextCreate(imageData, gridSize.width, gridSize.height, bitsPerComponent, bytesPerRow, grayscale, kCGImageAlphaNone);
    CGContextSetFillColorSpace(maskContext, grayscale);

    NSUInteger thisRow = 0;
    while (thisRow < self.rows) {
    NSUInteger thisColumn = 0;
        while (thisColumn < self.columns) {
            CGFloat percentValue = [self percentAtRow:thisRow column:thisColumn];
            // const CGFloat percentComponents[] = {0.0,  percentValue};
            // CGContextSetFillColor(gridContext, (const CGFloat*)&percentComponents);
            CGContextSetAlpha(maskContext, percentValue);
            CGContextFillRect(maskContext, CGRectMake(thisColumn, thisRow, 1, 1)); // single pixel
            thisColumn++;
        }
        thisRow++;
    }

    CGImageRef maskBitMap = CGBitmapContextCreateImage(maskContext);
exit:
    CGContextRelease(maskContext);
    CGColorSpaceRelease(grayscale);
    free(imageData);
    return maskBitMap;
}

#pragma mark - Slices

- (NSData*) dataAtRow:(NSUInteger)row
{
    return [NSData dataWithBytes:[self addressOfRow:row column:0] length:[self sizeOfRow]];
}

- (void) setData:(NSData*) slice atRow:(NSUInteger)row
{
    NSInteger index = (row * [self sizeOfRow]);
    if (index+[self sizeOfRow] <= data.length) {
        [data replaceBytesInRange:NSMakeRange(index, [self sizeOfRow])
                        withBytes:[slice bytes]];
    }
    else NSLog(@"EXCEPTION %@ setData:atRow: slice lands outside of data range: %@ row %lu", self, slice, row);
    
    // check the row and set the min/max values
    NSUInteger colIndex = 0;
    while (colIndex < gridColumns) {
        switch (gridType) {
            case ILGridDataByteType: {
                uint8_t byte = [self byteAtRow:row column:colIndex];
                if (byte > gridMaxValue) {
                    gridMaxValue = byte;
                }
                else if (byte > gridMinValue) {
                    gridMinValue = byte;
                }
                break;
            }

            case ILGridDataIntegerType: {
                NSInteger integer = [self integerAtRow:row column:colIndex];
                if( integer > gridMaxValue) {
                    gridMaxValue = integer;
                }
                else if ( integer < gridMinValue) {
                    gridMinValue = integer;
                }
                break;
            }
                
            case ILGridDataFloatType: {
                CGFloat floatValue = [self floatAtRow:row column:colIndex];
                if (floatValue > gridMaxValue) {
                    gridMaxValue = floatValue;
                }
                else if (floatValue < gridMinValue) {
                    gridMinValue = floatValue;
                }
                break;
            }
                
            case ILGridDataUnicharType: {
                UniChar charValue = [self floatAtRow:row column:colIndex];
                if( charValue > gridMaxValue)
                    gridMaxValue = charValue;
                else if ( charValue < gridMinValue)
                    gridMinValue = charValue;
                break;
            }
        }
        colIndex++;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(grid:didSetData:atRow:)]) {
        [self.delegate grid:self didSetData:slice atRow:row];
    }
}

- (void)appendData:(NSData*) slice
{
    NSInteger sliceColumns = (slice.length / gridValueSize);
    if ((sliceColumns % self.columns) == 0) { // allow appending 0-N rows at a time
        [data appendData:slice];
        gridRows++;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(grid:didAppendedData:asRow:)]) {
            [self.delegate grid:self didAppendedData:slice asRow:gridRows];
        }
    }
    else NSLog(@"EXCEPTION appendData, wrong sized slice: %lu bytes", slice.length);
}

- (void)trimToRangeOfRows:(NSRange)rowRange;
{
    if ((rowRange.location + rowRange.length) <= gridRows) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(grid:willTrimToRangeOfRows:)]) {
            [self.delegate grid:self willTrimToRangeOfRows:rowRange];
        }
        
        size_t rowSize = [self sizeOfRow];
        NSRange byteRange = NSMakeRange((rowRange.location * rowSize), (rowRange.length * rowSize));
        NSData* trimmedData = [data subdataWithRange:byteRange];
        [data setData:trimmedData];
        gridRows = rowRange.length;
    }
    else NSLog(@"EXCEPTION trimmed range (%lu,%lu) exceeds grid size: %lu", rowRange.location, rowRange.length, gridRows);
}

@end

#pragma mark -
#if IL_APP_KIT

@implementation ILGridTableDataSource

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.grid.rows;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    id value = nil;
    NSUInteger columnIndex = [tableView.tableColumns indexOfObject:tableColumn];

    if (columnIndex == 0) {
        value = self.labels[row];
    }
    else {
        if (self.grid.type == ILGridDataIntegerType) {
            value = [NSNumber numberWithDouble:[self.grid percentAtRow:row column:columnIndex-1]];
            // value = [NSNumber numberWithInteger:[self.grid integerAtRow:row column:columnIndex-1]];
        }
        else if (self.grid.type == ILGridDataFloatType) {
            value = [NSNumber numberWithDouble:[self.grid floatAtRow:row column:columnIndex-1]];
        }
        else if (self.grid.type == ILGridDataUnicharType) {
            value = [NSString stringWithFormat:@"%C", [self.grid uniCharAtRow:row column:columnIndex-1]];
        }
    }
    
    return value;
}

@end
#endif
