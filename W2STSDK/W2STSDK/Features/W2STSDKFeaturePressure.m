//
//  W2STFeaturePressure.m
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature_prv.h"
#import "W2STSDKFeaturePressure.h"

#import "W2STSDKFeatureField.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME @"Pressure"
#define FEATURE_UNIT @"mBar"
#define FEATURE_MIN 0
#define FEATURE_MAX 100
#define FEATURE_TYPE W2STSDKFeatureFieldTypeFloat

/**
 * @memberof W2STSDKFeaturePressure
 *  array with the description of field exported by the feature
 */
static NSArray *sFieldDesc;

@implementation W2STSDKFeaturePressure

+(void)initialize{
    if(self == [W2STSDKFeaturePressure class]){
        sFieldDesc = [[NSArray alloc] initWithObjects:
                      [W2STSDKFeatureField  createWithName: FEATURE_NAME
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      nil];
    }//if
}//initialize


+(float)getPressure:(W2STSDKFeatureSample *)sample{
    if(sample.data.count==0)
        return NAN;
    return[[sample.data objectAtIndex:0] floatValue];
}


-(instancetype) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}


/**
 *  read int32 for build the pressure value, create the new sample and
 * and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no 4 bytes available in the rawdata array
 *  @return number of read bytes
 */
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 4){
        @throw [NSException
                exceptionWithName:@"Invalid Pressure data"
                reason:@"The feature need almost 4 byte for extract the data"
                userInfo:nil];
    }//if
    
    int32_t press= [rawData extractLeInt32FromOffset:offset];
    
    NSArray *data = [NSArray arrayWithObject:[NSNumber numberWithFloat:press/100.0f]];
    W2STSDKFeatureSample *sample = [W2STSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    self.lastSample = sample;
    
    [self notifyUpdateWithSample:sample];
    [self logFeatureUpdate:[rawData subdataWithRange:NSMakeRange(offset, 4)]
                    sample:sample];
    
    return 4;
}

@end

#import "../W2STSDKFeature+fake.h"

@implementation W2STSDKFeaturePressure (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:4];
    
    int32_t temp = FEATURE_MIN*100 + rand()%((FEATURE_MAX-FEATURE_MIN)*100);
    [data appendBytes:&temp length:4];
    
    return data;
}

@end
