#import "ILStreamData.h"

@implementation ILStreamData

-(instancetype)init
{
    if (self = [super init]) {
        self.width = 1; // single byte stream width
    }
    
    return self;
}

-(void)appendData:(NSData*)data
{
    if (!self.buffer) {
        self.buffer = [NSMutableData dataWithLength:data.length];

        if (self.delegate && [self.delegate respondsToSelector:@selector(streamDidOpen:)]) {
            [self.delegate streamDidOpen:self];
        }
    }
    
    [self.buffer appendData:data];
    
    if (self.delegate && ((self.buffer.length % self.width) == 0)
    && [self.delegate respondsToSelector:@selector(stream:recievedData:)]) {
        [self.delegate stream:self recievedData:self.buffer];
    }
}

-(void)closeStream
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(streamWillClose:)]) {
        [self.delegate streamWillClose:self];
    }
    
    self.buffer = nil; // release the buffer
}

@end
