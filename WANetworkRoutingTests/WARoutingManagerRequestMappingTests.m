//
//  WARoutingManagerRequestMappingTests.m
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

#import "Enterprise.h"

SPEC_BEGIN(RoutingManagerRequestMappingTests)

static NSString *kBaseURL = @"http://www.someURL.com";

describe(@"RoutingManagerRequestMappingTests", ^{
    
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
                                               authenticationManager:nil];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.path isEqualToString:@"/enterprises"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            if ([request.HTTPMethod isEqualToString:@"POST"]) {
                return [OHHTTPStubsResponse responseWithData:[@"{\"name\": \"Test\"}" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{@"Content-Type":@"application/json"}];
            } else {
                return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"EnterprisesList.json", self.class)
                                                        statusCode:200
                                                           headers:@{@"Content-Type":@"application/json"}];
            }
        }];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.path isEqualToString:@"/enterprises/1"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            if ([request.HTTPMethod isEqualToString:@"PUT"]) {
                return [OHHTTPStubsResponse responseWithData:[@"{\"id\": 1, \"name\": \"Test\"}" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{@"Content-Type":@"application/json"}];
            } else {
                return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"Wasappli.json", self.class)
                                                        statusCode:200
                                                           headers:@{@"Content-Type":@"application/json"}];
            }
        }];
    });
    
    it(@"Map enterprises", ^{
        __block NSArray *_mappedObjects = nil;
        __block WAObjectResponse *_response = nil;
        __block id _error = nil;
    
[routingManager getObjectsAtPath:@"enterprises"
                      parameters:nil
                        progress:^(WAObjectRequest *objectRequest, NSProgress *uploadProgress, NSProgress *downloadProgress, NSProgress *mappingProgress) {
                            
                        }
                         success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                             _response = response;
                             _mappedObjects = mappedObjects;
                         }
                         failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                             _error = error;
                         }];
        
        [[expectFutureValue(_mappedObjects) shouldEventually] haveCountOf:3];
        [[expectFutureValue([_mappedObjects firstObject]) shouldEventually] beKindOfClass:[Enterprise class]];
        [[expectFutureValue([[_mappedObjects firstObject] name]) shouldEventually] equal:@"Wasappli"];
        [[expectFutureValue(_error) shouldEventually] beNil];
    });
    
    it(@"Map an enterprise from GET", ^{
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
        
        [[expectFutureValue(_mappedObjects) shouldEventually] beNonNil];
        [[expectFutureValue(_mappedObjects) shouldEventually] haveCountOf:1];
        [[expectFutureValue([_mappedObjects firstObject]) shouldEventually] beKindOfClass:[Enterprise class]];
        [[expectFutureValue([[_mappedObjects firstObject] name]) shouldEventually] equal:@"Wasappli"];
        [[expectFutureValue(_error) shouldEventually] beNil];
    });
    
    it(@"POST an enterprise", ^{
        __block NSArray *_mappedObjects = nil;
        __block WAObjectResponse *_response = nil;
        __block WAObjectRequest *_request = nil;
        __block id<WANRErrorProtocol> _error = nil;
        
        Enterprise *enterprise = [Enterprise new];
        enterprise.name = @"Test";
        
        [routingManager postObject:enterprise
                              path:@"enterprises"
                        parameters:nil
                           success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                               _response = response;
                               _mappedObjects = mappedObjects;
                               _request = objectRequest;
                           }
                           failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                               _error = error;
                           }];
        
        [[expectFutureValue(_request.targetObject) shouldEventually] beNil]; // Deleted from store
        [[expectFutureValue(_request.parameters[@"name"]) shouldEventually] equal:@"Test"]; // Mapped from object
        [[expectFutureValue(_mappedObjects) shouldEventually] haveCountOf:1];
        [[expectFutureValue([_mappedObjects firstObject]) shouldEventually] beKindOfClass:[Enterprise class]];
        [[expectFutureValue([[_mappedObjects firstObject] name]) shouldEventually] equal:@"Test"];
    });
    
    it(@"PUT an enterprise", ^{
        __block NSArray *_mappedObjects = nil;
        __block WAObjectResponse *_response = nil;
        __block WAObjectRequest *_request = nil;
        __block id<WANRErrorProtocol> _error = nil;
        
        Enterprise *enterprise = [[memoryStore objectsWithAttributes:@[@1] forMapping:enterpriseMapping] firstObject];
        [[enterprise shouldNot] beNil];
        enterprise.itemID = @1;
        enterprise.name = @"Test";
        
        [routingManager putObject:enterprise
                             path:@"enterprises/1"
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
        [[expectFutureValue(_request.parameters[@"name"]) shouldEventually] equal:@"Test"];
        [[expectFutureValue(_mappedObjects) shouldEventually] haveCountOf:1];
        [[expectFutureValue([_mappedObjects firstObject]) shouldEventually] beKindOfClass:[Enterprise class]];
        [[expectFutureValue([[_mappedObjects firstObject] name]) shouldEventually] equal:@"Test"];
        [[expectFutureValue([_mappedObjects firstObject]) shouldEventually] equal:enterprise];
    });
    
    afterAll(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SPEC_END

