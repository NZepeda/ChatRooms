//
//  SignUpViewController.m
//  ChatRooms
//
//  Created by Nestor Zepeda on 11/18/14.
//  Copyright (c) 2014 Nestor Zepeda. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.usernameTextField resignFirstResponder];
    
    
    
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
- (IBAction)signUpButtonPressed:(UIButton *)sender
{
    [self checkFields];
}

#pragma mark - Helper methods

-(void)checkFields //check to see if all fields are filled out
{
    if([self.usernameTextField.text isEqualToString:@""] || [self.emailTextField.text isEqualToString:@""]
        || [self.passwordTextField.text isEqualToString:@""] || [self.confirmPasswordTextField.text isEqualToString:@""]){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning!" message:@"Fields cannot be blank!" delegate:nil cancelButtonTitle:@"Fuck" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
    else{
        [self checkPasswords];
    }

    
}

-(void)checkPasswords
{
    if([self.passwordTextField.text isEqualToString: self.confirmPasswordTextField.text]){
        
        [self signupUser];
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Passwords do not match" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)signupUser
{
    PFUser *newUser = [PFUser user];
    newUser.username = [self.usernameTextField.text lowercaseString];
    newUser.password = self.passwordTextField.text;
    newUser.email = self.emailTextField.text;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"AWESOME" message:@"Check parse to see if you signed up properly :)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];

    
    
}

#pragma mark - Methods for dismissing keyboard
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
