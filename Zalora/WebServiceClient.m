//
//  WebServiceClient.m
//  Zalora
//
//  Created by Ulaş Sancak on 11/09/15.
//  Copyright (c) 2015 Ulaş Sancak. All rights reserved.
//

#import "WebServiceClient.h"

#define BASE_URL @"https://www.zalora.com.my/mobile-api/women/clothing"

static WebServiceClient *client;

typedef void(^WebServiceCompletionBlock)(id responseObject, NSError *error);

@implementation WebServiceClient

+(WebServiceClient *)client{
    if (!client) {
        client = [[WebServiceClient alloc] init];
    }

    return client;
}

#pragma mark - Web Service Client Methods

- (void)getProductsWithMaxItemNumber:(NSUInteger)maxItemNumber withPageNumber:(NSUInteger)pageNumber withSortType:(NSString *)sortType withDirection:(NSString *)direction withCompletionBlock:(WebServiceClientCompletionBlock)completionBlock {
    NSString *urlString = BASE_URL;
    NSDictionary *parameters = @{@"maxitems" : @(maxItemNumber), @"page" : @(pageNumber), @"sort" : sortType, @"dir" : direction};
    [self getFromURL:urlString withParameters:parameters withCompletionBlock:^(id responseObject, NSError *error) {
        NSDictionary *dictionary;
        if (!error) {
            dictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        }
        completionBlock(dictionary, error);
    }];
}

- (void)getProductDetailWithURL:(NSString *)URL withCompletionBlock:(WebServiceClientCompletionBlock)completionBlock {
    [self getFromURL:URL withParameters:nil withCompletionBlock:^(id responseObject, NSError *error) {
        NSDictionary *dictionary;
        if (!error) {
            dictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        }
        completionBlock(dictionary, error);
    }];
}

#pragma mark - AFNetworking Methods

- (void)getFromURL:(NSString *)urlString withParameters:(NSDictionary *)parameters withCompletionBlock:(WebServiceCompletionBlock)completionBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
}

-(void)cancelOperation{
    if (_operation.isExecuting) {
        [_operation cancel];
    }
}
@end
