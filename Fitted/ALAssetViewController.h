//
//  ALAssetViewController.h
//  H2H Feelsafe
//
//  Created by Maxime Berail on 27/12/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) ALAssetsGroup *group;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSString *titleView;
@property (nonatomic) BOOL addProduct;
@property (nonatomic) BOOL fromInspiration;

@end
