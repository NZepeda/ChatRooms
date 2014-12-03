//
//  HolderViewController.m
//  ChatRooms
//
//  Created by Nestor Zepeda on 11/27/14.
//  Copyright (c) 2014 Nestor Zepeda. All rights reserved.
//

#import "HolderViewController.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface HolderViewController ()

@end

@implementation HolderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //checks if user is logged in, if not redirects them to the login page
    if([PFUser currentUser] == nil){
        [self performSegueWithIdentifier:@"HolderToLogin" sender:nil];
    }
    else{
        NSLog(@"going into chat rooms!");
        [self performSegueWithIdentifier:@"HolderToChatRooms" sender:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.
    
    if([segue.destinationViewController isKindOfClass:[UINavigationController class]]){
        NSLog(@"In prepare for segue!");
        ChatRoomsTableViewController *chatVC = segue.destinationViewController;
        chatVC.delegate = self;
    }
}



#pragma mark - Chat Rooms VC delegate methods

-(void)logoutSuccessful
{
    [PFUser logOut];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}



@end
