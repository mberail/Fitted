//
//  LoginViewController.m
//  Fitted
//
//  Created by Maxime Berail on 03/01/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import "LoginViewController.h"
#import "WebServices.h"
#import "AppDelegate.h"

@interface LoginViewController ()
{
    UIAlertView *waitingDialog;
    NSTimer *cancelTimer;
}
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSInteger userID = [[NSUserDefaults standardUserDefaults] integerForKey:@"id"];
    if (userID != 0)
    {
        [self startLoginProcessWithFacebook:NO];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customNavBar];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"email"] != nil)
    {
        self.emailTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
        [self imageTextField:self.emailTextField replacementString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
        self.passTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"pass"];
        [self imageTextField:self.passTextField replacementString:[[NSUserDefaults standardUserDefaults] objectForKey:@"pass"]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self dismissKeyboard];
}

#pragma mark - Custom NavigationBar

- (void)customNavBar
{
    self.navigationController.navigationBar.translucent = NO;
	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"HEADER-.png"] forBarMetrics:UIBarMetricsDefault];
    /*UIImage *profile = [UIImage imageNamed:@"BOUTON REGLAGE.png"];
    UIButton *profileButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, profile.size.width, profile.size.height)];
    [profileButton setBackgroundImage:profile forState:UIControlStateNormal];
    [profileButton addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *profilItem =[[UIBarButtonItem alloc] initWithCustomView:profileButton];
    self.navigationItem.rightBarButtonItem = profilItem;*/
}

- (void)settings
{
    
}

#pragma mark - Actions

- (IBAction)login:(id)sender
{
    [self proceedWithLogin];
}

- (IBAction)forgottenPassword:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)facebookLogin:(id)sender
{
    [self startLoginProcessWithFacebook:YES];
}

#pragma mark - Login delegate

- (void)proceedWithLogin
{
    NSString *expression = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:self.emailTextField.text options:0 range:NSMakeRange(0, self.emailTextField.text.length)];
    if (self.emailTextField.text.length == 0 || self.passTextField.text.length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Veuillez compléter tous les champs" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else if (!match)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Adresse e-mail invalide" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else
    {
        [self startLoginProcessWithFacebook:NO];
    }
}

- (void)startLoginProcessWithFacebook:(BOOL)loginFB
{
    waitingDialog = [[UIAlertView alloc] initWithTitle:@"Connexion en cours .." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [waitingDialog show];
    if (loginFB)
    {
        [self performSelector:@selector(loginFacebook) withObject:nil afterDelay:0.3];
    }
    else
    {
        [self performSelector:@selector(loginWebServices) withObject:nil afterDelay:0.3];
    }
    cancelTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(cancelRequest:) userInfo:nil repeats:NO];
}

- (void)loginFacebook
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:YES];
}

- (void)loginWebServices
{
    BOOL isConnected = [WebServices amIConnected];
    [cancelTimer invalidate];
    if (isConnected)
    {
        [waitingDialog dismissWithClickedButtonIndex:0 animated:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nvc animated:YES completion:nil];
    }
    else
    {
        NSArray *parameters = [[NSArray alloc] initWithObjects:self.emailTextField.text,self.passTextField.text,nil];
        BOOL response =  [WebServices login:parameters];
        [waitingDialog dismissWithClickedButtonIndex:0 animated:YES];
        if (response)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:nvc animated:YES completion:nil];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Identifiants incorrects" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}

- (void)sessionStateChanged:(NSNotification *)notification
{
    [cancelTimer invalidate];
    if (FBSession.activeSession.isOpen)
    {
        [waitingDialog dismissWithClickedButtonIndex:0 animated:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nvc animated:YES completion:nil];
    }
}

- (void)cancelRequest:(NSTimer *)timer
{
    [waitingDialog dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problème connexion"
                                                    message:@"Veuillez vérifier votre connexion Internet"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

#pragma mark - TextField delegate

- (void)dismissKeyboard
{
    [self.emailTextField resignFirstResponder];
    [self.passTextField resignFirstResponder];
}

- (void)imageTextField:(UITextField *)textField replacementString:(NSString *)newString
{
    if (textField == self.emailTextField)
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
            NSTextCheckingResult *match = [regex firstMatchInString:newString options:0 range:NSMakeRange(0, newString.length)];
            if (match)
            {
                self.imageEmail.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE PRET A VALIDER.png"];
            }
            else
            {
                self.imageEmail.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE ERREUR.png"];
            }
        }
    }
    else if (textField == self.passTextField)
    {
        if (newString.length == 0)
        {
            self.imagePass.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE.png"];
        }
        else
        {
            NSString *expression = @".{4,20}";
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
            NSTextCheckingResult *match = [regex firstMatchInString:newString options:0 range:NSMakeRange(0, newString.length)];
            if (match)
            {
                self.imagePass.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE PRET A VALIDER.png"];
            }
            else
            {
                self.imagePass.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE ERREUR.png"];
            }
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.view.frame.origin.y > 0)
    {
        [UIView animateWithDuration:0.3 animations:^{CGRect frame = self.view.frame;
            frame.origin.y -= 103;
            self.view.frame = frame;}];
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
    [self imageTextField:textField replacementString:newString];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.emailTextField)
    {
        [self.passTextField becomeFirstResponder];
    }
    else
    {
        if (self.view.frame.origin.y < 0)
        {
            [UIView animateWithDuration:0.3 animations:^{CGRect frame = self.view.frame;
                frame.origin.y += 103;
                self.view.frame = frame;}];
        }
    }
    return YES;
}

@end
