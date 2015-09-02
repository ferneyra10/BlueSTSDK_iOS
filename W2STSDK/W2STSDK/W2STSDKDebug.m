//
//  W2STSDKDebug.m
//  W2STApp
//
//  Created by Giovanni Visentini on 21/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKDebug_prv.h"

#import "Util/W2STSDKBleNodeDefines.h"

@implementation W2STSDKDebug{
    /**
     *  device that will send the information
     */
    CBPeripheral *mDevice;
    
    /**
     *  characteristic where we will read the stdout message
     */
    CBCharacteristic* mTermChar;
    
    /**
     *  characteristics where we will read the error message
     */
    CBCharacteristic* mErrChar;
    
    /**
     *  fifo structure that will contain the message that we will send until 
     *  we don't have a write ack
     */
    NSMutableArray *mWriteMessageQueue;
}

-(instancetype) initWithNode:(W2STSDKNode *)node device:(CBPeripheral *)device
         termChart:(CBCharacteristic*)termChar
          errChart:(CBCharacteristic*)errChar{
    _node=node;
    mTermChar=termChar;
    mErrChar=errChar;
    mDevice=device;
    mWriteMessageQueue = [NSMutableArray array];
    return self;
}

-(void) writeMessage:(NSString*)msg{
    [mWriteMessageQueue addObject:msg];
    NSData *tempData = [msg dataUsingEncoding:NSASCIIStringEncoding];
    [mDevice writeValue:tempData forCharacteristic:mTermChar type:CBCharacteristicWriteWithResponse];
}

@synthesize delegate = _delegate;

-(id<W2STSDKDebugOutputDelegate>) getDelegate{
    id<W2STSDKDebugOutputDelegate> ret=nil;
    //made the operation atomic
    @synchronized(self){
        ret = _delegate;
    }//synchronized
    return ret;
}//getDelegate

/**
 *  set the new delegate and enable/disable the notification
 */
-(void) setDelegate:(id<W2STSDKDebugOutputDelegate>)delegate{
    //made the operation atomic
    @synchronized(self){
        _delegate=delegate;
        BOOL enable = delegate!=nil; //enable if !=nil, disable if ==nil
        [mDevice setNotifyValue:enable forCharacteristic:mTermChar];
        [mDevice setNotifyValue:enable forCharacteristic:mErrChar];
    }//setDelegate
}

#pragma mark - W2STSDKDebug(Prv)

-(void)receiveCharacteristicsWriteUpdate:(CBCharacteristic*)termChar
                                   error:(NSError *)error{
    if(self.delegate == nil)
        return;
    //if the write comes from an our characteristics
    if([termChar.UUID isEqual:W2STSDKServiceDebug.termUuid]){
        //remove the message from the queue and sent the callback
        NSString *temp = mWriteMessageQueue.firstObject;
        [mWriteMessageQueue removeObjectAtIndex:0];
        [self.delegate debug:self didStdInSend: temp error:error];
    }
}

-(void)receiveCharacteristicsUpdate:(CBCharacteristic*)termChar{
    if(self.delegate == nil)
        return;
    NSString *temp = [[NSString alloc]initWithData:termChar.value encoding:NSUTF8StringEncoding];
    if([termChar.UUID isEqual:W2STSDKServiceDebug.termUuid]){
        [self.delegate debug:self didStdOutReceived: temp];
    }else if([termChar.UUID isEqual:W2STSDKServiceDebug.stdErrUuid]){
        [self.delegate debug:self didStdErrReceived: temp];
    }
}
@end
