//
//  WebServiceClient.h
//  Zalora
//
//  Created by Ulaş Sancak on 11/09/15.
//  Copyright (c) 2015 Ulaş Sancak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void(^WebServiceClientCompletionBlock)(NSDictionary *dictionary, NSError *error);

@class WebServiceClient;

@protocol WebServiceClientDelegate <NSObject>

@optional

- (void)webServiceClient:(WebServiceClient *)client didReturnResponse:(NSMutableDictionary *)response withError:(NSError *)error;

@end

@interface WebServiceClient : NSObject

@property (assign, nonatomic) NSUInteger tag;
@property (strong, nonatomic) AFHTTPRequestOperation *operation;
@property (weak, nonatomic) id <WebServiceClientDelegate> delegate;

+(WebServiceClient *)client;

- (void)getProductsWithMaxItemNumber:(NSUInteger)maxItemNumber withPageNumber:(NSUInteger)pageNumber withSortType:(NSString *)sortType withDirection:(NSString *)direction withCompletionBlock:(WebServiceClientCompletionBlock)completionBlock;

- (void)getProductDetailWithURL:(NSString *)URL withCompletionBlock:(WebServiceClientCompletionBlock)completionBlock;

@end
