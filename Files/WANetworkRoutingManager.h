//
//  WANetworkRoutingManager.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

#import "WARequestManagerProtocol.h"
#import "WAMappingManagerProtocol.h"
#import "WARequestAuthenticationManagerProtocol.h"

#import "WANetworkRoutingUtilities.h"

@class WANetworkRouter;

@interface WANetworkRoutingManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 *  Initialize an network routing manager
 *
 *  @param baseURL               the base URL for all your requests
 *  @param requestManager        the request manager used to fetch data from server
 *  @param mappingManager        the mapping manager used to turn json to objects
 *  @param authenticationManager the authentication manager if your API needs an authentication
 *
 *  @return a fresh instance
 */
- (instancetype)initWithBaseURL:(NSURL *)baseURL requestManager:(id <WARequestManagerProtocol>)requestManager mappingManager:(id <WAMappingManagerProtocol>)mappingManager authenticationManager:(id <WARequestAuthenticationManagerProtocol>)authenticationManager NS_DESIGNATED_INITIALIZER;
// @see `initWithBaseURL: requestManager: mappingManager: authenticationManager:`
+ (instancetype)managerWithBaseURL:(NSURL *)baseURL requestManager:(id <WARequestManagerProtocol>)requestManager mappingManager:(id <WAMappingManagerProtocol>)mappingManager authenticationManager:(id <WARequestAuthenticationManagerProtocol>)authenticationManager;

/**
 *  Get all objects on a path
 *
 *  @param path       the path, relative to the base URL
 *  @param parameters the optional parameters
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 success:(WAObjectRequestSuccessCompletionBlock)success
                 failure:(WAObjectRequestFailureCompletionBlock)failure;


/**
 *  Get an object from a path
 *
 *  @param object     if used with the `WANetworkRouter`, pass the object and the router will find the path
 *  @param path       if you don't want to use an object, write the path to access the ressource
 *  @param parameters optional parameters
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)getObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          success:(WAObjectRequestSuccessCompletionBlock)success
          failure:(WAObjectRequestFailureCompletionBlock)failure;

// @see `getObject: path: parameters: success: failure:`
- (void)postObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(WAObjectRequestSuccessCompletionBlock)success
           failure:(WAObjectRequestFailureCompletionBlock)failure;

// @see `getObject: path: parameters: success: failure:`
- (void)putObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          success:(WAObjectRequestSuccessCompletionBlock)success
          failure:(WAObjectRequestFailureCompletionBlock)failure;

// @see `getObject: path: parameters: success: failure:`
- (void)deleteObject:(id)object
                path:(NSString *)path
          parameters:(NSDictionary *)parameters
             success:(WAObjectRequestSuccessCompletionBlock)success
             failure:(WAObjectRequestFailureCompletionBlock)failure;

// @see `getObject: path: parameters: success: failure:`
- (void)headObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(WAObjectRequestSuccessCompletionBlock)success
           failure:(WAObjectRequestFailureCompletionBlock)failure;

// @see `getObject: path: parameters: success: failure:`
- (void)patchObject:(id)object
               path:(NSString *)path
         parameters:(NSDictionary *)parameters
            success:(WAObjectRequestSuccessCompletionBlock)success
            failure:(WAObjectRequestFailureCompletionBlock)failure;

/**
 *  Enqueue a request. Useful for re enqueuing a request after renewing authentication
 *
 *  @param request the request to execute
 */
- (void)enqueueRequest:(WAObjectRequest *)request;

@property (nonatomic, strong, readonly ) NSURL                                       *baseURL;
@property (nonatomic, strong, readonly ) id <WARequestManagerProtocol>               requestManager;
@property (nonatomic, strong, readonly ) id <WARequestAuthenticationManagerProtocol> authenticationManager;
@property (nonatomic, strong, readonly ) id <WAMappingManagerProtocol>               mappingManager;
@property (nonatomic, strong, readonly ) WANetworkRouter                             *router;
@property (nonatomic, strong, readwrite) NSDictionary                                *optionalHeaders;

@end
