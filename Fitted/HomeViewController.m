//
//  HomeViewController.m
//  Fitted
//
//  Created by Maxime Berail on 03/01/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "InspirationViewController.h"
#import "CameraCustom2View.h"

@interface HomeViewController ()
{
    BOOL alreadyPushed;
    UIImagePickerController *imagePicker;
}
@end

@implementation HomeViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customScrollView];
    [self customNavigationBar];
    self.inspiration = [[UIImage alloc] init];
    self.receivePicture = NO;
    self.logout = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picture) name:@"pictureHome" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissImagePicker) name:@"dismissHome" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pellicule) name:@"pelliculeHome" object:nil];
}

- (void)customNavigationBar
{
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"HEADER.png"] forBarMetrics:UIBarMetricsDefault];
    UIView *customTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    customTitle.backgroundColor = [UIColor clearColor];
    UILabel *title = [[UILabel alloc] initWithFrame:customTitle.frame];
    NSString *pseudo = [[NSUserDefaults standardUserDefaults] objectForKey:@"pseudo"];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = [pseudo uppercaseString];
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont systemFontOfSize:20];
    [customTitle addSubview:title];
    self.navigationItem.titleView = customTitle;
    
    UIImage *profile = [UIImage imageNamed:@"BOUTON REGLAGE.png"];
    UIButton *profileButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, profile.size.width, profile.size.height)];
    [profileButton setBackgroundImage:profile forState:UIControlStateNormal];
    [profileButton addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *profilItem =[[UIBarButtonItem alloc] initWithCustomView:profileButton];
    self.navigationItem.rightBarButtonItem = profilItem;
}

- (void)customScrollView
{
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.image = [UIImage imageNamed:@"IMG_0315.JPG"];
    [self.scrollView addSubview:imageView];
    
    CGRect frame2;
    frame2.origin.x = 320;
    frame2.origin.y = 0;
    frame2.size = self.scrollView.frame.size;
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:frame2];
    imageView2.contentMode = UIViewContentModeScaleToFill;
    imageView2.image = [UIImage imageNamed:@"IMG_0316.JPG"];
    [self.scrollView addSubview:imageView2];
    
    UILabel *articleLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 120, 120, 60)];
    articleLabel.numberOfLines = 0;
    articleLabel.font = [UIFont systemFontOfSize:22];
    articleLabel.backgroundColor = [UIColor clearColor];
    articleLabel.textAlignment = NSTextAlignmentCenter;
    articleLabel.textColor = [UIColor whiteColor];
    articleLabel.text = @"AJOUTER ARTICLE";
    [self.scrollView addSubview:articleLabel];
    
    UIView *subview = [[UIView alloc] initWithFrame:CGRectMake(319, 0, 2, self.scrollView.frame.size.height)];
    subview.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:subview];
    
    UIImageView *arrowRight = [[UIImageView alloc] initWithFrame:CGRectMake(320, 137.5, 17, 25)];
    arrowRight.image = [UIImage imageNamed:@"FLECHE DROITE PAGE ACCUEIL.png"];
    [self.scrollView addSubview:arrowRight];
    
    UILabel *inspiLabel = [[UILabel alloc] initWithFrame:CGRectMake(330, 300, 140, 60)];
    inspiLabel.numberOfLines = 0;
    inspiLabel.font = [UIFont systemFontOfSize:22];
    inspiLabel.backgroundColor = [UIColor clearColor];
    inspiLabel.textAlignment = NSTextAlignmentCenter;
    inspiLabel.textColor = [UIColor whiteColor];
    inspiLabel.text = @"AJOUTER INSPIRATION";
    [self.scrollView addSubview:inspiLabel];
    
    UIImageView *arrowLeft = [[UIImageView alloc] initWithFrame:CGRectMake(320-18, 317.5, 17, 25)];
    arrowLeft.image = [UIImage imageNamed:@"FLECHE GAUCHE PAGE ACCUEIL.png"];
    [self.scrollView addSubview:arrowLeft];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * 2, self.scrollView.frame.size.height - 64)];
    [self.scrollView setContentOffset:CGPointMake(160, 0)];
}

- (void)viewWillAppear:(BOOL)animated
{
    alreadyPushed = NO;
    [self.scrollView setContentOffset:CGPointMake(160, 0)];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.receivePicture)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        InspirationViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InspirationViewController"];
        vc.pictureTaked = self.inspiration;
        [self.navigationController pushViewController:vc animated:YES];
        self.receivePicture = NO;
    }
    if (self.logout)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)settings
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - CameraCustom delegate

- (void)dismissImagePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)picture
{
    [imagePicker takePicture];
}

- (void)pellicule
{
    [self dismissViewControllerAnimated:YES completion:^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ALGroupViewController"];
        [self.navigationController pushViewController:vc animated:YES];}];
}

#pragma mark - ImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:^{if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            InspirationViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InspirationViewController"];
            vc.pictureTaked = image;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }}];
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0)
    {
        if (!alreadyPushed)
        {
            alreadyPushed = YES;
            [self performSelector:@selector(pushArticleView) withObject:nil afterDelay:0.3];
        }
    }
    else if (scrollView.contentOffset.x == 320)
    {
        if (!alreadyPushed)
        {
            alreadyPushed = YES;
            [self performSelector:@selector(displayCamera) withObject:nil afterDelay:0.3];
        }
    }
}

- (void)displayCamera
{
    CameraCustom2View *camera = [[CameraCustom2View alloc] initWithFrame:self.view.frame];
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.showsCameraControls = NO;
    imagePicker.navigationBarHidden = YES;
    imagePicker.wantsFullScreenLayout = YES;
    imagePicker.cameraOverlayView = camera;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)pushArticleView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ArticleViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
