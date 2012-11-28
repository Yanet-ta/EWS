//
//  XMLHandler.h
//  EWSClient
//
//  Created by Suraeva Yana on 21.11.12.
//  Copyright (c) 2012 Сураева Яна. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "Folder.h"
#import "Mail.h"

@interface XMLHandler : NSObject

+ (NSData *) XMLRequestGetFolderWithID:(NSString *)folderID;
+ (NSData *) XMLRequestGetFolderWithDistinguishedID:(NSString *)distinguishedFolderId;
+ (NSData *) XMLRequestGetItemWithID:(NSString *)itemID;
+ (NSData *) XMLRequestSyncItemsInFolderWithID:(NSString *)folderID usingSyncState:(NSString *)syncState;
+ (NSData *) XMLRequestSyncFolderHierarchyUsingSyncState:(NSString *)syncState;
+ (NSData *) XMLRequestFindFoldersInFolderWithID:(NSString *)folderID;
+ (NSData *) XMLRequestFindFoldersInFolderWithDistinguishedID:(NSString *)distinguishedFolderID;
+ (NSData *) XMLRequestFindItemsInFolderWithID:(NSString *)folderID;
+ (NSData *) XMLRequestFindItemsInFolderWithDistinguishedID:(NSString *)distinguishedFolderID;

// обработка ответов
+ (Folder *) objectForFolderXML:(GDataXMLElement *)folderXML;
+ (NSDictionary *) dictionaryForMailboxXML:(GDataXMLElement *)mailboxXML; 
+ (Mail *) objectForMessageXML:(GDataXMLElement *)messageXML;

@end

