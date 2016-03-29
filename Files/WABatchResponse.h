//
//  WABatchResponse.h
//  WANetworkRouting
//
//  Created by Marian Paul on 16-03-30.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@class WAObjectRequest, WAObjectResponse;

/**
 *  The batch response
 *  Contains the original request, the reponse (object and status code) plus the mapped objects if a mapper is used
 */
@interface WABatchResponse : NSObject

@property (nonatomic, strong) WAObjectRequest  *request;
@property (nonatomic, strong) WAObjectResponse *response;
@property (nonatomic, strong) NSArray          *mappedObjects;

@end
