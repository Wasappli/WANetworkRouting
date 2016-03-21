//
//  ViewController.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "WAProgress.h"

#import "CommentsTableViewController.h"

#import "Post.h"

#import <M13ProgressSuite/UINavigationController+M13ProgressViewBar.h>

@interface ViewController ()

@property (nonatomic, strong) NSArray *posts;

@end

@implementation ViewController

static NSString *kPostCellIdentifier = @"kPostCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kPostCellIdentifier];
    
    [self.navigationController setProgress:0.0f animated:NO];
    [self.navigationController showProgress];
    [self.navigationController setIndeterminate:YES];

    WAProgress *mainProgress = [[WAProgress alloc] initWithParent:nil userInfo:nil];
    mainProgress.totalUnitCount = 10;
    
    [mainProgress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.routingManager getObjectsAtPath:@"posts"
                                      parameters:nil
                                        progress:^(WAObjectRequest *objectRequest, NSProgress *uploadProgress, NSProgress *downloadProgress, NSProgress *mappingProgress) {
                                            [self.navigationController setIndeterminate:NO];
                                            [mainProgress addChildOnce:downloadProgress withPendingUnitCount:8];
                                            [mainProgress addChildOnce:mappingProgress withPendingUnitCount:2];
                                        }
                                         success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                                             self.posts = mappedObjects;
                                             [self.tableView reloadData];
                                             
                                             [self.navigationController finishProgress];
                                             [mainProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
                                         }
                                         failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                                             [self.navigationController cancelProgress];
                                             [mainProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
                                         }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPostCellIdentifier];
    Post *post = self.posts[indexPath.row];
    
    cell.textLabel.text = post.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentsTableViewController *c = [[CommentsTableViewController alloc] initWithPost:self.posts[indexPath.row]];
    [self.navigationController pushViewController:c animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([object isKindOfClass:[NSProgress class]]) {
        [self.navigationController setProgress:[change[NSKeyValueChangeNewKey] floatValue] animated:YES];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
