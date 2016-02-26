//
//  WAResponseDescriptorTests.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <WAMapping/WAMapping.h>

#import "WAResponseDescriptor.h"
#import "WAObjectRequest.h"

SPEC_BEGIN(ResponseDescriptors)

describe(@"Response descriptor matching", ^{
    WAEntityMapping *enterpriseMapping = [WAEntityMapping mappingForEntityName:@"Enterprise"];
    WAEntityMapping *employeeMapping = [WAEntityMapping mappingForEntityName:@"Employee"];
    
    WAResponseDescriptor *enterpriseResponseDescriptor = [WAResponseDescriptor responseDescriptorWithMapping:enterpriseMapping
                                                                                                      method:WAObjectRequestMethodGET | WAObjectRequestMethodPUT
                                                                                                 pathPattern:@"enterprises/:itemID"
                                                                                                     keyPath:@"enterprise"];
    
    WAResponseDescriptor *employeesInEnterpriseResponseDescriptor = [WAResponseDescriptor responseDescriptorWithMapping:employeeMapping
                                                                                                                 method:WAObjectRequestMethodGET | WAObjectRequestMethodPUT
                                                                                                            pathPattern:@"enterprises/:itemID"
                                                                                                                keyPath:@"employees"];
    
    WAResponseDescriptor *chiefsInEnterpriseResponseDescriptor = [WAResponseDescriptor responseDescriptorWithMapping:employeeMapping
                                                                                                              method:WAObjectRequestMethodGET
                                                                                                         pathPattern:@"enterprise/:itemID/chiefs"
                                                                                                             keyPath:@"chiefs"];
    
    WAResponseDescriptor *chiefResponseDescriptor = [WAResponseDescriptor responseDescriptorWithMapping:employeeMapping
                                                                                                 method:WAObjectRequestMethodGET | WAObjectRequestMethodPUT
                                                                                            pathPattern:@"chiefs/:itemID"
                                                                                                keyPath:@"chiefs"];
    
    WAObjectRequest *enterpriseGETRequest = [WAObjectRequest requestWithHTTPMethod:WAObjectRequestMethodGET
                                                                              path:@"enterprises/1234"
                                                                        parameters:nil
                                                                   optionalHeaders:nil];
    
    WAObjectRequest *chiefsInEnterpriseGETRequest = [WAObjectRequest requestWithHTTPMethod:WAObjectRequestMethodGET
                                                                                      path:@"enterprise/1234/chiefs"
                                                                                parameters:nil
                                                                           optionalHeaders:nil];
    
    it(@"Enterprises response descriptor should match", ^{
        [[theValue([enterpriseResponseDescriptor matchesObjectRequest:enterpriseGETRequest]) should] equal:theValue(YES)];
    });
    
    it(@"Employees in enterprise response descriptor should match", ^{
        [[theValue([employeesInEnterpriseResponseDescriptor matchesObjectRequest:enterpriseGETRequest]) should] equal:theValue(YES)];
    });
    
    it(@"Chiefs response descriptor should not match", ^{
        [[theValue([chiefResponseDescriptor matchesObjectRequest:enterpriseGETRequest]) should] equal:theValue(NO)];
    });
    
    it(@"Getting enterprise should not match chief response descriptor", ^{
        [[theValue([chiefsInEnterpriseResponseDescriptor matchesObjectRequest:enterpriseGETRequest]) should] equal:theValue(NO)];
    });
    
    it(@"Getting chiefs from enterprise should match chief descriptor", ^{
        [[theValue([chiefsInEnterpriseResponseDescriptor matchesObjectRequest:chiefsInEnterpriseGETRequest]) should] equal:theValue(YES)];
    });
    
    it(@"Getting chiefs from enterprise should not match enterprise descriptor", ^{
        [[theValue([enterpriseResponseDescriptor matchesObjectRequest:chiefsInEnterpriseGETRequest]) should] equal:theValue(NO)];
    });
});

SPEC_END

