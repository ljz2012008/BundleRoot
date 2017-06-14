#import "XADRARParser.h"
#import "XADRARVirtualMachine.h"

@interface XADRAR30Filter:NSObject
{
	XADRARProgramInvocation *invocation;
	off_t blockstartpos;
	int blocklength;

	uint32_t filteredblockaddress,filteredblocklength;
}

+(XADRAR30Filter *)filterForProgramInvocation:(XADRARProgramInvocation *)program
startPosition:(off_t)startpos length:(int)length;

-(id)initWithProgramInvocation:(XADRARProgramInvocation *)program
startPosition:(off_t)startpos length:(int)length;
-(void)dealloc;

-(off_t)startPosition;
-(int)length;

-(uint32_t)filteredBlockAddress;
-(uint32_t)filteredBlockLength;

-(void)executeOnVirtualMachine:(XADRARVirtualMachine *)vm atPosition:(off_t)pos;

@end

@interface XADRAR30DeltaFilter:XADRAR30Filter {}
-(void)executeOnVirtualMachine:(XADRARVirtualMachine *)vm atPosition:(off_t)pos;
@end

@interface XADRAR30AudioFilter:XADRAR30Filter {}
-(void)executeOnVirtualMachine:(XADRARVirtualMachine *)vm atPosition:(off_t)pos;
@end

@interface XADRAR30E8Filter:XADRAR30Filter {}
-(void)executeOnVirtualMachine:(XADRARVirtualMachine *)vm atPosition:(off_t)pos;
@end

@interface XADRAR30E8E9Filter:XADRAR30Filter {}
-(void)executeOnVirtualMachine:(XADRARVirtualMachine *)vm atPosition:(off_t)pos;
@end




@interface XADRAR50Filter:NSObject
{
	off_t start;
	uint32_t length;
}

-(id)initWithStart:(off_t)start length:(uint32_t)length;

-(off_t)start;
-(uint32_t)length;

-(void)runOnData:(NSMutableData *)data fileOffset:(off_t)pos;

@end

@interface XADRAR50DeltaFilter:XADRAR50Filter
{
	int numchannels;
}

-(id)initWithStart:(off_t)start length:(uint32_t)length numberOfChannels:(int)numchannels;

-(void)runOnData:(NSMutableData *)data fileOffset:(off_t)pos;

@end

@interface XADRAR50E8E9Filter:XADRAR50Filter
{
	BOOL handlee9;
}

-(id)initWithStart:(off_t)start length:(uint32_t)length handleE9:(BOOL)handlee9;

-(void)runOnData:(NSMutableData *)data fileOffset:(off_t)pos;

@end

@interface XADRAR50ARMFilter:XADRAR50Filter {}

-(void)runOnData:(NSMutableData *)data fileOffset:(off_t)pos;

@end

