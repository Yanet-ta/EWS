//
//  Mail.h
//  EWSClient
//
//  Created by Suraeva Yana on 27.11.12.
//  Copyright (c) 2012 Сураева Яна. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Mail : NSObject{
    NSString *itemID;
    NSString *parentFolderID;
    NSString *subject;
    NSString *body;
    NSString *bodyType;
    NSMutableArray *recipients;
    NSDictionary *sender;
}

@property (nonatomic, retain) NSString *itemID;
@property (nonatomic, retain) NSString *parentFolderID;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *bodyType;
@property (nonatomic, retain) NSMutableArray *recipients;
@property (nonatomic, retain) NSDictionary *sender;

@end


