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
+ (instancetype)requestWithHTTPMethod:(WAObjectRequestMethod)method path:(NSString *)path parameters:(NSDictionary*)parameters optionalHeaders:(NSDictionary*)headers;

/**
 *  Set the completion block for the request
 *
 *  @param success block called on success
 *  @param failure block called on failure
 */
- (void)setCompletionBlocksWithSuccess:(WAObjectRequestSuccessCompletionBlock)success
                               failure:(WAObjectRequestFailureCompletionBlock)failure;

@property (nonatomic, assign, readonly ) WAObjectRequestMethod                 method;
@property (nonatomic, strong, readonly ) NSString                              *path;
@property (nonatomic, strong, readonly ) NSDictionary                          *parameters;
@property (nonatomic, strong, readonly ) NSDictionary                          *headers;
@property (nonatomic, copy, readonly   ) WAObjectRequestSuccessCompletionBlock successBlock;
@property (nonatomic, copy, readonly   ) WAObjectRequestFailureCompletionBlock failureBlock;
@property (nonatomic, strong, readwrite) id                                    targetObject;

@end
