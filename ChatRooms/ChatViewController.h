//
//  ChatViewController.h
//  ChatRooms
//
//  Created by Nestor Zepeda on 11/29/14.
//  Copyright (c) 2014 Nestor Zepeda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import <Parse/Parse.h>

@interface ChatViewController : JSQMessagesViewController <JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout>

@property (strong, nonatomic) PFObject *chatroom;
@property (strong, nonatomic) NSString *chatRoomTitle;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@end
