//
//  WARoutingManagerRequestMappingRouterTests.m
//  WANetworkRouting
//
//  Created by Marian Paul on 16-02-23.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHPathHelpers.h>

#import <WAMapping/WAMapping.h>

#import "WANetworkRoutingManager.h"
#import "WAAFNetworkingRequestManager.h"
#import "WAMappingManager.h"

#import "WAObjectRequest.h"
#import "WAObjectResponse.h"
#import "WANRBasicError.h"
#import "WAURLResponse.h"
#import "WAResponseDescriptor.h"
#import "WARequestDescriptor.h"
#import "WANetworkRoute.h"
#import "WANetworkRouter.h"

#import "Enterprise.h"

SPEC_BEGIN(RoutingManagerRequestMappingRouterTests)

static NSString *kBaseURL = @"http://www.someURL.com";

describe(@"RoutingManagerRequestMappingRouterTests", ^{
    
    __block WANetworkRoutingManager *routingManager = nil;
    __block WAMemoryStore *memoryStore              = nil;
    __block WAEntityMapping *enterpriseMapping      = nil;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    beforeAll(^{
        // ———————————————————————————————————————————
        // Create the mapping
        // ———————————————————————————————————————————
        memoryStore = [[WAMemoryStore alloc] init];
        
        enterpriseMapping = [WAEntityMapping mappingForEntityName:@"Enterprise"];
        enterpriseMapping.identificationAttribute = @"itemID";
        [enterpriseMapping addAttributeMappingsFromDictionary:@{
                                                                @"id": @"itemID",
                                                                @"name": @"name",
                                                                @"address.street_number": @"streetNumber"}];
        
        [enterpriseMapping addMappingFromSourceProperty:@"creation_date"
                                  toDestinationProperty:@"creationDate"
                                              withBlock:^id(id value) {
                                                  return [dateFormatter dateFromString:value];
                                              }
                                           reverseBlock:^id(id value) {
                                               return [dateFormatter stringFromDate:value];
                                           }];
        
        // ———————————————————————————————————————————
        // Create the mapping manager
        // ———————————————————————————————————————————
        WAMappingManager *mappingManager = [WAMappingManager mappingManagerWithStore:memoryStore];
        
        // ———————————————————————————————————————————
        // Create the response descriptors
        // ———————————————————————————————————————————
        WAResponseDescriptor *enterprisesResponseDescriptor = [WAResponseDescriptor responseDescriptorWithMapping:enterpriseMapping
                                                                                                           method:WAObjectRequestMethodGET
                                                                                                      pathPattern:@"enterprises"
                                                                                                          keyPath:@"enterprises"];
        
        WAResponseDescriptor *singleEnterpriseResponseDescriptor = [WAResponseDescriptor responseDescriptorWithMapping:enterpriseMapping
                                                                                                                method:WAObjectRequestMethodGET | WAObjectRequestMethodPUT
                                                                                                           pathPattern:@"enterprises/:itemID"
                                                                                                               keyPath:nil];
        
        WAResponseDescriptor *createEnterpriseResponseDescriptor = [WAResponseDescriptor responseDescriptorWithMapping:enterpriseMapping
                                                                                                                method:WAObjectRequestMethodPOST
                                                                                                           pathPattern:@"enterprises"
                                                                                                               keyPath:nil];
        [mappingManager addResponseDescriptor:enterprisesResponseDescriptor];
        [mappingManager addResponseDescriptor:singleEnterpriseResponseDescriptor];
        [mappingManager addResponseDescriptor:createEnterpriseResponseDescriptor];
        
        // ———————————————————————————————————————————
        // Create the request descriptors
        // ———————————————————————————————————————————
        WARequestDescriptor *enterpriseRequestDescriptor = [WARequestDescriptor requestDescriptorWithMethod:WAObjectRequestMethodPOST
                                                                                                pathPattern:@"enterprises"
                                                                                                    mapping:enterpriseMapping
                                                                                             shouldMapBlock:nil
                                                                                             requestKeyPath:nil];
        
        WARequestDescriptor *enterpriseUpdateRequestDescriptor = [WARequestDescriptor requestDescriptorWithMethod:WAObjectRequestMethodPUT
                                                                                                      pathPattern:@"enterprises/:itemID"
                                                                                                          mapping:enterpriseMapping
                                                                                                   shouldMapBlock:nil
                                                                                                   requestKeyPath:nil];
        [mappingManager addRequestDescriptor:enterpriseRequestDescriptor];
        [mappingManager addRequestDescriptor:enterpriseUpdateRequestDescriptor];
        
        // ———————————————————————————————————————————
        // Create the routing manager
        // ———————————————————————————————————————————
        WAAFNetworkingRequestManager *requestManager = [WAAFNetworkingRequestManager new];
        
        routingManager = [WANetworkRoutingManager managerWithBaseURL:[NSURL URLWithString:kBaseURL]
                                                      requestManager:requestManager
                                                      mappingManager:mappingManager
                                               authenticationManager:nil
                          batchManager:nil];
        
        // ———————————————————————————————————————————
        // Configure the router
        // ———————————————————————————————————————————
        WANetworkRoute *enterpriseRoute = [WANetworkRoute routeWithObjectClass:[Enterprise class]
                                                                   pathPattern:@"enterprises/:itemID"
                                                                        method:WAObjectRequestMethodGET | WAObjectRequestMethodPUT];
        
        [routingManager.router addRoute:enterpriseRoute];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.path isEqualToString:@"/enterprises/1"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"Wasappli.json", self.class)
                                                    statusCode:200
                                                       headers:@{@"Content-Type":@"application/json"}];
        }];
    });
    
    it(@"Find the path from GET", ^{
        __block NSArray *_mappedObjects = nil;
        __block WAObjectResponse *_response = nil;
        __block WAObjectRequest *_request = nil;
        __block id _error = nil;
        
        Enterprise *enterprise = [memoryStore newObjectForMapping:enterpriseMapping];
        enterprise.itemID = @1;
        
        [routingManager getObject:enterprise
                             path:nil
                       parameters:nil
                          success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                              _response = response;
                              _mappedObjects = mappedObjects;
                              _request = objectRequest;
                          }
                          failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                              _error = error;
                          }];
        
        [[expectFutureValue(_request.targetObject) shouldEventually] beNonNil];
        [[expectFutureValue(_request.targetObject) shouldEventually] equal:enterprise];
        [[expectFutureValue(_mappedObjects) shouldEventually] haveCountOf:1];
        [[expectFutureValue([_mappedObjects firstObject]) shouldEventually] beKindOfClass:[Enterprise class]];
        [[expectFutureValue([[_mappedObjects firstObject] name]) shouldEventually] equal:@"Wasappli"];
        [[expectFutureValue([_mappedObjects firstObject]) shouldEventually] equal:enterprise];
    });
    
    afterAll(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SPEC_END
