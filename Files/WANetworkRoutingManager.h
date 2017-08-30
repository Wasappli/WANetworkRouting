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
#import "WABatchManagerProtocol.h"

#import "WANetworkRoutingUtilities.h"

@class WANetworkRouter;

typedef NS_ENUM(NSUInteger, WANetworkRoutingManagerError) {
    WANetworkRoutingManagerErrorRequestBatched
};

@interface WANetworkRoutingManager : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

/**
 *  Initialize an network routing manager
 *
 *  @param baseURL               the base URL for all your requests
 *  @param requestManager        the request manager used to fetch data from server
 *  @param mappingManager        the mapping manager used to turn json to objects
 *  @param authenticationManager the authentication manager if your API needs an authentication
 *  @param batchManager          the batch manager if you have any batch behavior to handle
 *
 *  @return a fresh instance
 */
- (instancetype _Nonnull)initWithBaseURL:(NSURL *_Nonnull)baseURL requestManager:(_Nonnull id <WARequestManagerProtocol>)requestManager mappingManager:(_Nullable id <WAMappingManagerProtocol>)mappingManager authenticationManager:(_Nullable id <WARequestAuthenticationManagerProtocol>)authenticationManager batchManager:(_Nullable id <WABatchManagerProtocol>)batchManager NS_DESIGNATED_INITIALIZER;
// @see `initWithBaseURL: requestManager: mappingManager: authenticationManager: batchManager:`
+ (instancetype _Nonnull)managerWithBaseURL:(NSURL *_Nonnull)baseURL requestManager:(_Nonnull id <WARequestManagerProtocol>)requestManager mappingManager:(_Nullable id <WAMappingManagerProtocol>)mappingManager authenticationManager:(_Nullable id <WARequestAuthenticationManagerProtocol>)authenticationManager batchManager:(_Nullable id <WABatchManagerProtocol>)batchManager;

/**
 *  GET all objects on a path
 *
 *  @param path       the path, relative to the base URL
 *  @param parameters the optional parameters
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)getObjectsAtPath:(NSString *_Nonnull)path
              parameters:(NSDictionary *_Nullable)parameters
                 success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
                 failure:(WAObjectRequestFailureCompletionBlock _Nullable )failure;

/**
 *  Get all objects on a path
 *
 *  @param path       the path, relative to the base URL
 *  @param parameters the optional parameters
 *  @param progress   a progress block
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)getObjectsAtPath:(NSString *_Nonnull)path
              parameters:(NSDictionary *_Nullable)parameters
                progress:(WAObjectRequestProgressBlock _Nullable)progress
                 success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
                 failure:(WAObjectRequestFailureCompletionBlock _Nullable)failure;

/**
 *  GET an object
 *
 *  @param object     if used with the `WANetworkRouter`, pass the object and the router will find the path
 *  @param path       if you don't want to use an object, write the path to access the ressource
 *  @param parameters optional parameters
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)getObject:(id _Nullable)object
             path:(NSString *_Nullable)path
       parameters:(NSDictionary *_Nullable)parameters
          success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
          failure:(WAObjectRequestFailureCompletionBlock _Nullable)failure;

/**
 *  GET an object
 *
 *  @param object     if used with the `WANetworkRouter`, pass the object and the router will find the path
 *  @param path       if you don't want to use an object, write the path to access the ressource
 *  @param parameters optional parameters
 *  @param progress   a progress block
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)getObject:(id _Nullable)object
             path:(NSString *_Nullable)path
       parameters:(NSDictionary *_Nullable)parameters
         progress:(WAObjectRequestProgressBlock _Nullable)progress
          success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
          failure:(WAObjectRequestFailureCompletionBlock _Nullable)failure;


/**
 *  POST an object
 *
 *  @param object     if used with the `WANetworkRouter`, pass the object and the router will find the path
 *  @param path       if you don't want to use an object, write the path to access the ressource
 *  @param parameters optional parameters
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)postObject:(id _Nullable)object
              path:(NSString *_Nullable)path
        parameters:(NSDictionary *_Nullable)parameters
           success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
           failure:(WAObjectRequestFailureCompletionBlock _Nullable)failure;

/**
 *  POST an object
 *
 *  @param object     if used with the `WANetworkRouter`, pass the object and the router will find the path
 *  @param path       if you don't want to use an object, write the path to access the ressource
 *  @param parameters optional parameters
 *  @param progress   a progress block
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)postObject:(id _Nullable)object
              path:(NSString *_Nullable)path
        parameters:(NSDictionary *_Nullable)parameters
          progress:(WAObjectRequestProgressBlock _Nullable)progress
           success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
           failure:(WAObjectRequestFailureCompletionBlock _Nullable)failure;

/**
 *  PUT an object
 *
 *  @param object     if used with the `WANetworkRouter`, pass the object and the router will find the path
 *  @param path       if you don't want to use an object, write the path to access the ressource
 *  @param parameters optional parameters
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)putObject:(id _Nullable)object
             path:(NSString *_Nullable)path
       parameters:(NSDictionary *_Nullable)parameters
          success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
          failure:(WAObjectRequestFailureCompletionBlock _Nullable)failure;

/**
 *  PUT an object
 *
 *  @param object     if used with the `WANetworkRouter`, pass the object and the router will find the path
 *  @param path       if you don't want to use an object, write the path to access the ressource
 *  @param parameters optional parameters
 *  @param progress   a progress block
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)putObject:(id _Nullable)object
             path:(NSString *_Nullable)path
       parameters:(NSDictionary *_Nullable)parameters
         progress:(WAObjectRequestProgressBlock _Nullable)progress
          success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
          failure:(WAObjectRequestFailureCompletionBlock _Nullable)failure;

/**
 *  DELETE an object
 *
 *  @param object     if used with the `WANetworkRouter`, pass the object and the router will find the path
 *  @param path       if you don't want to use an object, write the path to access the ressource
 *  @param parameters optional parameters
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)deleteObject:(id _Nullable)object
                path:(NSString *_Nullable)path
          parameters:(NSDictionary *_Nullable)parameters
             success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
             failure:(WAObjectRequestFailureCompletionBlock _Nullable)failure;

/**
 *  DELETE an object
 *
 *  @param object     if used with the `WANetworkRouter`, pass the object and the router will find the path
 *  @param path       if you don't want to use an object, write the path to access the ressource
 *  @param parameters optional parameters
 *  @param progress   a progress block
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)deleteObject:(id _Nullable)object
                path:(NSString *_Nullable)path
          parameters:(NSDictionary *_Nullable)parameters
            progress:(WAObjectRequestProgressBlock _Nullable)progress
             success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
             failure:(WAObjectRequestFailureCompletionBlock _Nullable)failure;

/**
 *  HEAD an object
 *
 *  @param object     if used with the `WANetworkRouter`, pass the object and the router will find the path
 *  @param path       if you don't want to use an object, write the path to access the ressource
 *  @param parameters optional parameters
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)headObject:(id _Nullable)object
              path:(NSString *_Nullable)path
        parameters:(NSDictionary *_Nullable)parameters
           success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
           failure:(WAObjectRequestFailureCompletionBlock _Nullable)failure;

/**
 *  HEAD an object
 *
 *  @param object     if used with the `WANetworkRouter`, pass the object and the router will find the path
 *  @param path       if you don't want to use an object, write the path to access the ressource
 *  @param parameters optional parameters
 *  @param progress   a progress block
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)headObject:(id _Nullable)object
              path:(NSString *_Nullable)path
        parameters:(NSDictionary *_Nullable)parameters
          progress:(WAObjectRequestProgressBlock _Nullable)progress
           success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
           failure:(WAObjectRequestFailureCompletionBlock _Nullable)failure;

/**
 *  PATCH an object
 *
 *  @param object     if used with the `WANetworkRouter`, pass the object and the router will find the path
 *  @param path       if you don't want to use an object, write the path to access the ressource
 *  @param parameters optional parameters
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)patchObject:(id _Nullable)object
               path:(NSString *_Nullable)path
         parameters:(NSDictionary *_Nullable)parameters
            success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
            failure:(WAObjectRequestFailureCompletionBlock _Nullable)failure;

/**
 *  PATCH an object
 *
 *  @param object     if used with the `WANetworkRouter`, pass the object and the router will find the path
 *  @param path       if you don't want to use an object, write the path to access the ressource
 *  @param parameters optional parameters
 *  @param progress   a progress block
 *  @param success    a success block
 *  @param failure    a failure block
 */
- (void)patchObject:(id _Nullable)object
               path:(NSString *_Nullable)path
         parameters:(NSDictionary *_Nullable)parameters
           progress:(WAObjectRequestProgressBlock _Nullable)progress
            success:(WAObjectRequestSuccessCompletionBlock _Nullable)success
            failure:(WAObjectRequestFailureCompletionBlock _Nullable)failure;

/**
 *  Enqueue a request. Useful for re enqueuing a request after renewing authentication
 *
 *  @param request the request to execute
 */
- (void)enqueueRequest:(WAObjectRequest *_Nonnull)request;

@property (nonatomic, strong, readonly ) NSURL * _Nonnull baseURL;
@property (nonatomic, strong, readonly ) _Nonnull id<WARequestManagerProtocol> requestManager;
@property (nonatomic, strong, readonly ) _Nullable id<WARequestAuthenticationManagerProtocol> authenticationManager;
@property (nonatomic, strong, readonly ) _Nullable id<WAMappingManagerProtocol> mappingManager;
@property (nonatomic, strong, readonly ) _Nullable id<WABatchManagerProtocol> batchManager;
@property (nonatomic, strong, readonly ) WANetworkRouter * _Nonnull router;
@property (nonatomic, strong, readwrite) NSDictionary * _Nullable optionalHeaders;

@end

FOUNDATION_EXTERN NSString * _Nonnull const WANetworkRoutingManagerErrorDomain;
