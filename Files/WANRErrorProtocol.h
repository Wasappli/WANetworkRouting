//
//  WANRErrorProtocol.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@class WAObjectResponse;

@protocol WANRErrorProtocol <NSObject>

- (instancetype)initWithOriginalError:(NSError *)error response:(WAObjectResponse *)response;

@property (nonatomic, strong, readonly) NSError          *originalError;
@property (nonatomic, strong, readonly) NSError          *finalError;
@property (nonatomic, strong, readonly) WAObjectResponse *response;

@end
