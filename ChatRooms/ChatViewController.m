//
//  ChatViewController.m
//  ChatRooms
//
//  Created by Nestor Zepeda on 11/29/14.
//  Copyright (c) 2014 Nestor Zepeda. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@property (strong, nonatomic) PFUser *currentUser; //stores info from the user thats logged in
@property (strong, nonatomic) NSMutableArray *messagesFromChatArray; //stores the chat activity objects retrieved from parse
@property (strong, nonatomic) NSMutableArray *messages; //holds the JSQMessages objects (this are the ones actaully displayed)
@property (strong, nonatomic) NSMutableArray *usersInChat; //stores user objects that are in the chat

@property (strong, nonatomic) NSMutableDictionary *chatters; //holds key pair valus of the users (object id, username)

//temp arrays
@property (strong, nonatomic) NSMutableArray *stringObjectIds; //holds the string object of the object id (used for querying)

@property (nonatomic) BOOL initialLoadComplete;
@property (strong, nonatomic) NSTimer *chatsTimer; //to constantly check fore new messages

@end

@implementation ChatViewController

//initialize our arrays

-(NSMutableDictionary *)chatters{
    if(!_chatters){
        _chatters = [[NSMutableDictionary alloc]init];
    }
    return _chatters;
}

-(NSMutableArray *)messages
{
    if(!_messages){
        _messages = [[NSMutableArray alloc]init];
    }
    return _messages;
}

-(NSMutableArray *)usersInChat
{
    if(!_usersInChat){
        _usersInChat = [[NSMutableArray alloc]init];
    }
    return _usersInChat;
}

-(NSMutableArray *)stringObjectIds
{
    if(!_stringObjectIds){
        _stringObjectIds = [[NSMutableArray alloc]init];
    }
    return _stringObjectIds;
}
-(NSMutableArray *)messagesFromChatArray
{
    if(!_messagesFromChatArray){
        _messagesFromChatArray = [[NSMutableArray alloc]init];
    }
    return _messagesFromChatArray;
}

//this method runs first
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //sets up the bubbles
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    //Here you can customize what the bubbles look like
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleNestorsColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleRedColor]];
    
    //set the title of view to the name of the chatroom
    [self setTitle:self.chatRoomTitle];
    
    //go into set up (sets up the view properly)
    [self setup];
    
    //checks for new messages
    [self checkForNewMessages];
    
    //constanly runs te check for new messages method (every 5 seceonds)((this can be adjusted to whatever time))
    self.chatsTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkForNewMessages) userInfo:nil repeats:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setup
{
    self.currentUser = [PFUser currentUser];
    
    //set the sender id and display name to the user currently logged in
    self.senderId = self.currentUser.objectId;
    self.senderDisplayName = self.currentUser.username;

    //shows no avatar for messages
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    //show load earlier messages thing at top
    self.showLoadEarlierMessagesHeader = YES;

    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    
    //create a JSQMessage object
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    //add it to parse
    if(message.text != 0){
        
        PFObject *chat = [PFObject objectWithClassName:@"ChatActivity"];
        [chat setObject:self.chatroom forKey:@"chatroom"];
        [chat setObject:self.currentUser forKey:@"fromUser"];
        [chat setObject:message.text forKey:@"text"];
        
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //add the message to the array
            [self.messages addObject:message];
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            [self.collectionView reloadData];
            [self finishSendingMessage];
            [self scrollToBottomAnimated:YES];
        }];
    }
    
    
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return [self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //return nil if you don't want bubbles
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //return nil if you don't want avatars
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return self.messages.count;
    
}


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];


    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Check for new messages
//This is the method that does most of the work
-(void)checkForNewMessages
{
    //first clears the arrays so that we don't have double messages
    [self.messages removeAllObjects];
    [self.messagesFromChatArray removeAllObjects];
    [self.usersInChat removeAllObjects];
    [self.stringObjectIds removeAllObjects];

    //Load messages from parse
    PFQuery *queryForMessages = [PFQuery queryWithClassName:@"ChatActivity"]; //query the chat activity class from parse
    
    //only get back the messages belonging to the chatroom that we're currently in
    [queryForMessages whereKey:@"chatroom" equalTo: self.chatroom];
    [queryForMessages orderByAscending:@"createdAt"];
    [queryForMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            
            //store objects retreived into our own array
            self.messagesFromChatArray = [objects mutableCopy];
            
            //store the object id in string form (used for our next query)
            for(int i = 0; i < self.messagesFromChatArray.count; i++){
                [self.stringObjectIds addObject:((PFUser *)self.messagesFromChatArray[i][@"fromUser"]).objectId];
            }
            
            
            //queries for users participating in that chat room
            PFQuery *queryForUserIds = [PFQuery queryWithClassName:@"_User"];
            [queryForUserIds whereKey:@"objectId" containedIn:self.stringObjectIds];
            
            [queryForUserIds findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if(!error){
                    self.usersInChat = [objects mutableCopy];
                    
                    //store those users in a dictionary for (key-value pairs)
                    for(int i = 0; i < self.usersInChat.count; i++)
                    {
                        [self.chatters setObject:((PFUser *)self.usersInChat[i]).username forKey:((PFUser *)self.usersInChat[i]).objectId];
                    }
                    
                    
                    for(int i = 0; i < self.messagesFromChatArray.count; i++){
                        
                        //convert all the messages from parse into JSQMessage objects and store them in an array
                        //These are the objects used to actually display in our chat
                        
                        [self.messages addObject: [[JSQMessage alloc]initWithSenderId: ((PFUser *)self.messagesFromChatArray[i][@"fromUser"]).objectId
                                                                    senderDisplayName:self.chatters[((PFUser *)self.messagesFromChatArray[i][@"fromUser"]).objectId]
                                                                                 date:[NSDate date]
                                                                                 text:self.messagesFromChatArray[i][@"text"]]];
                    }
                    
                }
                
                [self.collectionView reloadData];
                self.initialLoadComplete = YES;
                [self scrollToBottomAnimated:YES];
            }];
            
        }
    }];
    
}



@end
