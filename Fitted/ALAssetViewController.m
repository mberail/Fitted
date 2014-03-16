//
//  ALAssetViewController.m
//  H2H Feelsafe
//
//  Created by Maxime Berail on 27/12/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import "ALAssetViewController.h"
#import "ALAssetCell.h"
#import "ArticleViewController.h"
#import "HomeViewController.h"
#import "InspirationViewController.h"
#import "ImageCache.h"
#import "WebServices.h"

@interface ALAssetViewController ()
{
    NSMutableArray *assets;
}
@end

@implementation ALAssetViewController
@synthesize group,addProduct,fromInspiration;

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
    assets = [[NSMutableArray alloc] init];
    if (addProduct)
    {
        NSMutableArray *productsTemp = [[NSUserDefaults standardUserDefaults] objectForKey:@"link_products"];
        assets = productsTemp;
    }
    else
    {
        ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop)
        {
            if (asset)
            {
                [assets addObject:asset];
            }
        };
        [group enumerateAssetsUsingBlock:resultsBlock];
    }
    [self.collectionView reloadData];
}

- (void)customNavigationBar
{
    self.navigationController.navigationBar.translucent = NO;
    UIView *customTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    customTitle.backgroundColor = [UIColor clearColor];
    UILabel *title = [[UILabel alloc] initWithFrame:customTitle.frame];
    title.text = self.titleView;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CustomNavigationBar delegate

- (void)previousView
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CollectionView datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"assets : %i",assets.count);
    return assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    UIImage *imgCache = [[UIImage alloc] init];
    if (addProduct)
    {
        NSString *pathUrl = [assets[indexPath.row] objectForKey:@"product_image"];
        NSRange rangePath = NSMakeRange(0, pathUrl.length - 4);
        NSString *thumbUrl = [NSString stringWithFormat:@"%@webroot/images/products/%@_thumb.jpg",kURL,[pathUrl substringWithRange:rangePath]];
        if ([[ImageCache sharedImageCache] doesExist:thumbUrl] == YES)
        {
            imgCache = [[ImageCache sharedImageCache] getImage:thumbUrl];
        }
        else
        {
            NSData *imageData = [WebServices sendDataByGetAtUrl:thumbUrl];
            imgCache = [UIImage imageWithData:imageData];
            [[ImageCache sharedImageCache] addImage:thumbUrl with:imgCache];
        }
        cell.picture.image = imgCache;
        NSArray *products = [[NSArray alloc] init];
        if (fromInspiration)
        {
            InspirationViewController *ivc = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers indexOfObject:self.navigationController.viewControllers.lastObject] - 1];
            products = ivc.arrayProduits;
        }
        else
        {
            ArticleViewController *avc = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers indexOfObject:self.navigationController.viewControllers.lastObject] - 1];
            products = avc.arrayProduits;
        }
        NSLog(@"products : %@",products);
        if ([products containsObject:assets[indexPath.row]])
        {
            cell.alpha = 0.2;
        }
    }
    else
    {
        imgCache = [UIImage imageWithCGImage:[[assets objectAtIndex:assets.count - indexPath.row - 1] thumbnail]];
        cell.picture.image = imgCache;
    }
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 8;
}

#pragma mark - CollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (addProduct)
    {
        if (fromInspiration)
        {
            InspirationViewController *ivc = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers indexOfObject:self.navigationController.viewControllers.lastObject] - 1];
            if (![ivc.arrayProduits containsObject:assets[indexPath.row]])
            {
                [ivc.arrayProduits addObject:assets[indexPath.row]];
                [self.navigationController popToViewController:ivc animated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"receivePictureInspiration" object:nil];
            }
        }
        else
        {
            ArticleViewController *avc = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers indexOfObject:self.navigationController.viewControllers.lastObject] - 1];
            if (![avc.arrayProduits containsObject:assets[indexPath.row]])
            {
                [avc.arrayProduits addObject:assets[indexPath.row]];
                [self.navigationController popToViewController:avc animated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"receivePictureArticle" object:nil];
            }
        }
    }
    else
    {
        UIImage *picture = [UIImage imageWithCGImage:[[[assets objectAtIndex:assets.count - indexPath.row - 1] defaultRepresentation] fullScreenImage]];
        if ([[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers indexOfObject:self.navigationController.viewControllers.lastObject] - 2] isKindOfClass:[HomeViewController class]])
        {
            HomeViewController *hvc = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers indexOfObject:self.navigationController.viewControllers.lastObject] - 2];
            hvc.inspiration = picture;
            hvc.receivePicture = YES;
            [self.navigationController popToViewController:hvc animated:YES];
        }
        else if ([[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers indexOfObject:self.navigationController.viewControllers.lastObject] - 2] isKindOfClass:[ArticleViewController class]])
        {
            ArticleViewController *avc = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers indexOfObject:self.navigationController.viewControllers.lastObject] - 2];
            [avc.arrayPhotos addObject:picture];
            [self.navigationController popToViewController:avc animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"receivePictureArticle" object:nil];
        }
    }
}

@end
