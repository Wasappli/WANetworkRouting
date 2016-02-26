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

@property (nonatomic, strong) NSDictionary  *responseObject;
@property (nonatomic, strong) WAURLResponse *urlResponse;

@end
