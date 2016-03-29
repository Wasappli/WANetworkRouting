//
//  WANetworkRoutePattern.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WANetworkRoutePattern.h"
#import "WANetworkRoutingMacros.h"

@interface WANetworkRoutePattern ()

@property (nonatomic, strong) NSString *pattern;
@property (nonatomic, strong) NSArray<NSString *> *patternPathComponents;

@end

NSString * const WANetworkRoutePatternObjectPrefix = @":";
static NSString *WANetworkRoutePatternObjectEscapeString = @"\\";

@implementation WANetworkRoutePattern

- (instancetype)initWithPattern:(NSString *)pattern {
    WANRClassParameterAssert(pattern, NSString);
    
    self = [super init];
    if (self) {
        self->_pattern = pattern;
        self->_patternPathComponents = pattern.pathComponents;
    }
    
    return self;
}

- (BOOL)matchesRoute:(NSString *)route {
    NSArray *routePathComponents = route.pathComponents;
    
    // If the count is not the same, no way this can match
    if ([routePathComponents count] != [self.patternPathComponents count]) {
        return NO;
    }
    
    BOOL matches = YES;
    
    for (NSInteger i = 0 ; i < [routePathComponents count] ; i++) {
        NSString *routePath = routePathComponents[i];
        
        NSString *patternPath = self.patternPathComponents[i];
        
        // See if the pattern path is a future object
        if ([patternPath hasPrefix:WANetworkRoutePatternObjectPrefix]) {
            continue;
        }
        
        // If the strings are not equal, then we are done
        if (![routePath isEqualToString:patternPath]) {
            matches = NO;
            break;
        }
    }
    
    return matches;
}

- (NSString *)stringFromObject:(id)object {
    NSMutableString *finalString = [self.pattern mutableCopy];
    
    for (NSString *pathComponent in self.patternPathComponents) {
        // See if the pathComponent is a value
        if ([pathComponent hasPrefix:WANetworkRoutePatternObjectPrefix]) {
            NSString *parameterName = [pathComponent substringFromIndex:1];
            NSString *suffix = nil;
            
            NSRange escapedCharactersRange = [pathComponent rangeOfString:WANetworkRoutePatternObjectEscapeString];
            if (escapedCharactersRange.location != NSNotFound) {
                parameterName = [parameterName substringToIndex:escapedCharactersRange.location - [WANetworkRoutePatternObjectPrefix length]];
                suffix        = [pathComponent substringFromIndex:escapedCharactersRange.location + escapedCharactersRange.length];
            }
            
            NSString *value = [[object valueForKeyPath:parameterName] description];
            if (suffix) {
                value = [value stringByAppendingString:suffix];
            }
            
            [finalString replaceOccurrencesOfString:pathComponent
                                         withString:value
                                            options:NSCaseInsensitiveSearch
                                              range:NSMakeRange(0, finalString.length)];
        }
    }
    
    return [finalString copy];
}

@end
