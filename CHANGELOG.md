## 0.0.4 - Released Mar 22, 2015
Fixed an issue with mapping progress with several response descriptors

## 0.0.3 - Released Mar 21, 2015

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


## 0.0.2 - Released Feb 29, 2015
- Fixed an import with missing .h on main header
- Do not ask the store to delete an object if `nil`

## 0.0.1 - Released Feb 26, 2015
Initial release