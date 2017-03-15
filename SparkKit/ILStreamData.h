#import <Foundation/Foundation.h>

@protocol ILStreamDataDelegate;

/*! ILStreamData - streaming data interface for ILStreamView */
@interface ILStreamData : NSObject
@property(nonatomic, retain) NSMutableData* buffer;
@property(nonatomic, assign) NSUInteger width; // of the stream, in bytes
@property(nonatomic, assign) NSObject<ILStreamDataDelegate>* delegate;

/*! append data to the stream, which will notify the delegate when number of bytes in the buffer reaches stream.width */
-(void)appendData:(NSData*)data;
-(void)closeStream; // send streamDidClose to the delegate

@end

#pragma mark - ILStreamDataDelegate

/*! ILStreamDataDelegate - delegate for ILStreamData */
@protocol ILStreamDataDelegate <NSObject>

-(void)streamDidOpen:(ILStreamData*)stream; // first write
-(void)stream:(ILStreamData*)stream recievedData:(NSData*) data; // every stream.width
-(void)streamWillClose:(ILStreamData*)stream; // close

@end
