//
//  ConnectionManager.m
//  EWSClient
//
//  Created by Suraeva Yana on 26.11.12.
//  Copyright (c) 2012 Сураева Яна. All rights reserved.
//

#import "ConnectionManager.h"


@interface ConnectionManager () {
    NSMutableData *_recievedData;
    NSURLCredential *_credential;
}

@end

@implementation ConnectionManager

@synthesize delegate = _delegate;

- (void) dealloc {
    [_credential release];
    [_recievedData release];
    
    [super dealloc];
}

- (id) initWithDelegate:(id<ConnectionManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    
    return self;
}

// Отправка xml-запроса
- (void) sendRequestToServer:(NSURL *)serverURL withCredential:(NSURLCredential *)credential withBody:(NSData *)bodyData
{
    NSLog(@"sendRequest called");
    
    _credential = [credential retain];
    
    _recievedData = [[NSMutableData alloc] init];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serverURL];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:bodyData];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection == nil)
        NSLog(@"Connection cannot be created");
}

// Методы NSURLConnectionDelegate
- (void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"authentification challenge recieved");
    
    [[challenge sender] useCredential:_credential forAuthenticationChallenge:challenge];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection error: %@", [error localizedDescription]);
}

- (void) connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"Authentification error");
}

- (void) connection:(NSURLConnection *)connection didRecieveResponse:(NSURLResponse *) response {
    NSLog(@"Response recieved");
    
    [_recievedData setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"data recived");
    
    [_recievedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connection did finish loading");
    
    [self.delegate connectionManager:self didFinishLoadingData:_recievedData];
    
    _recievedData = nil;
}

@end
