//
//  LoginViewController.m
//  ChatRooms
//
//  Created by Nestor Zepeda on 11/18/14.
//  Copyright (c) 2014 Nestor Zepeda. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "ChatRoomsTableViewController.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;

@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)loginButtonPressed:(UIButton *)sender
{

        [PFUser logInWithUsernameInBackground:[self.usernameTextField.text lowercaseString] password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
            if(!error){
                NSString *name = user.username;
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Awesome" message:[NSString stringWithFormat:@"You logged in as %@", name]
                                                              delegate:nil
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil, nil];
                [alert show];
                
                [self.delegate loginSuccessful];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Your log in credentials were incorrect. Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];

}

@end
