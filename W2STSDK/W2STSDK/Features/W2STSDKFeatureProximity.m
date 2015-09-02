//
//  W2STSDKFeatureProximity.m
//  W2STApp
//
//  Created by Giovanni Visentini on 28/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature_prv.h"
#import "W2STSDKFeatureProximity.h"

#import "W2STSDKFeatureField.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME @"Proximity"
#define FEATURE_UNIT @"mm"
#define FEATURE_MIN 0
#define FEATURE_MAX 255
#define FEATURE_TYPE W2STSDKFeatureFieldTypeUInt16
#define FEATURE_OUT_OF_RANGE_VALUE 510

/**
 * @memberof W2STSDKFeatureProximity
 *  array with the description of field exported by the feature
 */
static NSArray *sFieldDesc;

@implementation W2STSDKFeatureProximity

+(void)initialize{
    if(self == [W2STSDKFeatureProximity class]){
        sFieldDesc = [NSArray arrayWithObjects:
                      [W2STSDKFeatureField  createWithName:FEATURE_NAME
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      nil];
    }//if
    
}


+(uint16_t)getProximityDistance:(W2STSDKFeatureSample*)sample{
    if(sample.data.count==0)
        return NAN;
    return[[sample.data objectAtIndex:0] intValue];
}

+(uint16_t)outOfRangeValue{
    return FEATURE_OUT_OF_RANGE_VALUE;
}


-(instancetype) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}


/**
 *  read uint16 for build the distance value, create the new sample and
 * and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no 2 bytes available in the rawdata array
 *  @return number of read bytes
 */
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 2){
        @throw [NSException
                exceptionWithName:@"Invalid Proximity data"
                reason:@"The feature need almost 2 byte for extract the data"
                userInfo:nil];
    }//if
    
    uint16_t distance = [rawData extractLeUInt16FromOffset:offset];
    
    NSArray *data = [NSArray arrayWithObject:[NSNumber numberWithFloat:distance]];
    W2STSDKFeatureSample *sample = [W2STSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    self.lastSample = sample;
    
    [self notifyUpdateWithSample:sample];
    [self logFeatureUpdate:[rawData subdataWithRange:NSMakeRange(offset, 2)]
                    sample:sample];
    
    return 2;
}

@end


#import "../W2STSDKFeature+fake.h"

@implementation W2STSDKFeatureProximity (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:2];
    
    int16_t temp = FEATURE_MIN + rand()%((FEATURE_MAX-FEATURE_MIN));
    [data appendBytes:&temp length:2];
    
    return data;
}

@end