//
//  WARoutingManagerRequestOnlyTests.m
//  WANetworkRouting
//
//  Created by Marian Paul on 16-02-23.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHPathHelpers.h>

#import "WANetworkRoutingManager.h"
#import "WAAFNetworkingRequestManager.h"
#import "WAObjectRequest.h"
#import "WAObjectResponse.h"
#import "WANRBasicError.h"
#import "WAURLResponse.h"

#import "Enterprise.h"

SPEC_BEGIN(RoutingManagerRequestOnlyTests)

static NSString *kBaseURL = @"http://www.someURL.com";

describe(@"RoutingManagerRequestOnlyTests", ^{

    __block WANetworkRoutingManager *routingManager = nil;
    
    beforeAll(^{
WAAFNetworkingRequestManager *requestManager = [WAAFNetworkingRequestManager new];
routingManager = [WANetworkRoutingManager managerWithBaseURL:[NSURL URLWithString:kBaseURL]
                                                                       requestManager:requestManager
                                                                       mappingManager:nil
                                                                authenticationManager:nil];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.path isEqualToString:@"/enterprises"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            NSString* fixture = OHPathForFile(@"EnterprisesList.json", self.class);
            return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                    statusCode:200
                                                       headers:@{@"Content-Type":@"application/json"}];
        }];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.path isEqualToString:@"/enterprises/1"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            NSString* fixture = OHPathForFile(@"Wasappli.json", self.class);
            return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                    statusCode:200
                                                       headers:@{@"Content-Type":@"application/json"}];
        }];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return ![request.URL.path isEqualToString:@"/enterprises/1"] && [request.URL.path hasPrefix:@"/enterprises/"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            NSString* fixture = OHPathForFile(@"Error.json", self.class);
            return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                    statusCode:404
                                                       headers:@{@"Content-Type":@"application/json"}];
        }];
    });
    
    it(@"Get enterprises ressources", ^{
        __block NSArray *_mappedObjects = nil;
        __block WAObjectResponse *_response = nil;
        __block id _error = nil;
        
        [routingManager getObjectsAtPath:@"enterprises"
                              parameters:nil
                                 success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                                     _response = response;
                                     _mappedObjects = mappedObjects;
                                 }
                                 failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                                     _error = error;
                                 }];
        
        [[expectFutureValue(_mappedObjects) shouldEventually] beNil];
        [[expectFutureValue(_response) shouldEventually] beNonNil];
        [[expectFutureValue(_response.responseObject[@"enterprises"]) shouldEventually] haveCountOf:3];
        [[expectFutureValue(_error) shouldEventually] beNil];
    });
    
    it(@"Get enterprise with ID of 1", ^{
        __block NSArray *_mappedObjects = nil;
        __block WAObjectResponse *_response = nil;
        __block id _error = nil;
        
        [routingManager getObject:nil
                             path:@"enterprises/1"
                       parameters:nil
                          success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                              _response = response;
                              _mappedObjects = mappedObjects;
                          }
                          failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                              _error = error;
                          }];
        
        [[expectFutureValue(_mappedObjects) shouldEventually] beNil];
        [[expectFutureValue(_response) shouldEventually] beNonNil];
        [[expectFutureValue(_response.responseObject[@"name"]) shouldEventually] equal:@"Wasappli"];
        [[expectFutureValue(_error) shouldEventually] beNil];
    });
    
    it(@"Get enterprise with unknown ID", ^{
        __block NSArray *_mappedObjects = nil;
        __block WAObjectResponse *_response = nil;
        __block WAObjectResponse *_errorResponse = nil;
        __block id<WANRErrorProtocol> _error = nil;
        
        [routingManager getObject:nil
                             path:@"enterprises/209"
                       parameters:nil
                          success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                              _response = response;
                              _mappedObjects = mappedObjects;
                          }
                          failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                              _errorResponse = response;
                              _error = error;
                          }];
        
        [[expectFutureValue(_mappedObjects) shouldEventually] beNil];
        [[expectFutureValue(_response) shouldEventually] beNil];
        [[expectFutureValue(_errorResponse) shouldEventually] beNonNil];
        [[expectFutureValue(_error) shouldEventually] beNonNil];
        [[expectFutureValue(_error) shouldEventually] beKindOfClass:[WANRBasicError class]];
        [[expectFutureValue(theValue(_error.response.urlResponse.statusCode)) shouldEventually] equal:@404];
    });
    
    afterAll(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SPEC_END
