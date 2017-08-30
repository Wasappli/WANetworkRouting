//
//  WAObjectRequest.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;
#import "WANetworkRoutingUtilities.h"

@interface WAObjectRequest : NSObject

/**
 *  Create an object request
 *
 *  @param method     the method (GET|POST|PUT|DELETE|HEAD|PATCH)
 *  @param path       the path relative to base URL. ex: @"shelves" for @"http://url.com/path/to/shelves"
 *  @param parameters the parameters to pass
 *  @param headers    optional headers to add to the request
 *
 *  @return A freshly created object requests
 */
+ (instancetype _Nonnull)requestWithHTTPMethod:(WAObjectRequestMethod)method path:(NSString *_Nonnull)path parameters:(NSDictionary *_Nullable)parameters optionalHeaders:(NSDictionary *_Nullable)headers;

/**
 *  Set the completion block for the request
 *
 *  @param success block called on success
 *  @param failure block called on failure
 */
- (void)setCompletionBlocksWithSuccess:(_Nullable WAObjectRequestSuccessCompletionBlock)success
                               failure:(_Nullable WAObjectRequestFailureCompletionBlock)failure;

@property (nonatomic, assign, readonly ) WAObjectRequestMethod                 method;
@property (nonatomic, strong, readonly ) NSString                              *_Nonnull path;
@property (nonatomic, strong, readonly ) NSDictionary                          *_Nullable parameters;
@property (nonatomic, strong, readonly ) NSDictionary                          *_Nullable headers;
@property (nonatomic, copy, readonly   ) WAObjectRequestSuccessCompletionBlock _Nullable successBlock;
@property (nonatomic, copy, readonly   ) WAObjectRequestFailureCompletionBlock _Nullable failureBlock;
@property (nonatomic, copy,readwrite   ) WAObjectRequestProgressBlock          _Nullable progressBlock;

@property (nonatomic, strong, readwrite) id                                    _Nullable targetObject;

@end
