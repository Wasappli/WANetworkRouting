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

typedef NSMutableURLRequest* _Nonnull (^WARequestManagerAuthenticateRequest)(NSMutableURLRequest *_Nonnull request);
typedef void (^WARequestManagerSuccess)(WAObjectRequest *_Nonnull request, WAObjectResponse *_Nonnull response);
typedef void (^WARequestManagerFailure)(WAObjectRequest *_Nonnull request, WAObjectResponse *_Nullable response, _Nullable id <WANRErrorProtocol>error);
typedef void (^WARequestManagerProgress)(WAObjectRequest *_Nonnull request, NSProgress *_Nullable uploadProgress, NSProgress *_Nullable downloadProgress);

@protocol WARequestManagerProtocol <NSObject>

@property (nonatomic, strong) NSURL *_Nonnull baseURL;
@property (nonatomic, strong) Class _Nonnull errorClass;

/**
 *  Enqueue a provided request
 *
 *  @param objectRequest            the `WAObjectRequest` object to enqueue
 *  @param authenticateRequestBlock provide a block if needed to authenticate the `NSMutableURLRequest` created
 *  @param successBlock             a block called on success
 *  @param failureBlock             a block called on failure
 *  @param progressBlock            a block called for progress
 */
- (void)enqueueRequest:(WAObjectRequest *_Nonnull)objectRequest authenticateRequestBlock:(_Nullable WARequestManagerAuthenticateRequest)authenticateRequestBlock successBlock:(_Nullable WARequestManagerSuccess)successBlock failureBlock:(_Nullable WARequestManagerFailure)failureBlock progress:(_Nullable WARequestManagerProgress)progressBlock;

/**
 *  Returns reachability status
 *
 *  @return YES if reachable, NO otherwise
 */
- (BOOL)isReachable;

@end
