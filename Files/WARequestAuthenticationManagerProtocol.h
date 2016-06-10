//
//  WARequestAuthenticationManagerProtocol.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@class WAObjectRequest, WAObjectResponse, WANetworkRoutingManager;
@protocol WANRErrorProtocol;

@protocol WARequestAuthenticationManagerProtocol <NSObject>

/**
 *  Authenticate an URL request. This is usually done by adding a token to the authentication header
 *
 *  @param urlRequest the request to authenticate
 *  @param request the original request
 */
- (void)authenticateURLRequest:(NSMutableURLRequest *)urlRequest request:(WAObjectRequest *)request;

/**
 *  A method which asks if a request, based on the response, should be replayed after renewing authentication. This is usually on 401 + some error codes from server
 *
 *  @param request  the request which might be replayed
 *  @param response the response we had on executing first the request
 *  @param error    the error along the request execution
 *
 *  @return YES if you need to ask the server to renew the token
 */
- (BOOL)shouldReplayRequest:(WAObjectRequest *)request response:(WAObjectResponse *)response error:(id <WANRErrorProtocol>)error;

/**
 *  This method is called when the first request execution returned an authentication error asking to renew it.
 *  Basic idea is to refresh your authentication with the server, save the new token and then ask the object manager to replay the request
 *
 *  @param request               the request you will have to enqueue then
 *  @param networkRoutingManager the network routing manager which deals with requests
 */
- (void)authenticateAndReplayRequest:(WAObjectRequest *)request fromNetworkRoutingManager:(WANetworkRoutingManager *)networkRoutingManager;

@end
