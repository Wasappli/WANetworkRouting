//
//  CommentsTableViewController.m
//  WANetworkRouting
//
//  Created by Marian Paul on 16-03-20.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "CommentsTableViewController.h"
#import "Post.h"
#import "Comment.h"

#import "AppDelegate.h"
#import "WAProgress.h"

#import <M13ProgressSuite/UINavigationController+M13ProgressViewBar.h>

@interface CommentsTableViewController ()

@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) NSArray *comments;

@end

@implementation CommentsTableViewController

- (instancetype)initWithPost:(Post *)post {
    self = [super init];
    if (self) {
        self->_post = post;
    }
    return self;
}

static NSString *kCommentCellIdentifier = @"kCommentCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCommentCellIdentifier];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.title = [NSString stringWithFormat:@"Comments for post %@", self.post.postID];
    
    [self.navigationController setProgress:0.0f animated:NO];
    [self.navigationController showProgress];
    [self.navigationController setIndeterminate:YES];
    
    WAProgress *mainProgress = [[WAProgress alloc] initWithParent:nil userInfo:nil];
    mainProgress.totalUnitCount = 10;
    
    [mainProgress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:nil];
    
    // Get comments
    [appDelegate.routingManager getObjectsAtPath:[NSString stringWithFormat:@"posts/%@/comments", self.post.postID]
                                      parameters:nil
     progress:^(WAObjectRequest *objectRequest, NSProgress *uploadProgress, NSProgress *downloadProgress, NSProgress *mappingProgress) {
         [self.navigationController setIndeterminate:NO];
         [mainProgress addChildOnce:downloadProgress withPendingUnitCount:8];
         [mainProgress addChildOnce:mappingProgress withPendingUnitCount:2];
     }
                                         success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                                             self.comments = [mappedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.class == %@", [Comment class]]];
                                             [self.tableView reloadData];
                                         }
                                         failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                                             [self.navigationController cancelProgress];
                                             [mainProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
                                         }];
    
    mainProgress.totalUnitCount += 10;
    
    // Refresh the post, just for the example
    [appDelegate.routingManager getObject:self.post
                                     path:nil
                               parameters:nil
                                 progress:^(WAObjectRequest *objectRequest, NSProgress *uploadProgress, NSProgress *downloadProgress, NSProgress *mappingProgress) {
                                     [self.navigationController setIndeterminate:NO];
                                     [mainProgress addChildOnce:downloadProgress withPendingUnitCount:8];
                                     [mainProgress addChildOnce:mappingProgress withPendingUnitCount:2];
                                 }
                                  success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                                      NSLog(@"Refreshed post %@", mappedObjects);
                                  }
                                  failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                                      NSLog(@"Failed to refresh post with error %@ - %@", error, response.responseObject);
                                      [self.navigationController cancelProgress];
                                      [mainProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
                                  }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([object isKindOfClass:[NSProgress class]]) {
        NSLog(@"%@", change[NSKeyValueChangeNewKey]);
        float progress = [change[NSKeyValueChangeNewKey] floatValue];
        [self.navigationController setProgress:progress animated:YES];

        if (progress >= 1.0f) {
            [self.navigationController finishProgress];
            [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
            
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.comments count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
    Comment *comment = self.comments[indexPath.row];
    
    cell.textLabel.text = [comment.name stringByAppendingFormat:@" - %@", comment.email];
    
    return cell;
}

@end
