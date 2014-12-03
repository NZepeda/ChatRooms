//
//  LoginViewController.h
//  ChatRooms
//
//  Created by Nestor Zepeda on 11/18/14.
//  Copyright (c) 2014 Nestor Zepeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate <NSObject>

-(void)loginSuccessful;

@end

@interface LoginViewController : UIViewController

@property (weak, nonatomic) id <LoginViewControllerDelegate> delegate;

@end
