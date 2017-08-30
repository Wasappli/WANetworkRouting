//
//  WANetworkRoutingUtilities.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#ifndef WANetworkRoutingUtilities_h
#define WANetworkRoutingUtilities_h

@import Foundation;

@protocol WANRErrorProtocol;

typedef NS_OPTIONS(NSInteger, WAObjectRequestMethod) {
    WAObjectRequestMethodGET    = 1 << 0,
    WAObjectRequestMethodPUT    = 1 << 1,
    WAObjectRequestMethodPOST   = 1 << 2,
    WAObjectRequestMethodDELETE = 1 << 3,
    WAObjectRequestMethodHEAD   = 1 << 4,
    WAObjectRequestMethodPATCH  = 1 << 5,
};

FOUNDATION_EXPORT NSString * _Nonnull WAStringFromObjectRequestMethod(WAObjectRequestMethod method);
FOUNDATION_EXPORT WAObjectRequestMethod WAObjectRequestMethodFromString(NSString *_Nonnull method);

@class WAObjectRequest, WAObjectResponse;

typedef void (^WAObjectRequestSuccessCompletionBlock)(WAObjectRequest *_Nonnull objectRequest, WAObjectResponse *_Nonnull response, NSArray *_Nullable _mappedObjects);
typedef void (^WAObjectRequestProgressBlock)(WAObjectRequest *_Nonnull objectRequest, NSProgress *_Nullable uploadProgress, NSProgress *_Nullable downloadProgress, NSProgress *_Nullable mappingProgress);
typedef void (^WAObjectRequestFailureCompletionBlock)(WAObjectRequest *_Nonnull objectRequest, WAObjectResponse *_Nullable response, _Nullable id<WANRErrorProtocol> error);


#endif /* WANetworkRoutingUtilities_h */
