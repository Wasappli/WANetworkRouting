# WANetworkRouting

[![Version](https://img.shields.io/cocoapods/v/WANetworkRouting.svg?style=flat)](http://cocoapods.org/pods/WANetworkRouting)
[![License](https://img.shields.io/cocoapods/l/WANetworkRouting.svg?style=flat)](http://cocoapods.org/pods/WANetworkRouting)
[![Platform](https://img.shields.io/cocoapods/p/WANetworkRouting.svg?style=flat)](http://cocoapods.org/pods/WANetworkRouting)

**Developed and Maintained by [ipodishima](https://github.com/ipodishima) Founder & CTO at [Wasappli Inc](http://wasapp.li).**

**Sponsored by [Wisembly](http://wisembly.com/en/)**

A routing library to fetch objects from an API and map them to your app

- [x] Highly customizable: network request, authentication and mapping layers are separate, you can create your own.
- [x] Default network request layer built on top of AFNetworking 3.0
- [x] Default mapping layer built on top of WAMapping
- [x] Built-in object router
- [x] Built-in batch manager
- [x] Different configurations available
- [x] `NSProgress` support
- [x] Tested and used on real projects

Go visit the [wiki](https://github.com/wasappli/WANetworkRouting/wiki) for more details about `WANetworkRouting` advanced use.

`WANetworkRouting` is a library which turns `GET enterprises/:itemID` to `Enterprise : NSManagedObject` from a simple configuration step.

## Install and use
### Cocoapods
Use Cocoapods, this is the easiest way to install the router.

`pod 'WANetworkRouting'`

`#import <WANetworkRouting/WANetworkRouting.h>` 

### `WANetworkRoutingManager`
`WANetworkRoutingManager` is the core component of `WANetworkRouting`. It handles all the requests for you.

The initialization should contains at least a request manager. `WANetworkRouting` has a built in manager `WAAFNetworkingRequestManager` built on top of `AFNetworking 3.0`.

```objc
// Create a request manager
WAAFNetworkingRequestManager *requestManager = [WAAFNetworkingRequestManager new];

// Create the network routing manager 
WANetworkRoutingManager *routingManager = [WANetworkRoutingManager managerWithBaseURL:[NSURL URLWithString:@"http://baseURL.com"]
                                                                       requestManager:requestManager
                                                                       mappingManager:nil
                                                                authenticationManager:nil];

```

** Note ** This `routingManager` will have not mapping layer nor authentication layer. This example demonstrates how easy it is to test your API before configuring the mapping.

You can then perform any operations among `GET|POST|PUT|PATCH|DELETE|HEAD`. For eg:

- Fetch all the enterprises

```objc
[routingManager getObjectsAtPath:@"enterprises"
                      parameters:nil
                         success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                             NSDictionary *json = response.responseObject;
                             // Do something with the JSON
                         }
                         failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                         }];
```

- Update an enterprise

```objc
[routingManager putObject:nil
                     path:@"enterprises/1"
               parameters:@{@"key": @"newValue"}
                  success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                  }
                  failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                  }];
```

### Add mapping layer
This is where things become to be interesting

The idea is to add a mapping layer so that your json gets mapped as objects. This is done by using a default mapping service built on top of [`WAMapping`](https://github.com/wasappli/WAMapping). I strongly encourage you to read the docs about how to configure the mapping.

There are 3 steps:

- Configure the mapping,
- Configure the response descriptor,
- Optional: configure the request descriptor.

#### Step 1: configure the mapping

Have a look at [`WAMapping`](https://github.com/wasappli/WAMapping) for every details about the mapping:

```objc
// Specify a store to use between WAMemoryStore, WANSCodingStore, WACoreDataStore, your own store.
WAMemoryStore *memoryStore = [[WAMemoryStore alloc] init];
           
// Create the mapping description for `Enterprise`
WAEntityMapping *enterpriseMapping = [WAEntityMapping mappingForEntityName:@"Enterprise"];
enterpriseMapping.identificationAttribute = @"itemID";
[enterpriseMapping addAttributeMappingsFromDictionary:@{
                                                        @"id": @"itemID",
                                                        @"name": @"name",
                                                        @"address.street_number": @"streetNumber"}];
// Create the mapping manager
WAMappingManager *mappingManager = [WAMappingManager mappingManagerWithStore:memoryStore];
                                                                
WAAFNetworkingRequestManager *requestManager = [WAAFNetworkingRequestManager new];

// Create the network routing manager 
WANetworkRoutingManager *routingManager = [WANetworkRoutingManager managerWithBaseURL:[NSURL URLWithString:@"http://baseURL.com"]
                                                                       requestManager:requestManager
                                                                       mappingManager:mappingManager
                                                                authenticationManager:nil];
                                                                
// Add a default date formatter on mapper
id(^toDateMappingBlock)(id ) = ^id(id value) {
    if ([value isKindOfClass:[NSString class]]) {
        return [dateFormatter dateFromString:value];
    }

    return value;
};

[mappingManager addDefaultMappingBlock:toDateMappingBlock
                   forDestinationClass:[NSDate class]];
```

#### Step 2: configure the response descriptors
This will map a path with a mapping. For example, when fetching `/enterprises`, you would get a JSON as

```
{
	"array_of_enterprises": [{
		"name": "Enterprise 1"
	}, {
		"name": "Enterprise 2"
	}]
}
```

The request descriptor would then be as follows:

```objc
WAResponseDescriptor *enterprisesResponseDescriptor =
[WAResponseDescriptor responseDescriptorWithMapping:enterpriseMapping
                                             method:WAObjectRequestMethodGET
                                        pathPattern:@"enterprises" // The path on the URL
                                            keyPath:@"array_of_enterprises"]; // The key path to access the enterprises on JSON
```

For a `GET` or a `PUT` on an enterprise, which would be returned as

```
{
	"name": "Enterprise 1"
}
```

```objc
WAResponseDescriptor *singleEnterpriseResponseDescriptor =
[WAResponseDescriptor responseDescriptorWithMapping:enterpriseMapping
                                             method:WAObjectRequestMethodGET | WAObjectRequestMethodPUT // Specify multiple methods
                                        pathPattern:@"enterprises/:itemID" // The path
                                            keyPath:nil]; // The response would directly returns the object
```

Please note the syntax `enterprises/:itemID`: `:` means that the value would be replaced dynamically knowning that `itemID` is the property name on client side.

Finally, add the response descriptors to the mapping manager

```objc
[mappingManager addResponseDescriptor:enterprisesResponseDescriptor];
[mappingManager addResponseDescriptor:singleEnterpriseResponseDescriptor];
```

You can now use `WANetworkRouting` as this:

```objc
[routingManager getObjectsAtPath:@"enterprises"
                      parameters:nil
                         success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                             NSArray<Enterprise *> *enterprises = mappedObjects;
                             // Do something with the enterprises
                         }
                         failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                         }];
```

#### Step 3: configure the request descriptor
This step is optional, but allows you to reverse map an object to send it to the server.
Rather than creating by yourself the parameters dictionary on a `POST` for example, you could write:

```objc
WARequestDescriptor *enterpriseRequestDescriptor =
[WARequestDescriptor requestDescriptorWithMethod:WAObjectRequestMethodPOST
                                     pathPattern:@"enterprises" // The path on the URL
                                         mapping:enterpriseMapping
                                  shouldMapBlock:nil // On optional block which let you configure rather you want to reverse map a relation ship or not
                                  requestKeyPath:nil]; // The key path for the final dictionary
                                  
[mappingManager addRequestDescriptor:enterpriseRequestDescriptor];
```

Please note that the `requestKeyPath` fits with how your object would be wrapped on the parameters. If nil, the dictionary is the object as dictionary.

```
{
	"requestKeyPathValue": {
		"name": "Enterprise 1"
	}
}
```

This allows you to post an object like this

```objc
Enterprise *enterprise = [Enterprise new];
enterprise.name = @"Test";
        
[routingManager postObject:enterprise
                      path:@"enterprises"
                parameters:nil
                   success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                   }
                   failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                   }];
```

This will reverse map the `enterprise` to a dictionary and send it as parameters on `POST enterprise`. All magically without anymore work!

**Note**: If `enterprise` has no value for its `identificationAttribute` (see the mapping), the enterprise object would be automatically deleted from the store since the object returned by the server would be a new one with an `identificationAttribute`. Said in other words: you do not have to deal with potential duplicates.

### Add routing layer

We just saw this call

```objc
[routingManager postObject:enterprise
                      path:@"enterprises"
                parameters:nil
                   success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                   }
                   failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                   }];
```

Wouldn't it be great to write instead?

```objc
[routingManager postObject:enterprise
                      path:nil // No value for path
                parameters:nil
                   success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                   }
                   failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                   }];
```

Here comes the router!

```objc
WANetworkRoute *postEnterpriseRoute =
[WANetworkRoute routeWithObjectClass:[Enterprise class]
                         pathPattern:@"enterprises"
                              method:WAObjectRequestMethodPOST];

[routingManager.router postEnterpriseRoute];
```

Each time you are trying to `POST` an object of class `Enterprise`, it will supply the `enterprises` path for you.

Here is an other example with `GET` and `PUT` routes:

```objc
WANetworkRoute *enterpriseRoute =
[WANetworkRoute routeWithObjectClass:[Enterprise class]
                         pathPattern:@"enterprises/:itemID"
                              method:WAObjectRequestMethodGET | WAObjectRequestMethodPUT];

[routingManager.router addRoute:enterpriseRoute];
```

### Add authentication layer

This layer is important if your API has some authentication. Basically you should have a login/signup endpoint which returns some kind of token that you can renew if the requests gets an error like `401: token expired`.
By implementing the simple `WARequestAuthenticationManagerProtocol` protocol, and passing an instance of your class to the router manager, it will:

- Ask to authenticate the `NSMutableURLRequest`. Should be a token on `Authorization` HTTP header field.
- Ask if a request should be replayed: you received `401: token expired` for example then yes.
- Ask you to authenticate (renew the authorization somehow) and replay the request (`[routingManager enqueueRequest:]`) (The request will automatically be re authorized for you).

This will allow the routing manager to run every requests without any surprise when authentication has expired!

### Add batch 
The batch managers answers two needs:

1/ Let's say that you want to minimize the impact on server of having multiple calls to perform at the same time. Like `GET /me`, `GET /meetings`, `GET /configuration`
2/ Have offline support, for example add notes to a meeting and automatically sync them when you are back online!

Well, `WABatchManager` is there for you

#### Step 1: create a batch api
This library comes with a built-in batch manager from the following specifications. You can either create an API which conforms to the specification, or create a new batch manager from `WABatchManager` which fits your needs.

The specifications: (this is  closely following the batch api requests by facebook [Facebook batch API](https://developers.facebook.com/docs/graph-api/making-multiple-requests))

- Set a limit per session
- The data sent has the following format

```
{
	"batch": [{
		"uri": "\/meetings\/Ufd8f4e\/notes",
		"method": "POST",
		"body": "{\"note\":{\"hash\":\"817ebd76b6a89eff47bbd8e53f633c93eeadf23e\",\"title\":\"New first note\",\"type\":\"item\",\"position\":0}}",
		"headers": {
          "Content-Type": "application/json"
        }
	}, {
		"uri": "\/meetings\/Ufd8f4e\/notes",
		"method": "POST",
		"body": "{\"note\":{\"hash\":\"f4e893ab9a754c273707b264359e7ec12262959d\",\"title\":\"New second note\",\"type\":\"note\",\"position\":1}}"
	}]
}
```
Please note that `uri` is relative to the base URL and `body` is an encoded string

- Respond with

```
[
  {
    "body": "[{\"note\":\"...\"}]
    "code": 200
  },
  {
    "body": "[{\"note\":\"...\"}]
    "code": 200
  }
 ]
 ```

#### Step 2: create a batch manager

```objc
WABatchManager *batchManager = [[WABatchManager alloc] initWithBatchPath:@"/batch" limit:20];

routingManager = [WANetworkRoutingManager managerWithBaseURL:[NSURL URLWithString:kBaseURL]
                                              requestManager:requestManager
                                              mappingManager:mappingManager
                                       authenticationManager:authManager
                                                batchManager:batchManager];
```

#### Manually batch requests

```objc
// Create a batch session
WABatchSession *batchSession = [WABatchSession new];

// Enqueue the requests you want to perform
[batchSession addRequest:[WAObjectRequest requestWithHTTPMethod:WAObjectRequestMethodGET
                                                           path:@"/me"
                                                     parameters:nil
                                                optionalHeaders:nil]];
[batchSession addRequest:[WAObjectRequest requestWithHTTPMethod:WAObjectRequestMethodGET
                                                           path:@"/meetings"
                                                     parameters:nil
                                                optionalHeaders:nil]];
[batchSession addRequest:[WAObjectRequest requestWithHTTPMethod:WAObjectRequestMethodGET
                                                           path:@"/configuration"
                                                     parameters:nil
                                                optionalHeaders:nil]];
                                                
// Send the session
[batchManager sendBatchSession:batchSession
                  successBlock:^(id<WABatchManagerProtocol> batchManager, NSArray<WABatchResponse *> *batchResponses) {
                      
                  }
                  failureBlock:^(id<WABatchManagerProtocol> batchManager, WAObjectRequest *request, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                      
                  }];
```

#### Add an offline mode
The offline mode works out of the box.
Basically, you register routes describing requests which can be enqueued if there is a network issue (you should not include `GET`) and you let the library do its job! It also integrates with mapping and authentication without any further step.

- Create routes to describe the requests to be enqueued

```objc
// Meetings
WANetworkRoute *modifyMeeting = [WANetworkRoute routeWithObjectClass:nil
                                                         pathPattern:@"meetings/:itemID"
                                                              method:WAObjectRequestMethodPUT | WAObjectRequestMethodeDELETE];

// Action items
WANetworkRoute *postActionItem = [WANetworkRoute routeWithObjectClass:nil
                                                          pathPattern:@"meetings/:itemID/notes"
                                                               method:WAObjectRequestMethodPOST];
```
- Add them to the batch manager

```objc
[batchManager addRouteToBatchIfOffline:modifyMeeting];
[batchManager addRouteToBatchIfOffline:postActionItem];
```

- Answers to errors

```objc
[self.apiManager putObject:meeting
                      path:nil
                parameters:nil
                   success:...
                   failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                       SLDMeeting *meetingReturned = nil;
                       // Check if the error is a batch one
                       if ([[error.originalError.domain isEqualToString:WANetworkRoutingManagerErrorDomain] && error.originalError.code == WANetworkRoutingManagerErrorRequestBatched) {
                           // Return the meeting for any UI update
                           meetingReturned = meeting;
                           // Store a "has offline changes" flag
                           meeting.hasOfflineModifications = @YES;
                           // Save the store
                           [store save];
                       }
                       
                       if (completion) {
                           completion(meetingReturned, error);
                       }
                   }];
```

- Wait for flush. The library automatically flush the offline changes on any request made while online. You can also manually trigger the flush with 

```objc
if ([batchManager needsFlushing]) {
  [batchManager flushDataWithCompletion:completion];
}
```

- Perform actions post flush

```objc
[batchManager setOfflineFlushSuccessBlock:^(id <WABatchManagerProtocol> batchManager, NSArray<WABatchResponse *> *batchResponses) {
    if (![batchManager needsFlushing]) {
        // Consider all meetings synchronized. You could also iterate trough batch responses
        NSArray *notSyncedMeetings = [SLDMeeting findAll];
        for (SLDMeeting *meeting in notSyncedMeetings) {
            meeting.hasOfflineModifications = @NO;
        }
        
        [store save];
    }
}];
```

## Progress

You can track the progress of your request. This library uses `NSProgress` class which is a great tool for dealing with progress.
If your app supports iOS 9+, there is the explicit child feature. You can then write:

(Please note that we are using a subclass of `NSProgress` that you can find on the sample. This is because `NSProgress` does not allow you to check if a progress already has a child :/)

```objc
WAProgress *mainProgress = [[WAProgress alloc] initWithParent:nil userInfo:nil];
mainProgress.totalUnitCount = 100; // 100%

// Add an observer to track the fraction completed
[mainProgress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:NSKeyValueObservingOptionNew context:nil];

                                     }];

[routingManager getObjectsAtPath:@"posts"
                      parameters:nil
                        progress:^(WAObjectRequest *objectRequest, NSProgress *uploadProgress, NSProgress *downloadProgress, NSProgress *mappingProgress) {
                            // Add the progress as a child
                            [mainProgress addChildOnce:downloadProgress withPendingUnitCount:80]; // Network counts as 80% of the time
                            [mainProgress addChildOnce:mappingProgress withPendingUnitCount:20]; // Mapping counts as 20% of the time. This is arbitrary
                        }
                         success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                             self.posts = mappedObjects;
                             [self.tableView reloadData];
                             
                             // Remove the observer!
                             [mainProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
                         }
                         failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                             [mainProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
                         }];

...

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([object isKindOfClass:[NSProgress class]]) {
        NSLog(@"New progress is %f", [change[NSKeyValueChangeNewKey] floatValue]);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

```
	
If your app targets less than iOS 9, I suggest you to calculate your own progress, this is simple since it is synchronous.

## Cancellation

Because of `NSProgress`, you can easily cancel the request:
You have to call `[downloadProgress cancel]` and `[mappingProgress cancel]` and it will cancel either the mapping or the server fetch task depending on where you are on the process.

## Errors

Each api has a way to describe errors details others than the http codes (404, 403, 401, ...). For example, you could have a response like:

```
{
	"error": {
		"error_code": 4,
		"error_description": "The token is expired"
	}
}
```

The `WANetworkRouting` allows you to customize the error handling and retrieve both code and error description. Let's see how:
It's an other protocol (again): `WANRErrorProtocol`

### Create your own class
The routing manager comes with a default error class which does nothing except being allocated. 

```objc
@interface MyAPIError : NSObject <WANRErrorProtocol>
@end

@implementation MyAPIError 

- (instancetype)initWithOriginalError:(NSError *)error response:(WAObjectResponse *)response {
    self = [super init];
    
    if (self) {
        self->_originalError = error;
        self->_response      = response;
        self->_finalError    = error;
        
        NSDictionary *errorDescription = response.responseObject[@"error"];
        NSInteger errorCode = [errorDescription[@"error_code"] integerValue];
        NSString *errorDesc = errorDescription[@"error_description"];
        
        self->_finalError = [NSError errorWithDomain:MyDomain
                                                code:errorCode
                                            userInfo:@{
                                                       NSLocalizedDescriptionKey: errorDesc
                                                       }];
    }
    
    return self;
}

@end

```

### Register the class

```objc
WAAFNetworkingRequestManager *requestManager = [WAAFNetworkingRequestManager new];
requestManager.errorClass = [MyAPIError class];
```

### Use the class

```objc
[routingManager postObject:enterprise
                      path:nil
                parameters:nil
                   success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                   }
                   failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, MyAPIError *error) {
                   		if (error.finalError.errorCode == 4) {
                   			// Token has expired :/
                   		}
                   }];
```

## Delete a ressource

A quick word about deletion:

If you write
```objc
[routingManager deleteObject:enterprise
                        path:nil
                  parameters:nil
                     success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                   }
                     failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, MyAPIError *error) {
                   }];
```

This will automatically delete enterprise from the store on success! Be careful that if you delete an object only from it's ressource, it's up to you to delete it from your store (`[routingManager deleteObject:nil path:@"enterprises/1"...]`).

## Get the HTTP code and header fields from the response

```objc
// WAObjectResponse *response

NSInteger responseStatusCode = response.urlResponse.statusCode;
NSDictionary *httpHeaderFields = response.urlResponse.httpHeaderFields;
```

## Inspiration
Let's be honest, you'll find some things which looks like [Restkit](https://github.com/RestKit/RestKit).
I used RestKit for a while on a very big projects, but it tends to be too much magic and hard to maintain for our need which remains simple.
For example: upgrading `AFNetworking` on RestKit is just... Well, something we wait for months!

By compartimenting the layers, I hope to fix this issue!

#Contributing : Problems, Suggestions, Pull Requests?

Please open a new Issue [here](https://github.com/Wasappli/WANetworkRouting/issues) if you run into a problem specific to WANetworkRouting.

For new features pull requests are encouraged and greatly appreciated! Please try to maintain consistency with the existing code style. If you're considering taking on significant changes or additions to the project, please ask me before by opening a new issue to have a chance for a merge.
Please also run the tests before ;)

#That's all folks !

- If your are happy don't hesitate to send me a tweet [@ipodishima](http://twitter.com/ipodishima)!
- Distributed under MIT licence.
- Follow Wasappli on [facebook](https://www.facebook.com/wasappli)
