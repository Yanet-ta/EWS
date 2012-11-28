//
//  RequestHandler.m
//  EWSClient
//
//  Created by Suraeva Yana on 26.11.12.
//  Copyright (c) 2012 Сураева Яна. All rights reserved.
//

#import "RequestHandler.h"
#import "XMLHandler.h"
#import "ConnectionManager.h"
#import "GDataXMLNode.h"

typedef enum {
    RequestHandlerCurrentOperationGetFolder,
    RequestHandlerCurrentOperationGetItem,
    RequestHandlerCurrentOperationSyncFolderItems,
    RequestHandlerCurrentOperationSyncFolderHierarchy,
    RequestHandlerCurrentOperationFindFolder,
    RequestHandlerCurrentOperationFindItem
} RequestHandlerCurrentOperation;

@interface RequestHandler () {
    RequestHandlerCurrentOperation _currentOperation;
}

- (void) sendRequestWithBody:(NSData *)requestBody;

@end

@implementation RequestHandler

@synthesize serverURL = _serverURL;
@synthesize userName = _userName;
@synthesize userPassword = _userPassword;
@synthesize delegate = _delegate;

- (void) dealloc {
    self.serverURL = nil;
    self.userName = nil;
    self.userPassword = nil;
    
    [super dealloc];
}

- (id) initWithServerURL:(NSURL *)serverURL
            withUserName:(NSString *)userName
            withUserPassword:(NSString *)userPassword
            withDelegate:(id<RequestHandlerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _serverURL = [serverURL retain];
        _userName = [userName retain];
        _userPassword = [userPassword retain];
        _delegate = delegate;
    }
    
    return self;
}

- (void) sendRequestWithBody:(NSData *)requestBody {
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.userName
                                                             password:self.userPassword
                                                          persistence:NSURLCredentialPersistenceForSession];
    
    ConnectionManager *connection = [[ConnectionManager alloc] initWithDelegate:self];
    
    [connection sendRequestToServer:_serverURL withCredential:credential withBody:requestBody];
}

- (void) getFolderWithID:(NSString *)folderID {
    _currentOperation = RequestHandlerCurrentOperationGetFolder;
    
    [self sendRequestWithBody:[XMLHandler XMLRequestGetFolderWithID:folderID]];
}

- (void) getFolderWithDistinguishedID:(NSString *)distinguishedFolderID {
    _currentOperation = RequestHandlerCurrentOperationGetFolder;
    
    [self sendRequestWithBody:[XMLHandler XMLRequestGetFolderWithDistinguishedID:distinguishedFolderID]];
}

- (void) getItemWithID:(NSString *)itemID {
    _currentOperation = RequestHandlerCurrentOperationGetItem;
    
    [self sendRequestWithBody:[XMLHandler XMLRequestGetItemWithID:itemID]];
}

- (void) syncItemsInFolderWithID:(NSString *)folderID usingSyncState:(NSString *)syncState {
    _currentOperation = RequestHandlerCurrentOperationSyncFolderItems;
    
    [self sendRequestWithBody:[XMLHandler XMLRequestSyncItemsInFolderWithID:folderID usingSyncState:syncState]];
}

- (void) syncFolderHierarchyUsingSyncState:(NSString *)syncState {
    _currentOperation = RequestHandlerCurrentOperationSyncFolderHierarchy;
    
    [self sendRequestWithBody:[XMLHandler XMLRequestSyncFolderHierarchyUsingSyncState:syncState]];
}

- (void) getFoldersInFolderWithID:(NSString *)folderID {
    _currentOperation = RequestHandlerCurrentOperationFindFolder;
    
    [self sendRequestWithBody:[XMLHandler XMLRequestFindFoldersInFolderWithID:folderID]];
}

- (void) getFoldersInFolderWithDistinguishedID:(NSString *)distinguishedFolderID {
    _currentOperation = RequestHandlerCurrentOperationFindFolder;
    
    [self sendRequestWithBody:[XMLHandler
                               XMLRequestFindFoldersInFolderWithDistinguishedID:distinguishedFolderID]];
}

- (void) getItemsInFolderWithID:(NSString *)folderID {
    _currentOperation = RequestHandlerCurrentOperationFindItem;
    
    [self sendRequestWithBody:[XMLHandler XMLRequestFindItemsInFolderWithID:folderID]];
}

- (void) getItemsInFolderWithDistinguishedID:(NSString *)distinguishedFolderID {
    _currentOperation = RequestHandlerCurrentOperationFindItem;
    
    [self sendRequestWithBody:[XMLHandler
                               XMLRequestFindItemsInFolderWithDistinguishedID:distinguishedFolderID]];
}

- (void) connectionManager:(ConnectionManager *)manager didFinishLoadingData:(NSData *)data {
    NSLog(@"didFinishLoadingData starts");
    
    GDataXMLDocument *response = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    
    // вывод ответа сервера
    NSString *debugString = [NSString stringWithUTF8String:[data bytes]];
    NSLog(@"%@", debugString);
    
    NSDictionary *namespaces = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"http://schemas.microsoft.com/exchange/services/2006/messages", @"m",
                                @"http://schemas.microsoft.com/exchange/services/2006/types", @"t",
                                @"http://www.w3.org/2001/XMLSchema-instance", @"xsi",
                                @"http://www.w3.org/2001/XMLSchema", @"xsd",
                                @"http://schemas.xmlsoap.org/soap/envelope/", @"s", nil];
    
    NSString *getFolderResponseCode = [[[response nodesForXPath:@"//m:ResponseCode"
                                                     namespaces:namespaces
                                                          error:nil] objectAtIndex:0] stringValue];
    if ([getFolderResponseCode isEqualToString:@"NoError"]) {
        switch (_currentOperation) {
            case RequestHandlerCurrentOperationGetFolder: {
                GDataXMLElement *folderXML = [[response nodesForXPath:@"//t:Folder"
                                                           namespaces:namespaces
                                                                error:nil] objectAtIndex:0];
                
                [self.delegate requestHandler:self
                        didFinishLoadingFolder:[XMLHandler objectForFolderXML:folderXML]];
                break;
            }
                
            case RequestHandlerCurrentOperationGetItem: {
                GDataXMLElement *messageXML = [[response nodesForXPath:@"//t:Message"
                                                            namespaces:namespaces
                                                                 error:nil] objectAtIndex:0];
                
                [self.delegate requestHandler:self
                       didFinishLoadingMessage:[XMLHandler objectForMessageXML:messageXML]];
                break;
            }
                
            case RequestHandlerCurrentOperationSyncFolderItems: {
                NSMutableArray *messagesToCreate = [NSMutableArray array];
                NSArray *messagesToCreateXML = [response nodesForXPath:@"//t:Create/t:Message"
                                                            namespaces:namespaces
                                                                 error:nil];
                for (GDataXMLElement *currentMessage in messagesToCreateXML)
                    [messagesToCreate addObject:[XMLHandler objectForMessageXML:currentMessage]];
                
                NSMutableArray *messagesToUpdate = [NSMutableArray array];
                NSArray *messagesToUpdateXML = [response nodesForXPath:@"//t:Create/t:Message"
                                                            namespaces:namespaces
                                                                 error:nil];
                for (GDataXMLElement *currentMessage in messagesToUpdateXML)
                    [messagesToUpdate addObject:[XMLHandler objectForMessageXML:currentMessage]];
                
                NSMutableArray *messagesToDelete = [NSMutableArray array];
                NSArray *messagesToDeleteXML = [response nodesForXPath:@"//t:Create/t:Message"
                                                            namespaces:namespaces
                                                                 error:nil];
                for (GDataXMLElement *currentMessage in messagesToDeleteXML)
                    [messagesToDelete addObject:[XMLHandler objectForMessageXML:currentMessage]];
                
                NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:messagesToCreate, @"Create",
                                        messagesToUpdate, @"Update",
                                        messagesToDelete, @"Delete", nil];
                [self.delegate requestHandler:self didFinishLoadingItemsToSync:result];
                break;
            }
                
            case RequestHandlerCurrentOperationSyncFolderHierarchy: {
                NSArray *foldersToCreateXML = [response nodesForXPath:@"//t:Create/t:Folder"
                                                           namespaces:namespaces
                                                                error:nil];
                NSMutableArray *foldersToCreate = [NSMutableArray array];
                for (GDataXMLElement *currentFolder in foldersToCreateXML)
                    [foldersToCreate addObject:[XMLHandler objectForFolderXML:currentFolder]];
                
                NSArray *foldersToUpdateXML = [response nodesForXPath:@"//t:Create/t:Folder"
                                                           namespaces:namespaces
                                                                error:nil];
                NSMutableArray *foldersToUpdate = [NSMutableArray array];
                for (GDataXMLElement *currentFolder in foldersToUpdateXML)
                    [foldersToUpdate addObject:[XMLHandler objectForFolderXML:currentFolder]];
                
                NSArray *foldersToDeleteXML = [response nodesForXPath:@"//t:Create/t:Folder"
                                                           namespaces:namespaces
                                                                error:nil];
                NSMutableArray *foldersToDelete = [NSMutableArray array];
                for (GDataXMLElement *currentFolder in foldersToDeleteXML)
                    [foldersToDelete addObject:[XMLHandler objectForFolderXML:currentFolder]];
                
                NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:foldersToCreate, @"Create",
                                        foldersToUpdate, @"Update",
                                        foldersToDelete, @"Delete", nil];
                [self.delegate requestHandler:self didFinishLoadingFoldersToSync:result];
                break;
            }
                
            case RequestHandlerCurrentOperationFindFolder: {
                NSMutableArray *result = [NSMutableArray array];
                
                NSArray *folders = [response nodesForXPath:@"//t:Folder"
                                                namespaces:namespaces
                                                     error:nil];
                for (GDataXMLElement *currentFolder in folders) {
                    [result addObject:[XMLHandler objectForFolderXML:currentFolder]];
                }
                
                [self.delegate requestHandler:self didFinishLoadingFolders:result];
                break;
            }
                
            case RequestHandlerCurrentOperationFindItem: {
                NSMutableArray *result = [NSMutableArray array];
                
                NSArray *messages = [response nodesForXPath:@"//t:Message"
                                                 namespaces:namespaces
                                                      error:nil];
                for (GDataXMLElement *currentMessage in messages) {
                    [result addObject:[XMLHandler objectForMessageXML:currentMessage]];
                }
                
                [self.delegate requestHandler:self didFinishLoadingItems:result];
                break;
            }
                
            default: {
                NSLog(@"Wrong current operation code");
                break;
            }
        }
    }
    else {
        NSLog(@"Error response");
        NSLog(@"%@", [[[response nodesForXPath:@"//m:ResponseCode"
                                    namespaces:namespaces
                                         error:nil] objectAtIndex:0] stringValue]);
    }
    
    [manager release];
    [response release];
}

@end
