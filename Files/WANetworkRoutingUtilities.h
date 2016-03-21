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

FOUNDATION_EXPORT NSString *WAStringFromObjectRequestMethod(WAObjectRequestMethod method);

@class WAObjectRequest, WAObjectResponse;

typedef void (^WAObjectRequestSuccessCompletionBlock)(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects);
typedef void (^WAObjectRequestProgressBlock)(WAObjectRequest *objectRequest, NSProgress *uploadProgress, NSProgress *downloadProgress, NSProgress *mappingProgress);
typedef void (^WAObjectRequestFailureCompletionBlock)(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error);


#endif /* WANetworkRoutingUtilities_h */
