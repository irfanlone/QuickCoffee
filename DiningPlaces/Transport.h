//
//  Transport.h
//
//
//  Created by Irfan Lone on 1/12/15.
//  Copyright (c) 2015 Irfan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransportResponseObject : NSObject
@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSHTTPURLResponse *response;
@property (strong, nonatomic) NSError *error;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error NS_DESIGNATED_INITIALIZER;
@end

@interface Transport : NSObject

- (void)retrieve:(NSURLRequest *)urlRequest completionBlock:(void (^)(BOOL success, TransportResponseObject *responseObject))completionBlock;

@end
