//
//  ALGroupViewController.m
//  H2H Feelsafe
//
//  Created by Maxime Berail on 27/12/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import "ALGroupViewController.h"
#import "ALGroupCell.h"
#import "ALAssetViewController.h"

@interface ALGroupViewController ()
{
    ALAssetsLibrary *assetsLibrary;
    NSMutableArray *groups;
}
@end

@implementation ALGroupViewController

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
	[self loadGroups];
    [self customNavigationBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - CustomNavigationBar

- (void)customNavigationBar
{
    self.navigationController.navigationBar.translucent = NO;
    UIView *customTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    customTitle.backgroundColor = [UIColor clearColor];
    UILabel *title = [[UILabel alloc] initWithFrame:customTitle.frame];
    title.text = @"ALBUMS";
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

#pragma mark - Assets library datasource

- (void)loadGroups
{
    if (!assetsLibrary)
    {assetsLibrary = [[ALAssetsLibrary alloc] init];}
    if (!groups)
    {groups = [[NSMutableArray alloc] init];}
    else
    {[groups removeAllObjects];}
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if(group)
        {[groups addObject:group];}
        [self.tableView reloadData];
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error)
    {
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    NSUInteger groupTypes = ALAssetsGroupAll;
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized)
    {
        [assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restriction accès" message:@"Veuillez activer l'accès à la photothèque pour l'application. Réglages -> Confidentialité -> Photos -> Fitted" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALGroupCell *cell = (ALGroupCell *)[tableView dequeueReusableCellWithIdentifier:@"ALGroupCell"];
    if (cell == nil)
    {
        cell = [[ALGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ALGroupCell"];
    }
    cell.picture.image = [UIImage imageWithCGImage:[[groups objectAtIndex:indexPath.row] posterImage]];
    cell.description.text = [[groups objectAtIndex:indexPath.row] valueForProperty:ALAssetsGroupPropertyName];
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsGroup *group = [groups objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ALAssetViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ALAssetViewController"];
    vc.group = group;
    vc.addProduct = NO;
    vc.titleView = [[groups objectAtIndex:indexPath.row] valueForProperty:ALAssetsGroupPropertyName];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
