//
//  W2STSDKDebug.h
//  W2STApp
//
//  Created by Giovanni Visentini on 21/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//
#ifndef W2STApp_W2STSDKDebug_h
#define W2STApp_W2STSDKDebug_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBPeripheral.h>
#import <CoreBluetooth/CBCharacteristic.h>

#import "W2STSDKNode.h"

@protocol W2STSDKDebugOutputDelegate;

/**
 *  Class that permit to read and write from the debug node console
 * @author STMicroelectronics - Central Labs.
 */
NS_CLASS_AVAILABLE(10_7, 5_0)
@interface W2STSDKDebug : NSObject

/**
 *  node that export this console
 */
@property (readonly,strong) W2STSDKNode* node;

/**
 *  delegate used for notify new message in the console, when you set a delegate
 * we will automatically enable the notification for the out/error message
 * for disable the notification set it to nil
 */
@property (nonatomic,weak,setter=setDelegate:,getter=getDelegate) id<W2STSDKDebugOutputDelegate> delegate;

/**
 *  create a debug console
 *
 *  @param node     node that export the debug console
 *  @param device   device associated to the node
 *  @param termChar characteristic where write and read the console message
 *  @param errChar  characteristic where receive the error messages
 *
 *  @return pointer to a W2STSDKDebug class
 */
-(instancetype) initWithNode:(W2STSDKNode *)node device:(CBPeripheral *)device
         termChart:(CBCharacteristic*)termChar
          errChart:(CBCharacteristic*)errChar;

/**
 *  send a message to the debug console
 *
 *  @param msg message to write in the node debug console
 */
-(void) writeMessage:(NSString*)msg;

@end

/** Protocol used for notify an console update */
@protocol W2STSDKDebugOutputDelegate
@required
/**
 *  called when we receive a message that the node write in the stdout stream
 *
 *  @param debug class that receive the message
 *  @param msg   message
 */
-(void) debug:(W2STSDKDebug*)debug didStdOutReceived:(NSString*) msg;

/**
 *  called when we receive a message that the node write in the stderr stream
 *
 *  @param debug class that receive the message
 *  @param msg   message
 */
-(void) debug:(W2STSDKDebug*)debug didStdErrReceived:(NSString*) msg;

/**
 *  called when we successfully send a message to the node stdin
 *
 *  @param debug class that send the message
 *  @param msg   message send
 *  @param error if present, it is the reason why message was not send */
-(void) debug:(W2STSDKDebug*)debug didStdInSend:(NSString*) msg error:(NSError*)error;
@end

#endif
