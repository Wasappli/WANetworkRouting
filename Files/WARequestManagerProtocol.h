//
//  WARequestManagerProtocol.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@class WAObjectRequest, WAObjectResponse;
@protocol WANRErrorProtocol;

typedef NSMutableURLRequest* (^WARequestManagerAuthenticateRequest)(NSMutableURLRequest *request);
typedef void (^WARequestManagerSuccess)(WAObjectRequest *request, WAObjectResponse *response);
typedef void (^WARequestManagerFailure)(WAObjectRequest *request, WAObjectResponse *response, id <WANRErrorProtocol>error);
typedef void (^WARequestManagerProgress)(WAObjectRequest *request, NSProgress *uploadProgress, NSProgress *downloadProgress);

@protocol WARequestManagerProtocol <NSObject>

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) Class errorClass;

/**
 *  Enqueue a provided request
 *
 *  @param objectRequest            the `WAObjectRequest` object to enqueue
 *  @param authenticateRequestBlock provide a block if needed to authenticate the `NSMutableURLRequest` created
 *  @param successBlock             a block called on success
 *  @param failureBlock             a block called on failure
 *  @param progressBlock            a block called for progress
 */
- (void)enqueueRequest:(WAObjectRequest *)objectRequest authenticateRequestBlock:(WARequestManagerAuthenticateRequest)authenticateRequestBlock successBlock:(WARequestManagerSuccess)successBlock failureBlock:(WARequestManagerFailure)failureBlock progress:(WARequestManagerProgress)progressBlock;

@end
