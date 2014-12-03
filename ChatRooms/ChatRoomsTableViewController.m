//
//  ChatRoomsTableViewController.m
//  ChatRooms
//
//  Created by Nestor Zepeda on 11/18/14.
//  Copyright (c) 2014 Nestor Zepeda. All rights reserved.
//

#import "ChatRoomsTableViewController.h"
#import "ViewController.h"
#import <Parse/Parse.h>
#import "ChatViewController.h"

@interface ChatRoomsTableViewController ()

@property (strong, nonatomic) NSMutableArray *chatrooms;

@end

@implementation ChatRoomsTableViewController

-(NSMutableArray *)chatrooms
{
    if(!_chatrooms){
        _chatrooms = [[NSMutableArray alloc]init];
    }
    
    return _chatrooms;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self.navigationController.delegate;

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Views

-(void)setupView
{
    //query for all the available chatrooms
    PFQuery *chatRoomQuery = [PFQuery queryWithClassName:@"Chatroom"];
    //chatRoomQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    
    //get all available chatrooms
    [chatRoomQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            
            //store the chatrooms found in our own array
            self.chatrooms = [objects mutableCopy];
            [self.tableView reloadData];
        }
        else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.chatrooms count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *chatRoom = self.chatrooms[indexPath.row]; //this object includes the list of the users in that chat...
    cell.textLabel.text = chatRoom[@"roomName"]; //make the text of the cell to the name of the chat room

    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.destinationViewController isKindOfClass:[ChatViewController class]]){
        
        ChatViewController *chatVC = segue.destinationViewController;
        NSIndexPath *indexpath = [self.tableView indexPathForSelectedRow];
        
        //passes the title of the chatroom and the chatroom object itself to the chat view controller
        chatVC.chatRoomTitle = self.chatrooms[indexpath.row][@"roomName"];
        chatVC.chatroom = self.chatrooms[indexpath.row];

        
    }
}


#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"chatListToChat" sender:indexPath];
}

#pragma mark - IBActions

//used to logout
- (IBAction)logoutButtonPressed:(UIBarButtonItem *)sender
{
    [self.delegate logoutSuccessful];
}
- (IBAction)addChatRoomButtonPressed:(UIBarButtonItem *)sender
{
    UIAlertView *newChatRoomAlertView = [[UIAlertView alloc]initWithTitle:@"Enter name for new Chatroom" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    [newChatRoomAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [newChatRoomAlertView show];
    
}

#pragma mark - UIAlertViewDelegate
//Inserts new items into to the table when the user clicks Add on the alert view
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *alertText = [alertView textFieldAtIndex:0].text;
        
        PFObject *newChatRoom = [PFObject objectWithClassName:@"Chatroom"];
        [newChatRoom setObject:alertText forKey:@"roomName"];
        [newChatRoom setObject:[NSArray arrayWithObject:[PFUser currentUser].objectId] forKey:@"users"];
        
        [newChatRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.chatrooms addObject:newChatRoom];
            [self.tableView reloadData];
        }];
        
        
    }
}
@end
