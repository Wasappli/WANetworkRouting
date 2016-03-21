//
//  Comment.h
//  WANetworkRouting
//
//  Created by Marian Paul on 16-03-20.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (nonatomic, strong) NSNumber *postID;
@property (nonatomic, strong) NSNumber *commentID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *body;

@end
