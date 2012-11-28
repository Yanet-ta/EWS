//
//  ViewController.m
//  EWSClient
//
//  Created by Suraeva Yana on 21.11.12.
//  Copyright (c) 2012 Сураева Яна. All rights reserved.
//

#import "ViewController.h"
#import "RequestHandler.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    self.title = @"Login";
    RequestHandler *requestHandlerInstance = [[RequestHandler alloc] initWithServerURL:
                                              [NSURL URLWithString:@"https://mail.digdes.com/ews/exchange.asmx"]
                                                                            withUserName:@"sed"
                                                                            withUserPassword:@"P@ssw0rd"
                                                                            withDelegate:self];
    [requestHandlerInstance syncFolderHierarchyUsingSyncState:nil];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) requestHandler:(RequestHandler *)handler didFinishLoadingFolder:(Folder *)folder{
    NSLog(@"%@",folder);
}

- (void) requestHandler:(RequestHandler *)handler didFinishLoadingMessage:(Mail *)message{
    NSLog(@"%@",message.subject);
}

- (void) requestHandler:(RequestHandler *)handler didFinishLoadingFolders:(NSArray *)folders{
    NSLog(@"%@",folders);
}

- (void) requestHandler:(RequestHandler *)handler didFinishLoadingItems:(NSArray *)items{
    NSLog(@"%@",items);
}

- (void) requestHandler:(RequestHandler *)handler didFinishLoadingItemsToSync:(NSDictionary *)itemsToSync{
    NSLog(@"%@",itemsToSync);
}

- (void) requestHandler:(RequestHandler *)handler didFinishLoadingFoldersToSync:(NSDictionary *)foldersToSync{
    NSLog(@"%@",foldersToSync);
}


@end
