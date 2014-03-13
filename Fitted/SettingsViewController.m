//
//  SettingsViewController.m
//  Fitted
//
//  Created by Maxime Berail on 03/03/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import "SettingsViewController.h"
#import "HomeViewController.h"
#import "WebServices.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    [self customNavBar];
}

- (void)customNavBar
{
    self.navigationController.navigationBar.translucent = NO;
    UIView *customTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    customTitle.backgroundColor = [UIColor clearColor];
    UILabel *title = [[UILabel alloc] initWithFrame:customTitle.frame];
    title.text = @"RÉGLAGES";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont systemFontOfSize:20];
    [customTitle addSubview:title];
    self.navigationItem.titleView = customTitle;
    
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

#pragma mark - Tableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"Sélectionnez votre fond de carte :";
            break;
        default:
            return nil;
            break;
    }
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"paraCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *text = nil;
    switch (indexPath.row)
    {
        case 0:
            text = @"Aide";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            text = @"Déconnexion";
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        default:
            break;
    }
    cell.textLabel.text = text;
    return cell;
}

#pragma mark - Tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            /*DetailsViewController *dvc = [storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
            dvc.dataText = text;
            dvc.navigationItem.title = title;
            [self.navigationController pushViewController:dvc animated:YES];*/
        }
            break;
        case 1:
        {
            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Voulez-vous vraiment vous déconnecter ?" delegate:self cancelButtonTitle:@"Annuler" destructiveButtonTitle:@"Déconnexion" otherButtonTitles:nil];
            action.actionSheetStyle = UIActionSheetStyleAutomatic;
            [action showInView:self.view];
        }
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        [pref setInteger:0 forKey:@"id"];
        [WebServices logout];
        HomeViewController *hvc = self.navigationController.viewControllers[0];
        hvc.logout = YES;
        [self.navigationController popToViewController:hvc animated:YES];
    }
}

@end
