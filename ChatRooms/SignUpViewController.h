//
//  SignUpViewController.h
//  ChatRooms
//
//  Created by Nestor Zepeda on 11/18/14.
//  Copyright (c) 2014 Nestor Zepeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignUpViewControllerDelegate <NSObject>

-(void)signUpSuccessful;

@end

@interface SignUpViewController : UIViewController

@property (weak, nonatomic) id <SignUpViewControllerDelegate> delegate;

@end
