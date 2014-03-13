//
//  HomeViewController.h
//  Fitted
//
//  Created by Maxime Berail on 03/01/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface HomeViewController : UIViewController <UIScrollViewDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *inspiration;
@property (nonatomic) BOOL receivePicture;
@property (nonatomic) BOOL logout;

@end
