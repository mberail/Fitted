//
//  LoginViewController.h
//  Fitted
//
//  Created by Maxime Berail on 03/01/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageEmail;
@property (weak, nonatomic) IBOutlet UIImageView *imagePass;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;

- (IBAction)login:(id)sender;
- (IBAction)forgottenPassword:(id)sender;
- (IBAction)facebookLogin:(id)sender;

@end
