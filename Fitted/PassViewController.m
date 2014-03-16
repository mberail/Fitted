//
//  PassViewController.m
//  Fitted
//
//  Created by Maxime Berail on 03/03/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import "PassViewController.h"

@interface PassViewController ()

@end

@implementation PassViewController
@synthesize emailTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customNavigationBar];
    [emailTextField becomeFirstResponder];
	// Do any additional setup after loading the view.
}

#pragma mark - Custom Navigation Bar

- (void)customNavigationBar
{
    self.navigationController.navigationBar.translucent = NO;
	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"HEADER-.png"] forBarMetrics:UIBarMetricsDefault];
    
    UIImage *back = [UIImage imageNamed:@"BOUTON RETOUR.png"];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, back.size.width, back.size.height)];
    [backButton setBackgroundImage:back forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(previousView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)previousView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getPassword:(id)sender
{
    
}

#pragma mark - Text field delegate

- (BOOL)imageTextField:(UITextField *)textField replacementString:(NSString *)newString
{
    if (newString.length == 0)
    {
        self.imageEmail.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE.png"];
    }
    else
    {
        NSString *expression = @"[\\w-_.]{1,30}@[\\w-_.]{1,30}\\.[a-z]{2,6}";
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
        NSRange rangeNewMatch = [regex rangeOfFirstMatchInString:newString options:0 range:NSMakeRange(0, newString.length)];
        NSRange rangeOldMatch = [regex rangeOfFirstMatchInString:textField.text options:0 range:NSMakeRange(0, textField.text.length)];
        if (!NSEqualRanges(rangeNewMatch, NSMakeRange(NSNotFound, 0)))
        {
            self.imageEmail.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE PRET A VALIDER.png"];
            if (NSEqualRanges(rangeNewMatch, rangeOldMatch))
            {
                return NO;
            }
        }
        else
        {
            self.imageEmail.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE ERREUR.png"];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = nil;
    if (string.length == 0)
    {
        newString = [textField.text substringWithRange:NSMakeRange(0, textField.text.length-1)];
    }
    else
    {
        newString = [textField.text stringByAppendingString:string];
    }
    return [self imageTextField:textField replacementString:newString];
}

@end
