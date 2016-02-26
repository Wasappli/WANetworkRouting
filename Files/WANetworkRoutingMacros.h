//
//  WANetworkRoutingMacros.h
//  WANetworkRouting
//
//  Created by Marian Paul on 23/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#ifndef WANetworkRoutingMacros_h
#define WANetworkRoutingMacros_h

#define WANRParameterAssert(obj) NSParameterAssert(obj)
#define WANRClassParameterAssert(obj, className) WANRParameterAssert([obj isKindOfClass:[className class]])
#define WANRClassParameterAssertIfExists(obj, className) if (obj) { WANRParameterAssert([obj isKindOfClass:[className class]]);}
#define WANRProtocolParameterAssertIfExists(obj, protocolName) if (obj) { WANRParameterAssert([obj conformsToProtocol:@protocol(protocolName)]);}
#define WANRProtocolParameterAssert(obj, protocolName) WANRParameterAssert([obj conformsToProtocol:@protocol(protocolName)]);
#define WANRProtocolClassAssert(class, protocolName) WANRParameterAssert([class conformsToProtocol:@protocol(protocolName)]);

#define wanrWeakify(var) __weak typeof(var) WANRWeak_##var = var;

#define wanrStrongify(var) \
_Pragma("clang diagnostic push") \
__strong typeof(var) var = WANRWeak_##var; \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
_Pragma("clang diagnostic pop")

#endif /* WANetworkRoutingMacros_h */
