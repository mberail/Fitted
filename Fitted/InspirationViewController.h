//
//  InspirationViewController.h
//  Fitted
//
//  Created by Maxime Berail on 05/01/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InspirationViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *pictureTaked;
@property (nonatomic, strong) NSMutableArray *arrayProduits;

@end
