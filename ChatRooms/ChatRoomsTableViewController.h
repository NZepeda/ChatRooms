//
//  ChatRoomsTableViewController.h
//  ChatRooms
//
//  Created by Nestor Zepeda on 11/18/14.
//  Copyright (c) 2014 Nestor Zepeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatRoomsTableViewControllerDelegate <NSObject>

-(void)logoutSuccessful;

@end

@interface ChatRoomsTableViewController : UITableViewController

@property (weak, nonatomic) id <ChatRoomsTableViewControllerDelegate> delegate;

@end
