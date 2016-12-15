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
    if ( self = [super init] )
    {
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
    if( row > gridRows || column > gridColumns)
    {
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

- (NSInteger) integerAtRow:(NSUInteger)row column:(NSUInteger)column
{
    if( gridValueSize != sizeof(NSInteger) )
        [[NSException exceptionWithName:NSRangeException reason:nil userInfo:nil] raise];
    void* valueAddress = [self addressOfRow:row column:column];
    NSInteger integerValue = 0;
    memcpy(&integerValue, valueAddress, gridValueSize);
    return integerValue;
}

- (CGFloat) floatAtRow:(NSUInteger)row column:(NSUInteger)column
{
    if( gridValueSize != sizeof(CGFloat) )
        [[NSException exceptionWithName:NSRangeException reason:nil userInfo:nil] raise];
    void* valueAddress = [self addressOfRow:row column:column];
    CGFloat floatValue = 0;
    memcpy(&floatValue, valueAddress, gridValueSize);
    return floatValue;
}

- (UniChar) uniCharAtRow:(NSUInteger)row column:(NSUInteger)column
{
    if( gridValueSize != sizeof(UniChar) )
        [[NSException exceptionWithName:NSRangeException reason:nil userInfo:nil] raise];
    void* valueAddress = [self addressOfRow:row column:column];
    UniChar unicharValue = 0;
    memcpy(&unicharValue, valueAddress, gridValueSize);
    return unicharValue;
}

- (CGFloat) percentAtRow:(NSUInteger) row column:(NSUInteger) col
{
    CGFloat percent = 0.0;
    
    if( gridType == ILGridDataIntegerType)
    {
        NSInteger thisValue = [self integerAtRow:row column:col];
        if( thisValue > 0)
            percent = fabs(thisValue / gridMaxValue);
        else
            percent = fabs(thisValue / gridMinValue);
    }
    else if( gridType == ILGridDataFloatType)
    {
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

- (void) setInteger:(NSInteger) integerValue atRow:(NSUInteger)row column:(NSUInteger)column
{
    if( integerValue > gridMaxValue)
        gridMaxValue = integerValue;

    if( integerValue < gridMinValue)
        gridMinValue = integerValue;
    
//    NSLog(@"setInteger: %li atRow: %lu column: %lu", integerValue, row, column);
    [self setValueAtRow:row column:column data:&integerValue length:gridValueSize];
}

- (void) setFloat:(CGFloat) floatValue atRow:(NSUInteger) row column:(NSUInteger)column
{
    if( floatValue > gridMaxValue)
        gridMaxValue = floatValue;
    
    if( floatValue < gridMinValue)
        gridMinValue = floatValue;

    [self setValueAtRow:row column:column data:&floatValue length:gridValueSize];
}

- (void) setUniChar:(UniChar) charValue atRow:(NSUInteger) row column:(NSUInteger)column
{
    [self setValueAtRow:row column:column data:&charValue length:gridValueSize];
}

#pragma mark -
#pragma mark fill routines

- (void) fillIntegerValue:(NSInteger) integerValue
{
    NSUInteger row = 0;
    NSUInteger col = 0;
    while ( row < gridRows)
    {
        while ( col < gridColumns)
        {
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
    while ( row < gridRows)
    {
        while ( col < gridColumns)
        {
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
    while ( row < gridRows)
    {
        while ( col < gridColumns)
        {
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
    while( rowIndex < gridRows )
    {
        NSUInteger columnIndex = 0; // reset to zero for each row
        while ( columnIndex < gridColumns )
        {
            NSInteger datum = [self integerAtRow:rowIndex column:columnIndex];
            [gridRep appendFormat:@"% 5li", datum];
//            [gridRep appendFormat:@"% 3li,% 3li", rowIndex, columnIndex];
            if ( columnIndex++ < (gridColumns-1) )
                [gridRep appendString:@" "];
        }
        if ( rowIndex++ < (gridRows-1) )
            [gridRep appendString:@",\n"];
        
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

#pragma mark - Slices

- (NSData*) dataAtRow:(NSUInteger)row
{
    return [NSData dataWithBytes:[self addressOfRow:row column:0] length:[self sizeOfRow]];
}

- (void) setData:(NSData*) slice atRow:(NSUInteger)row
{
    NSInteger index = (row * [self sizeOfRow]);
    if( index+[self sizeOfRow] <= data.length)
    {
        [data replaceBytesInRange:NSMakeRange(index, [self sizeOfRow])
                        withBytes:[slice bytes]];
    }
    else NSLog(@"setData:atRow: slice lands outside of data range: %@ row %lu", slice, row);
    
    // check the row and set the min/max values
    NSUInteger colIndex = 0;
    while( colIndex < gridColumns)
    {
        switch( gridType)
        {
            case ILGridDataIntegerType:
            {
                NSInteger integer = [self integerAtRow:row column:colIndex];
                if( integer > gridMaxValue)
                    gridMaxValue = integer;
                else if ( integer < gridMinValue)
                    gridMinValue = integer;
                break;
            }
                
            case ILGridDataFloatType:
            {
                CGFloat floatValue = [self floatAtRow:row column:colIndex];
                if( floatValue > gridMaxValue)
                    gridMaxValue = floatValue;
                else if ( floatValue < gridMinValue)
                    gridMinValue = floatValue;
                break;
            }
                
            case ILGridDataUnicharType:
            {
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
}

@end