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

- (instancetype _Nonnull)initWithOriginalError:(NSError *_Nullable)error response:(WAObjectResponse *_Nullable)response;

@property (nonatomic, strong, readonly) NSError          *_Nullable originalError;
@property (nonatomic, strong, readonly) NSError          *_Nullable finalError;
@property (nonatomic, strong, readonly) WAObjectResponse *_Nullable response;

@end
