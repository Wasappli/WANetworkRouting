//
//  AppDelegate.m
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#import "Post.h"
#import "Comment.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // ———————————————————————————————————————————
    // Create the mapping
    // ———————————————————————————————————————————
    WAMemoryStore *memoryStore = [[WAMemoryStore alloc] init];
    
    WAEntityMapping *postMapping = [WAEntityMapping mappingForEntityName:@"Post"];
    postMapping.identificationAttribute = @"postID";
    [postMapping addAttributeMappingsFromDictionary:@{
                                                      @"id": @"postID",
                                                      @"title": @"title",
                                                      @"body": @"body"
                                                      }];
    
    WAEntityMapping *commentMapping = [WAEntityMapping mappingForEntityName:@"Comment"];
    commentMapping.identificationAttribute = @"commentID";
    [commentMapping addAttributeMappingsFromDictionary:@{
                                                         @"postId": @"postID",
                                                         @"id": @"commentID",
                                                         @"name": @"name",
                                                         @"body": @"body",
                                                         @"email": @"email"
                                                         }];
    
    // ———————————————————————————————————————————
    // Create the mapping manager
    // ———————————————————————————————————————————
    WAMappingManager *mappingManager = [WAMappingManager mappingManagerWithStore:memoryStore];
    
    // ———————————————————————————————————————————
    // Create the response descriptors
    // ———————————————————————————————————————————
    WAResponseDescriptor *postsResponseDescriptor = [WAResponseDescriptor responseDescriptorWithMapping:postMapping
                                                                                                 method:WAObjectRequestMethodGET
                                                                                            pathPattern:@"posts"
                                                                                                keyPath:nil];
    
    WAResponseDescriptor *singlePostResponseDescriptor = [WAResponseDescriptor responseDescriptorWithMapping:postMapping
                                                                                                      method:WAObjectRequestMethodGET | WAObjectRequestMethodPUT
                                                                                                 pathPattern:@"posts/:postID"
                                                                                                     keyPath:nil];
    [mappingManager addResponseDescriptor:postsResponseDescriptor];
    [mappingManager addResponseDescriptor:singlePostResponseDescriptor];
    
    WAResponseDescriptor *commentsResponseDescriptor = [WAResponseDescriptor responseDescriptorWithMapping:commentMapping
                                                                                                    method:WAObjectRequestMethodGET
                                                                                               pathPattern:@"posts/:postID/comments"
                                                                                                   keyPath:nil];
    [mappingManager addResponseDescriptor:commentsResponseDescriptor];
    
    // ———————————————————————————————————————————
    // Create the request descriptors
    // ———————————————————————————————————————————
    WARequestDescriptor *postRequestDescriptor = [WARequestDescriptor requestDescriptorWithMethod:WAObjectRequestMethodPOST
                                                                                      pathPattern:@"posts"
                                                                                          mapping:postMapping
                                                                                   shouldMapBlock:nil
                                                                                   requestKeyPath:nil];
    
    WARequestDescriptor *postUpdateRequestDescriptor = [WARequestDescriptor requestDescriptorWithMethod:WAObjectRequestMethodPUT
                                                                                            pathPattern:@"posts/:postID"
                                                                                                mapping:postMapping
                                                                                         shouldMapBlock:nil
                                                                                         requestKeyPath:nil];
    [mappingManager addRequestDescriptor:postRequestDescriptor];
    [mappingManager addRequestDescriptor:postUpdateRequestDescriptor];
    
    // ———————————————————————————————————————————
    // Create the routing manager
    // ———————————————————————————————————————————
    WAAFNetworkingRequestManager *requestManager = [WAAFNetworkingRequestManager new];
    
    WANetworkRoutingManager *routingManager = [WANetworkRoutingManager managerWithBaseURL:[NSURL URLWithString:@"http://jsonplaceholder.typicode.com"]
                                                                           requestManager:requestManager
                                                                           mappingManager:mappingManager
                                                                    authenticationManager:nil];
    
    // ———————————————————————————————————————————
    // Configure the router
    // ———————————————————————————————————————————
    WANetworkRoute *enterpriseRoute = [WANetworkRoute routeWithObjectClass:[Post class]
                                                               pathPattern:@"posts/:postID"
                                                                    method:WAObjectRequestMethodGET | WAObjectRequestMethodPUT];
    
    [routingManager.router addRoute:enterpriseRoute];
    
    self.routingManager = routingManager;
    
    ViewController *v = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:v];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.rootViewController = nav;
    self.window = window;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
