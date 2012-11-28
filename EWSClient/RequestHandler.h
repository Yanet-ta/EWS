//
//  RequestHandler.h
//  EWSClient
//
//  Created by Suraeva Yana on 26.11.12.
//  Copyright (c) 2012 Сураева Яна. All rights reserved.
//  Set up request settings

#import <Foundation/Foundation.h>
#import "ConnectionManager.h"
#import "Folder.h"
#import "Mail.h"

@protocol RequestHandlerDelegate;

@interface RequestHandler : NSObject <ConnectionManagerDelegate>

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userPassword;
@property (nonatomic, retain) NSURL *serverURL;
@property (nonatomic,assign) id <RequestHandlerDelegate> delegate;

- (id) initWithServerURL:(NSURL *)serverURL withUserName:(NSString *)userName withUserPassword:(NSString *)userPassword withDelegate:(id<RequestHandlerDelegate>)delegate;
//получение ID папки
- (void) getFolderWithID:(NSString *)folderID;
//получение "смыслового" ID папки
- (void) getFolderWithDistinguishedID:(NSString *)distinguishedFolderID;
- (void) getItemWithID:(NSString *)itemID;
// Получение изменений содержимого папки
- (void) syncItemsInFolderWithID:(NSString *)folderID usingSyncState:(NSString *)syncState;
// Получение изменений дерева папок
- (void) syncFolderHierarchyUsingSyncState:(NSString *)syncState;
// Получение дочерних папок от указанной папки
- (void) getFoldersInFolderWithID:(NSString *)folderID;
- (void) getFoldersInFolderWithDistinguishedID:(NSString *)distinguishedFolderID;
// Получение содержимого папки
- (void) getItemsInFolderWithID:(NSString *)folderID;
- (void) getItemsInFolderWithDistinguishedID:(NSString *)distinguishedFolderID;

@end

@protocol RequestHandlerDelegate <NSObject>
// закончили загружать папку
- (void) requestHandler:(RequestHandler *)handler didFinishLoadingFolder:(Folder *)folder;
// закончили загружать сообщение
- (void) requestHandler:(RequestHandler *)handler didFinishLoadingMessage:(Mail *)message;
// закончили загружать папки (массив объектов Folder)
- (void) requestHandler:(RequestHandler *)handler didFinishLoadingFolders:(NSArray *)folders;
// закончили загружать элементы (сообщения)
- (void) requestHandler:(RequestHandler *)handler didFinishLoadingItems:(NSArray *)items;
// закончили загружать элементы, требующие синхронизации
- (void) requestHandler:(RequestHandler *)handler didFinishLoadingItemsToSync:(NSDictionary *)itemsToSync;
// закончили загружать папки, требующие синхронизации
- (void) requestHandler:(RequestHandler *)handler didFinishLoadingFoldersToSync:(NSDictionary *)foldersToSync;

@end
