//
//  WANRBasicError.m
//  WANetworkRouting
//
//  Created by Marian Paul on 16-02-23.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WANRBasicError.h"

@implementation WANRBasicError
@synthesize finalError = _finalError, originalError = _originalError, response = _response;

- (instancetype)initWithOriginalError:(NSError *)error response:(WAObjectResponse *)response {
    self = [super init];
    
    if (self) {
        self->_originalError = error;
        self->_response      = response;
        self->_finalError    = error;
    }
    
    return self;
}

@end
