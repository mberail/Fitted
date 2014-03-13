//
//  ArticleViewController.h
//  Fitted
//
//  Created by Maxime Berail on 05/01/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

@interface ArticleViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (nonatomic, weak) UIImage *imageTemp;
@property (nonatomic, strong) NSMutableArray *arrayPhotos;
@property (nonatomic, strong) NSMutableArray *arrayProduits;

@end
