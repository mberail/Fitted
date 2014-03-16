//
//  PassViewController.h
//  Fitted
//
//  Created by Maxime Berail on 03/03/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PassViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageEmail;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

- (IBAction)getPassword:(id)sender;
@end
