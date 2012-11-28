//
//  Folder.h
//  EWSClient
//
//  Created by Suraeva Yana on 27.11.12.
//  Copyright (c) 2012 Сураева Яна. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Folder : NSObject{
    NSString *folderID;
    NSString *parentFolderID;
    NSString *displayName;
}

@property (nonatomic, retain) NSString *folderID;
@property (nonatomic, retain) NSString *parentFolderID;
@property (nonatomic, retain) NSString *displayName;

@end
