//
//  ConnectionManager.h
//  EWSClient
//
//  Created by Suraeva Yana on 26.11.12.
//  Copyright (c) 2012 Сураева Яна. All rights reserved.
//  Working with connection

#import <Foundation/Foundation.h>

@protocol ConnectionManagerDelegate;


@interface ConnectionManager : NSObject <NSURLConnectionDelegate>

@property (nonatomic, assign) id <ConnectionManagerDelegate> delegate;

- (id) initWithDelegate:(id<ConnectionManagerDelegate>)delegate;
- (void) sendRequestToServer:(NSURL *)serverURL withCredential:(NSURLCredential *)credential withBody:(NSData *)bodyData;

@end

@protocol ConnectionManagerDelegate <NSObject>

- (void) connectionManager:(ConnectionManager *)manager didFinishLoadingData:(NSData *)data;

@end


