## 1.0.0 - Released Jul 27, 2016
- Fixed an issue with response descriptors and keypaths… Wasn't working!

## 0.0.9 - Released Jun 10, 2016
- Send the WAObjectRequest for authentication

## 0.0.8 - Released Apr 27, 2016
- Added support for watch os

## 0.0.7 - Released Apr 22, 2016
### Pods
- Updated `AFNetworking` from `3.0` to `3.1`
- Updated `WAMapping` from `0.0.6` to `0.0.7`

### Batch Manager
- Added `canEnqueue` behavior from response and error
- Enqueue on `Offline` or `Time out` error on `NSURLErrorDomain`
- Enqueue on http status code of `500` (server down) or `503` (maintenance) 

## 0.0.6 - Released Mar 25, 2016
- Added Batch manager
- Fixed an issue on route and `DELETE`: the object is no longer mapped as a request
- Fixed an issue on request descriptors and routes with keypath. You can now write `meetings/:meeting.itemID/privatenotes/:itemID`
- Added reachability on `WARequestManagerProtocol` and `WAAFNetworkingRequestManager`: `isReachable`
- When you delete an object without using routes|request descriptors, the path is parsed to get the object ID to delete. It was not deleted before
- Fixed crashes when object requests have no success or failure blocks
- Fixed a crash when your request descriptor have no `shouldMapBlock`
 
## 0.0.5 - Released Mar 25, 2016
Fixed an issue with mapping progress when the object to map is empty

## 0.0.4 - Released Mar 22, 2016
Fixed an issue with mapping progress with several response descriptors

## 0.0.3 - Released Mar 21, 2016

This release brings the progress for download and mapping using `NSProgress`!

```objc
[routingManager getObjectsAtPath:@"posts"
                      parameters:nil
                        progress:^(WAObjectRequest *objectRequest, NSProgress *uploadProgress, NSProgress *downloadProgress, NSProgress *mappingProgress) {
                            NSLog(@"downloadProgress: %f -> %@ — mappingProgress: %f -> %@", downloadProgress.fractionCompleted, downloadProgress.localizedDescription, mappingProgress.fractionCompleted, mappingProgress.localizedDescription);
                        }
                         success:^(WAObjectRequest *objectRequest, WAObjectResponse *response, NSArray *mappedObjects) {
                         }
                         failure:^(WAObjectRequest *objectRequest, WAObjectResponse *response, id<WANRErrorProtocol> error) {
                         }];
```

By adding support of `NSProgress`, you can easily cancel the request. You have to call `[downloadProgress cancel]` and/or `[mappingProgress cancel]` depending on where you are on the task.

- Added a simple sample
- You no longer have to create `WAMapper` or `WAReverseMapper`. Simply pass the store.

Was

```objc
WAMemoryStore *memoryStore = [[WAMemoryStore alloc] init];

// Create both a mapper and a reverse mapper
WAMapper *mapper               = [WAMapper newMapperWithStore:memoryStore];
WAReverseMapper *reverseMapper = [WAReverseMapper new];

// Create the mapping manager
WAMappingManager *mappingManager = [WAMappingManager mappingManagerWithMapper:mapper
                                                                reverseMapper:reverseMapper];
```
is

```objc
WAMemoryStore *memoryStore = [[WAMemoryStore alloc] init];

// Create the mapping manager
WAMappingManager *mappingManager = [WAMappingManager mappingManagerWithStore:memoryStore];
```

- For registering default mapping blocks. 

Was

```objc
// Add a default date formatter on mapper
id(^toDateMappingBlock)(id ) = ^id(id value) {
    if ([value isKindOfClass:[NSString class]]) {
        return [dateFormatter dateFromString:value];
    }

    return value;
};

[mapper addDefaultMappingBlock:toDateMappingBlock
           forDestinationClass:[NSDate class]];
```
is

```objc
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


## 0.0.2 - Released Feb 29, 2016
- Fixed an import with missing .h on main header
- Do not ask the store to delete an object if `nil`

## 0.0.1 - Released Feb 26, 2016
Initial release