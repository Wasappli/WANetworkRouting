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

@property (nonatomic, strong) NSNumber *_Nonnull batchID; // The batch ID
@property (nonatomic, strong) NSString *_Nonnull method; // The method (POST GET PUT ...)
@property (nonatomic, strong) NSString *_Nonnull uri; // The relative path (/items for http://someURL.com/items)
@property (nonatomic, strong) _Nullable id parameters; // The parameters
@property (nonatomic, strong) _Nullable id headers; // The headers for the specific request. Default is content type = application/json

@end
