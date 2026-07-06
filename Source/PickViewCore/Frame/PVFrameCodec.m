//
//  PVFrameCodec.m
//  PickView
//
//  Created by kris cheng on 2026/7/6.
//

#import "PVFrameCodec.h"
#import "PVFrame.h"
#import <arpa/inet.h>

static NSString * const PVFrameCodecErrorDomain = @"PVFrameCodecErrorDomain";

typedef struct {
    uint32_t version;
    uint32_t type;
    uint32_t tag;
    uint32_t payloadSize;
} PVFrameHeader;

@implementation PVFrameCodec

+ (NSUInteger)headerLength {
    return sizeof(PVFrameHeader);
}

+ (NSData *)dataWithFrame:(PVFrame *)frame {
    PVFrameHeader header;
    header.version = htonl(frame.version);
    header.type = htonl(frame.type);
    header.tag = htonl(frame.tag);
    header.payloadSize = htonl((uint32_t)frame.payload.length);

    NSMutableData *data = [NSMutableData dataWithBytes:&header length:sizeof(header)];
    if (frame.payload.length) {
        [data appendData:frame.payload];
    }
    return data;
}

+ (NSUInteger)payloadLengthFromHeaderData:(NSData *)headerData error:(NSError **)error {
    if (headerData.length != sizeof(PVFrameHeader)) {
        if (error) {
            *error = [NSError errorWithDomain:PVFrameCodecErrorDomain code:3 userInfo:@{NSLocalizedDescriptionKey: @"Frame header data has invalid length."}];
        }
        return 0;
    }

    PVFrameHeader header;
    [headerData getBytes:&header length:sizeof(header)];
    return ntohl(header.payloadSize);
}

+ (PVFrame *)frameWithData:(NSData *)data error:(NSError **)error {
    if (data.length < sizeof(PVFrameHeader)) {
        if (error) {
            *error = [NSError errorWithDomain:PVFrameCodecErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey: @"Frame data is shorter than header."}];
        }
        return nil;
    }

    PVFrameHeader header;
    [data getBytes:&header length:sizeof(header)];

    uint32_t payloadSize = ntohl(header.payloadSize);
    NSUInteger expectedLength = sizeof(PVFrameHeader) + payloadSize;
    if (data.length != expectedLength) {
        if (error) {
            *error = [NSError errorWithDomain:PVFrameCodecErrorDomain code:2 userInfo:@{NSLocalizedDescriptionKey: @"Frame payload size does not match data length."}];
        }
        return nil;
    }

    NSData *payload = nil;
    if (payloadSize > 0) {
        payload = [data subdataWithRange:NSMakeRange(sizeof(PVFrameHeader), payloadSize)];
    }

    return [[PVFrame alloc] initWithVersion:ntohl(header.version)
                                       type:ntohl(header.type)
                                        tag:ntohl(header.tag)
                                    payload:payload];
}

@end

