//
//  WABatchObject.h
//  WANetworkRouting
//
//  Created by Marian Paul on 29/03/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

/**
 *  A batch object describing a `WAObjectRequest`
 */
@interface WABatchObject : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *batchID; // The batch ID
@property (nonatomic, strong) NSString *method; // The method (POST GET PUT ...)
@property (nonatomic, strong) NSString *uri; // The relative path (/items for http://someURL.com/items)
@property (nonatomic, strong) id parameters; // The parameters
@property (nonatomic, strong) id headers; // The headers for the specific request. Default is content type = application/json

@end
