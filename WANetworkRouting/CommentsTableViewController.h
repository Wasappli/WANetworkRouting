//
//  CommentsTableViewController.h
//  WANetworkRouting
//
//  Created by Marian Paul on 16-03-20.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Post;

@interface CommentsTableViewController : UITableViewController

- (instancetype)initWithPost:(Post *)post;

@end
