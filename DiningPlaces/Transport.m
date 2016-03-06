//
//  Transport.m
//  
//
//  Created by Irfan Lone on 1/12/15.
//  Copyright (c) 2015 Irfan. All rights reserved.
//

#import "Transport.h"

@implementation TransportResponseObject

- (instancetype)initWithData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error {
    if (self = [super init]) {
        self.data = data;
        self.response = response;
        self.error = error;
    }
    return self;
}

@end


@implementation Transport

- (void)retrieve:(NSURLRequest *)urlRequest completionBlock:(void (^)(BOOL success, TransportResponseObject *responseObject))completionBlock
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        TransportResponseObject *responseObject = [[TransportResponseObject alloc] initWithData:data response:httpResponse error:error];
        NSInteger responseStatusCode = httpResponse.statusCode;
        if (error == nil && (responseStatusCode >= 200 && responseStatusCode <= 299)) {
            completionBlock(YES, responseObject);
        } else {
            completionBlock(NO, responseObject);
        }
    }];
    [dataTask resume];
    [session finishTasksAndInvalidate];
}


@end
