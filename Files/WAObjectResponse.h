//
//  WAObjectResponse.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@class WAURLResponse;

@interface WAObjectResponse : NSObject

@property (nonatomic, strong) id _Nonnull responseObject;
@property (nonatomic, strong) WAURLResponse *_Nonnull urlResponse;

@end
