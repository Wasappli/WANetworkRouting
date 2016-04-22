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
#import "WABatchManager.h"

#import "WAObjectRequest.h"
#import "WAObjectResponse.h"
#import "WANRBasicError.h"
#import "WAURLResponse.h"
#import "WAResponseDescriptor.h"
#import "WARequestDescriptor.h"
#import "WANetworkRoute.h"

#import "Enterprise.h"

SPEC_BEGIN(RoutingManagerRequestMappingBatchTests)

static NSString *kBaseURL = @"http://www.google.com";

describe(@"RoutingManagerRequestMappingBatchTests", ^{
    
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
                                                                                                                method:WAObjectRequestMethodGET | WAObjectRequestMethodPUT | WAObjectRequestMethodDELETE
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
        // Create the batch manager
        // ———————————————————————————————————————————
        WABatchManager *batchManager = [[WABatchManager alloc] initWithBatchPath:@"batch" limit:1];
        [batchManager reset];
        
        WANetworkRoute *postEnterprise = [WANetworkRoute routeWithObjectClass:nil
                                                                  pathPattern:@"enterprises"
                                                                       method:WAObjectRequestMethodPOST];
        
        WANetworkRoute *putDeleteEnterprise = [WANetworkRoute routeWithObjectClass:nil
                                                                       pathPattern:@"enterprises/:itemID"
                                                                            method:WAObjectRequestMethodPUT|WAObjectRequestMethodDELETE];
        
        [batchManager addRouteToBatchIfOffline:postEnterprise];
        [batchManager addRouteToBatchIfOffline:putDeleteEnterprise];
        
        // ———————————————————————————————————————————
        // Create the routing manager
        // ———————————————————————————————————————————
        WAAFNetworkingRequestManager *requestManager = [WAAFNetworkingRequestManager new];
        
        routingManager = [WANetworkRoutingManager managerWithBaseURL:[NSURL URLWithString:kBaseURL]
                                                      requestManager:requestManager
                                                      mappingManager:mappingManager
                                               authenticationManager:nil
                                                        batchManager:batchManager];
        
        // ———————————————————————————————————————————
        // Stub requests
        // ———————————————————————————————————————————
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.path isEqualToString:@"/enterprises"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            if ([request.HTTPMethod isEqualToString:@"POST"]) {
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                                     code:NSURLErrorNotConnectedToInternet
                                                 userInfo:nil];
                
                return [OHHTTPStubsResponse responseWithError:error];
            }
            return nil;
        }];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.path isEqualToString:@"/enterprises/1"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            if ([request.HTTPMethod isEqualToString:@"GET"]) {
                return [OHHTTPStubsResponse responseWithData:[@"{\"id\": 1, \"name\": \"Test\"}" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{@"Content-Type":@"application/json"}];
            }
            return nil;
        }];
    });

    it(@"Batch if offline when received", ^{
        // CF stub response
        [[theValue([routingManager.batchManager needsFlushing]) should] equal:@NO];
        
        [routingManager postObject:nil
                              path:@"enterprises"
                        parameters:nil
                           success:nil
                           failure:nil];
        
        [[expectFutureValue(theValue([routingManager.batchManager needsFlushing])) shouldEventually] equal:@YES];
    });
    
    it(@"Batch if offline when sending", ^{
        // Stub reachability
        [(WAAFNetworkingRequestManager *)routingManager.requestManager stub:@selector(isReachable) andReturn:theValue(NO)];
        
        [routingManager putObject:nil
                             path:@"enterprises/1"
                       parameters:nil
                          success:nil
                          failure:nil];
        
        [[theValue([routingManager.batchManager needsFlushing]) should] equal:@YES];
    });
    
    it(@"Flush", ^{
        __block NSUInteger callCount = 0;
        id stubs = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.path isEqualToString:@"/batch"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            NSArray *array = nil;
            switch(callCount) {
                case 0:
                {
                    array = @[@{
                                  @"body": @"{\"id\": 1, \"name\": \"Test\"}",
                                  @"code": @200
                                  }];
                }
                    break;
                case 1:
                {
                    array = @[@{
                                  @"body": @"{\"id\": 2, \"name\": \"Test\"}",
                                  @"code": @200
                                  }];
                }
                    break;
                case 2:
                {
                    array = @[@{
                                  @"body": [NSNull null],
                                  @"code": @200
                                  }];
                }
                    break;
            }
            
            callCount++;
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
            return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:@{@"Content-Type":@"application/json"}];
        }];
        
            // Stub reachability
            [(WAAFNetworkingRequestManager *)routingManager.requestManager stub:@selector(isReachable) andReturn:theValue(YES)];
        
        [[theValue([routingManager.batchManager needsFlushing]) should] equal:@YES];
        
        [[[memoryStore objectsWithAttributes:@[@1, @2] forMapping:enterpriseMapping] should] haveCountOf:0];
        
        __block NSArray *_mappedObjects     = nil;
        __block WAObjectResponse *_response = nil;
        __block id _error                   = nil;
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
        // See the get
        [[expectFutureValue(_mappedObjects) shouldEventually] beNonNil];
        [[expectFutureValue(_mappedObjects) shouldEventually] haveCountOf:1];
        [[expectFutureValue([_mappedObjects firstObject]) shouldEventually] beKindOfClass:[Enterprise class]];
        [[expectFutureValue([[_mappedObjects firstObject] name]) shouldEventually] equal:@"Test"];
        [[expectFutureValue(_error) shouldEventually] beNil];
        
        // See the flush
        [[theValue([routingManager.batchManager needsFlushing]) should] equal:@NO];
        
        NSArray *objectsIDs = @[@1, @2];
        [[expectFutureValue([memoryStore objectsWithAttributes:objectsIDs forMapping:enterpriseMapping]) shouldEventually] haveCountOf:2];
        
        [OHHTTPStubs removeStub:stubs];
    });
    
    it(@"Batch and delete", ^{
        __block NSUInteger callCount = 0;

        id stubs = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.path isEqualToString:@"/batch"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            NSArray *array = nil;
            switch(callCount) {
                case 0:
                {
                    array = @[@{
                                  @"body": @"{\"id\": 1, \"name\": \"Test\"}",
                                  @"code": @200
                                  }];
                }
                    break;
                case 1:
                {
                    array = @[@{
                                  @"body": @"{\"id\": 2, \"name\": \"Test\"}",
                                  @"code": @200
                                  }];
                }
                    break;
                case 2:
                {
                    array = @[@{
                                  @"body": [NSNull null],
                                  @"code": @200
                                  }];
                }
                    break;
            }
            
            callCount++;
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
            return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:@{@"Content-Type":@"application/json"}];
        }];
        
        // Stub reachability
        [(WAAFNetworkingRequestManager *)routingManager.requestManager stub:@selector(isReachable) andReturn:theValue(NO)];
        [[theValue([routingManager.batchManager needsFlushing]) should] equal:@NO];
        
        [routingManager postObject:nil
                              path:@"enterprises"
                        parameters:nil
                           success:nil
                           failure:nil];
        
        [routingManager putObject:nil
                             path:@"enterprises/1"
                       parameters:nil
                          success:nil
                          failure:nil];
        
        [routingManager deleteObject:nil
                                path:@"enterprises/2"
                          parameters:nil
                             success:nil
                             failure:nil];
        
        [[theValue([routingManager.batchManager needsFlushing]) should] equal:@YES];
        
        [(WAAFNetworkingRequestManager *)routingManager.requestManager stub:@selector(isReachable) andReturn:theValue(YES)];
        
        // Get to trigger the flush
        [routingManager getObject:nil
                             path:@"enterprises/1"
                       parameters:nil
                          success:nil
                          failure:nil];
        
        // See the flush
        [[theValue([routingManager.batchManager needsFlushing]) should] equal:@NO];        

        NSArray *objectsIDs = @[@1, @2];
        [[expectFutureValue([memoryStore objectsWithAttributes:objectsIDs forMapping:enterpriseMapping]) shouldEventually] haveCountOf:1];
        
        [OHHTTPStubs removeStub:stubs];
    });
    
    afterAll(^{
        [OHHTTPStubs removeAllStubs];
    });
});

SPEC_END