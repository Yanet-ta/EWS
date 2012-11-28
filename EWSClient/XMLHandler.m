//
//  XMLHandler.m
//  EWSClient
//
//  Created by Suraeva Yana on 21.11.12.
//  Copyright (c) 2012 Сураева Яна. All rights reserved.
//
#import "XMLHandler.h"
#import "GDataXMLNode.h"


@implementation XMLHandler

// обработка ответов

+ (Folder *) objectForFolderXML:(GDataXMLElement *)folderXML {
    NSLog(@"objectForFolderXML called");
    
    GDataXMLElement *folderIDXML = [[folderXML elementsForName:@"t:FolderId"] objectAtIndex:0];
    Folder *result = [[Folder alloc] init];
    result.folderID = [[folderIDXML attributeForName:@"Id"] stringValue];
    
    GDataXMLElement *parentFolderIDXML = [[folderXML elementsForName:@"t:ParentFolderId"] objectAtIndex:0];
    result.parentFolderID = [[parentFolderIDXML attributeForName:@"Id"] stringValue];
    
    result.displayName = [[[folderXML elementsForName:@"t:DisplayName"] objectAtIndex:0] stringValue];
    
    return result;
}

+ (NSDictionary *) dictionaryForMailboxXML:(GDataXMLElement *)mailboxXML {
    NSLog(@"dictionaryForMailboxXML called");
    
    NSString *name = [[[mailboxXML elementsForName:@"t:Name"] objectAtIndex:0] stringValue];
    NSString *email = [[[mailboxXML elementsForName:@"t:EmailAddress"] objectAtIndex:0] stringValue];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:name, @"Name", email, @"EmailAddress", nil];
}

+ (Mail *) objectForMessageXML:(GDataXMLElement *)messageXML {
    NSLog(@"objectForMessageXML called");
    
    GDataXMLElement *itemIDXML = [[messageXML elementsForName:@"t:ItemId"] objectAtIndex:0];
    Mail *result = [[Mail alloc] init];
    result.itemID= [[itemIDXML attributeForName:@"Id"] stringValue];
    
    GDataXMLElement *parentFolderIDXML = [[messageXML elementsForName:@"t:ParentFolderId"] objectAtIndex:0];
    result.parentFolderID = [[parentFolderIDXML attributeForName:@"Id"] stringValue];
    result.subject = [[[messageXML elementsForName:@"t:Subject"] objectAtIndex:0] stringValue];
    
    GDataXMLElement *bodyXML = [[messageXML elementsForName:@"t:Body"] objectAtIndex:0];
    result.body = [bodyXML stringValue];
    result.bodyType = [[bodyXML attributeForName:@"t:BodyType"] stringValue];

    GDataXMLElement *toRecipientsXML = [[messageXML elementsForName:@"t:ToRecipients"] objectAtIndex:0];
    NSArray *recipientsXML = [toRecipientsXML elementsForName:@"t:Mailbox"];
    result.recipients = [NSMutableArray array];
    for (GDataXMLElement *singleRecipientXML in recipientsXML)
        [result.recipients addObject:[self dictionaryForMailboxXML:singleRecipientXML]];
    
    GDataXMLElement *senderXML = [[messageXML elementsForName:@"t:From"] objectAtIndex:0];
    GDataXMLElement *senderMailboxXML = [[senderXML elementsForName:@"t:Mailbox"] objectAtIndex:0];
    result.sender = [self dictionaryForMailboxXML:senderMailboxXML];
    
    return result;
}

// генерация запросов

+ (NSData *) XMLRequestGetFolderWithID:(NSString *)folderID {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <GetFolder xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <FolderShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </FolderShape>\
                        <FolderIds>\
                        <t:FolderId Id=\"%@\"/>\
                        </FolderIds>\
                        </GetFolder>\
                        </soap:Body>\
                        </soap:Envelope>", folderID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *) XMLRequestGetFolderWithDistinguishedID:(NSString *)distinguishedFolderId {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <GetFolder xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <FolderShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </FolderShape>\
                        <FolderIds>\
                        <t:DistinguishedFolderId Id=\"%@\"/>\
                        </FolderIds>\
                        </GetFolder>\
                        </soap:Body>\
                        </soap:Envelope>", distinguishedFolderId];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *) XMLRequestGetItemWithID:(NSString *)itemID {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope\
                        xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\
                        xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"\
                        xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <GetItem\
                        xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <ItemShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        <t:IncludeMimeContent>true</t:IncludeMimeContent>\
                        </ItemShape>\
                        <ItemIds>\
                        <t:ItemId Id=\"%@\"/>\
                        </ItemIds>\
                        </GetItem>\
                        </soap:Body>\
                        </soap:Envelope>", itemID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *) XMLRequestSyncItemsInFolderWithID:(NSString *)folderID usingSyncState:(NSString *)syncState {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <SyncFolderItems xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\">\
                        <ItemShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </ItemShape>\
                        <SyncFolderId>\
                        <t:FolderId Id=\"%@\"/>\
                        </SyncFolderId>\
                        <SyncState>%@</SyncState>\
                        <Ignore>\
                        </Ignore>\
                        <MaxChangesReturned>100</MaxChangesReturned>\
                        </SyncFolderItems>\
                        </soap:Body>\
                        </soap:Envelope>", folderID, syncState ? syncState : @""];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *) XMLRequestSyncFolderHierarchyUsingSyncState:(NSString *)syncState {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <SyncFolderHierarchy  xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\">\
                        <FolderShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </FolderShape>\
                        <SyncState>%@</SyncState>\
                        </SyncFolderHierarchy>\
                        </soap:Body>\
                        </soap:Envelope>", syncState ? syncState : @""];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *) XMLRequestFindFoldersInFolderWithID:(NSString *)folderID {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <FindFolder Traversal=\"Shallow\" xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\">\
                        <FolderShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </FolderShape>\
                        <ParentFolderIds>\
                        <t:FolderId Id=\"%@\"/>\
                        </ParentFolderIds>\
                        </FindFolder>\
                        </soap:Body>\
                        </soap:Envelope>", folderID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *) XMLRequestFindFoldersInFolderWithDistinguishedID:(NSString *)distinguishedFolderID {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <FindFolder Traversal=\"Shallow\" xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\">\
                        <FolderShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </FolderShape>\
                        <ParentFolderIds>\
                        <t:DistinguishedFolderId Id=\"%@\"/>\
                        </ParentFolderIds>\
                        </FindFolder>\
                        </soap:Body>\
                        </soap:Envelope>", distinguishedFolderID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *) XMLRequestFindItemsInFolderWithID:(NSString *)folderID {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <FindItem xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\"\
                        Traversal=\"Shallow\">\
                        <ItemShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </ItemShape>\
                        <ParentFolderIds>\
                        <t:FolderId Id=\"%@\"/>\
                        </ParentFolderIds>\
                        </FindItem>\
                        </soap:Body>\
                        </soap:Envelope>", folderID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *) XMLRequestFindItemsInFolderWithDistinguishedID:(NSString *)distinguishedFolderID {
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                        <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\
                        <soap:Body>\
                        <FindItem xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\
                        xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\"\
                        Traversal=\"Shallow\">\
                        <ItemShape>\
                        <t:BaseShape>AllProperties</t:BaseShape>\
                        </ItemShape>\
                        <ParentFolderIds>\
                        <t:DistinguishedFolderId Id=\"%@\"/>\
                        </ParentFolderIds>\
                        </FindItem>\
                        </soap:Body>\
                        </soap:Envelope>", distinguishedFolderID];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@end

