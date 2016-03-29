//
//  WABatchObject.m
//  WANetworkRouting
//
//  Created by Marian Paul on 29/03/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WABatchObject.h"

@implementation WABatchObject

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.batchID    = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(batchID))];
        self.method     = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(method))];
        self.uri        = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(uri))];
        self.parameters = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(parameters))];
        self.headers    = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(headers))];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.batchID forKey:NSStringFromSelector(@selector(batchID))];
    [aCoder encodeObject:self.method forKey:NSStringFromSelector(@selector(method))];
    [aCoder encodeObject:self.uri forKey:NSStringFromSelector(@selector(uri))];
    [aCoder encodeObject:self.parameters forKey:NSStringFromSelector(@selector(parameters))];
    [aCoder encodeObject:self.headers forKey:NSStringFromSelector(@selector(headers))];
}

@end
