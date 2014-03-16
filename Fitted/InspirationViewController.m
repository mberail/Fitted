//
//  InspirationViewController.m
//  Fitted
//
//  Created by Maxime Berail on 05/01/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import "InspirationViewController.h"
#import "ALAssetViewController.h"
#import "ImageCache.h"
#import "WebServices.h"
#import "SVProgressHUD.h"

@interface InspirationViewController ()
{
    UICollectionView *collectionProduits;
    UILabel *produitsLabel;
    UIImageView *textViewImage;
    UITextView *detailTextView;
    
    NSMutableArray *allElements;
    NSMutableArray *textFields;
    NSMutableArray *imageTextFields;
    NSMutableArray *arrayLabels;
    NSArray *arrayData;
    
    UIAlertView *waitingDialog;
    UIPickerView *currentPickerView;
    
    BOOL alreadyDismiss;
    int indexOfBouton;
}
@end

@implementation InspirationViewController
@synthesize arrayProduits;
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
    [self customNavigationBar];
    [self loadAllElements];
    [self displayPicture];
    indexOfBouton = 0;
    alreadyDismiss = NO;
    arrayProduits = [[NSMutableArray alloc] init];
    arrayData = [NSArray arrayWithObjects:@"Événements",@"Soirées",@"Sport",@"Plein air",@"Activité",@"Lifestyle",@"Quotidien",@"Personnes",@"Saison",@"Articles", nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePicture:) name:@"receivePictureInspiration" object:nil];
}

- (void)customNavigationBar
{
    self.navigationController.navigationBar.translucent = NO;
	UIView *customTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    customTitle.backgroundColor = [UIColor clearColor];
    UILabel *title = [[UILabel alloc] initWithFrame:customTitle.frame];
    title.text = @"AJOUT INSPIRATION";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont systemFontOfSize:20];
    [customTitle addSubview:title];
    self.navigationItem.titleView = customTitle;
    
    /*UIImage *profile = [UIImage imageNamed:@"BOUTON REGLAGE.png"];
    UIButton *profileButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, profile.size.width, profile.size.height)];
    [profileButton setBackgroundImage:profile forState:UIControlStateNormal];
    [profileButton addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *profilItem =[[UIBarButtonItem alloc] initWithCustomView:profileButton];
    self.navigationItem.rightBarButtonItem = profilItem;*/
    
    UIImage *back = [UIImage imageNamed:@"BOUTON RETOUR.png"];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, back.size.width, back.size.height)];
    [backButton setBackgroundImage:back forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(previousView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - NavigationBar delegate

/*- (void)settings
{
    
}*/

- (void)previousView
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ScrollView datasource

- (void)loadAllElements
{
    UIImageView *titreImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 280, 48)];
    titreImage.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE.png"];
    [self.scrollView addSubview:titreImage];
    
    UITextField *titreTextField = [[UITextField alloc] initWithFrame:CGRectMake(35, 20, 260, 48)];
    titreTextField.placeholder = @"Titre_";
    titreTextField.delegate = self;
    [self.scrollView addSubview:titreTextField];
    
    UIImageView *tagImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 78, 280, 48)];
    tagImage.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE.png"];
    [self.scrollView addSubview:tagImage];
    
    UITextField *tagTextField = [[UITextField alloc] initWithFrame:CGRectMake(35, 78, 260, 48)];
    tagTextField.placeholder = @"#_";
    tagTextField.delegate = self;
    [self.scrollView addSubview:tagTextField];
    
    UIButton *tagBouton = [UIButton buttonWithType:UIButtonTypeCustom];
    tagBouton.frame = CGRectMake(20, 136, 40, 40);
    [tagBouton setBackgroundImage:[UIImage imageNamed:@"BOUTON PLUS.png"] forState:UIControlStateNormal];
    [tagBouton addTarget:self action:@selector(addTag) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:tagBouton];
    
    UIButton *categorieBouton = [UIButton buttonWithType:UIButtonTypeCustom];
    categorieBouton.frame = CGRectMake(20, 186, 280, 48);
    [categorieBouton setBackgroundImage:[UIImage imageNamed:@"BOUTON MD SEUL.png"] forState:UIControlStateNormal];
    [categorieBouton addTarget:self action:@selector(displayPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:categorieBouton];
    
    UILabel *categorieLabelPicker = [[UILabel alloc] initWithFrame:CGRectMake(145, 186, 150, 48)];
    categorieLabelPicker.text = @"";
    categorieLabelPicker.textAlignment = NSTextAlignmentRight;
    categorieLabelPicker.font = [UIFont boldSystemFontOfSize:17];
    categorieLabelPicker.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    [self.scrollView addSubview:categorieLabelPicker];
    
    UILabel *categorieLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 186, 120, 48)];
    categorieLabel.text = @"   Catégorie 1";
    categorieLabel.font = [UIFont systemFontOfSize:17];
    categorieLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    [self.scrollView addSubview:categorieLabel];
    
    UIButton *addBouton = [UIButton buttonWithType:UIButtonTypeCustom];
    addBouton.frame = CGRectMake(20, 244, 40, 40);
    [addBouton setBackgroundImage:[UIImage imageNamed:@"BOUTON PLUS.png"] forState:UIControlStateNormal];
    [addBouton addTarget:self action:@selector(addCategory) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:addBouton];
    
    UICollectionViewFlowLayout *flowLayout2 = [[UICollectionViewFlowLayout alloc] init];
    collectionProduits = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 294, 300, 0) collectionViewLayout:flowLayout2];
    collectionProduits.dataSource = self;
    collectionProduits.delegate = self;
    [collectionProduits registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"produitsCell"];
    collectionProduits.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:collectionProduits];
    
    UIButton *produitsBouton = [UIButton buttonWithType:UIButtonTypeCustom];
    produitsBouton.frame = CGRectMake(20, 294, 280, 48);
    [produitsBouton setBackgroundImage:[UIImage imageNamed:@"BOUTON MD SEUL.png"] forState:UIControlStateNormal];
    [produitsBouton addTarget:self action:@selector(addProduit) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:produitsBouton];
    
    produitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 294, 180, 48)];
    produitsLabel.text = @"   Lier des articles (5)";
    produitsLabel.font = [UIFont systemFontOfSize:17];
    produitsLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    [self.scrollView addSubview:produitsLabel];
    
    textViewImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 352, 280, 165)];
    textViewImage.image = [UIImage imageNamed:@"LAIUS.png"];
    [self.scrollView addSubview:textViewImage];
    
    detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(30, 362, 260, 145)];
    //detailTextView.text = @"   Laïus_";
    //detailTextView.textColor = [UIColor colorWithWhite:0.75 alpha:1];
    detailTextView.font = [UIFont systemFontOfSize:15];
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.delegate = self;
    [self.scrollView addSubview:detailTextView];
    
    UIButton *validerBouton = [UIButton buttonWithType:UIButtonTypeCustom];
    validerBouton.frame = CGRectMake(20, 527, 280, 50);
    [validerBouton setTitle:@"VALIDER" forState:UIControlStateNormal];
    [validerBouton setFont:[UIFont systemFontOfSize:22]];
    [validerBouton setBackgroundImage:[UIImage imageNamed:@"BOUTON VALIDATION.png"] forState:UIControlStateNormal];
    [validerBouton addTarget:self action:@selector(proceedWithAddInspiration) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:validerBouton];
    
    [self.scrollView setContentSize:CGSizeMake(320, 595)];
    
    allElements = [[NSMutableArray alloc] initWithObjects:titreImage,titreTextField,tagImage,tagTextField,tagBouton,categorieBouton,categorieLabelPicker,categorieLabel,addBouton,collectionProduits,produitsBouton,produitsLabel,textViewImage,detailTextView,validerBouton, nil];
    
    textFields = [[NSMutableArray alloc] initWithObjects:titreTextField,tagTextField,nil];
    imageTextFields = [[NSMutableArray alloc] initWithObjects:titreImage,tagImage, nil];
    arrayLabels = [[NSMutableArray alloc] initWithObjects:categorieLabelPicker, nil];
}

- (void)displayPicture
{
    CGRect frame;
    if (self.pictureTaked.size.width > self.pictureTaked.size.height)
    {
        frame = CGRectMake(10, 10, 300, 226);
    }
    else
    {
        frame = CGRectMake(10, 10, 300, 400);
    }
    UIImageView *picture = [[UIImageView alloc] initWithFrame:frame];
    picture.contentMode = UIViewContentModeScaleAspectFit;
    picture.image = self.pictureTaked;
    [self.scrollView addSubview:picture];
    
    for (int i = 0; i < allElements.count; i++)
    {
        CGRect tempFrame = [allElements[i] frame];
        tempFrame.origin.y += frame.size.height;
        [allElements[i] setFrame:tempFrame];
    }
    [self.scrollView setContentSize:CGSizeMake(320, self.scrollView.contentSize.height + frame.size.height)];
    
    NSMutableArray *tempAllElements = [[NSMutableArray alloc] init];
    [tempAllElements addObject:picture];
    [tempAllElements addObjectsFromArray:allElements];
    allElements = [[NSMutableArray alloc] initWithArray:tempAllElements];
}

#pragma mark - ScrollView delegate

- (void)displayPickerView:(UIButton *)sender
{
    [self dismissKeyboard];
    if (indexOfBouton == 0)
    {
        [self.scrollView setContentOffset:CGPointMake(0, sender.frame.origin.y - 20)];
        currentPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, sender.frame.origin.y + 58, 320, 162)];
        currentPickerView.dataSource = self;
        currentPickerView.delegate = self;
        currentPickerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BOUTON MD SEUL.png"]];
        [self.scrollView addSubview:currentPickerView];
        indexOfBouton = [allElements indexOfObject:sender];
        for (int i = [allElements indexOfObject:sender] + 3; i < allElements.count; i++)
        {
            CGRect tempFrame = [[allElements objectAtIndex:i] frame];
            tempFrame.origin.y += 172;
            [[allElements objectAtIndex:i] setFrame:tempFrame];
        }
        [self.scrollView setContentSize:CGSizeMake(320, self.scrollView.contentSize.height + 172)];
    }
    else
    {
        int indexOfSender = [allElements indexOfObject:sender];
        if (indexOfSender == indexOfBouton)
        {
            NSInteger selected = [currentPickerView selectedRowInComponent:0];
            [self dismissPickerView:arrayData[selected]];
        }
        else
        {
            [self dismissPickerView:[[allElements objectAtIndex:indexOfBouton+1] text]];
            [self displayPickerView:sender];
        }
    }
}

- (void)addTag
{
    int numberOfTextFields = 0;
    int indexLastTextField = 0;
    for (int i = 0; i < allElements.count; i++)
    {
        id object = allElements[i];
        if ([object isKindOfClass:[UITextField class]])
        {
            numberOfTextFields++;
            indexLastTextField = i;
        }
    }
    
    if (numberOfTextFields < 5)
    {
        CGRect previousFrame = [allElements[indexLastTextField] frame];
        
        UIImageView *tag2Image = [[UIImageView alloc] initWithFrame:CGRectMake(20, previousFrame.origin.y + 58, 280, 48)];
        tag2Image.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE.png"];
        [self.scrollView addSubview:tag2Image];
        [imageTextFields addObject:tag2Image];
        
        UITextField *tagTextField2 = [[UITextField alloc] initWithFrame:CGRectMake(35, previousFrame.origin.y + 58, 260, 48)];
        tagTextField2.placeholder = @"#_";
        tagTextField2.delegate = self;
        [self.scrollView addSubview:tagTextField2];
        [textFields addObject:tagTextField2];
        
        for (int j = indexLastTextField+1; j < allElements.count; j++)
        {
            CGRect tempFrame = [[allElements objectAtIndex:j] frame];
            tempFrame.origin.y += 58;
            [[allElements objectAtIndex:j] setFrame:tempFrame];
        }
        [self.scrollView setContentSize:CGSizeMake(320, self.scrollView.contentSize.height + 58)];
        
        NSIndexSet *indexBefore = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, indexLastTextField+1)];
        NSArray *arrayBefore = [allElements objectsAtIndexes:indexBefore];
        NSMutableArray *tempAllElements = [[NSMutableArray alloc] initWithArray:arrayBefore];
        [tempAllElements addObject:tag2Image];
        [tempAllElements addObject:tagTextField2];
        NSIndexSet *indexAfter = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexLastTextField+1, allElements.count-indexLastTextField-1)];
        NSArray *arrayAfter = [allElements objectsAtIndexes:indexAfter];
        [tempAllElements addObjectsFromArray:arrayAfter];
        allElements = [[NSMutableArray alloc] initWithArray:tempAllElements];
    }
}

- (void)addCategory
{
    [self dismissPickerView:nil];
    int indexFirstBouton = 0;
    int indexLastBouton = 0;
    for (int i = 0; i < allElements.count; i++)
    {
        id object = allElements[i];
        if ([object frame].size.height == 40)
        {
            if (indexFirstBouton == 0)
            {
                indexFirstBouton = i;
            }
            else
            {
                indexLastBouton = i;
            }
        }
    }
    int numberOfBoutons = (indexLastBouton - indexFirstBouton)/3;
    if (numberOfBoutons < 3)
    {
        CGRect previousFrame = [allElements[indexLastBouton-1] frame];
        UIButton *bouton = [UIButton buttonWithType:UIButtonTypeCustom];
        bouton.frame = CGRectMake(20, previousFrame.origin.y+58, 280, 48);
        [bouton setBackgroundImage:[UIImage imageNamed:@"BOUTON MD SEUL.png"] forState:UIControlStateNormal];
        [bouton addTarget:self action:@selector(displayPickerView:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:bouton];
        
        UILabel *labelPicker = [[UILabel alloc] initWithFrame:CGRectMake(145, previousFrame.origin.y+58, 150, 48)];
        labelPicker.text = @"";
        labelPicker.textAlignment = NSTextAlignmentRight;
        labelPicker.font = [UIFont boldSystemFontOfSize:17];
        labelPicker.textColor = [UIColor colorWithWhite:0.25 alpha:1];
        [self.scrollView addSubview:labelPicker];
        [arrayLabels addObject:labelPicker];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, previousFrame.origin.y+58, 120, 48)];
        label.text = [NSString stringWithFormat:@"   Catégorie %i",numberOfBoutons+1];
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = [UIColor colorWithWhite:0.25 alpha:1];
        [self.scrollView addSubview:label];
        
        for (int j = indexLastBouton; j < allElements.count; j++)
        {
            CGRect tempFrame = [[allElements objectAtIndex:j] frame];
            tempFrame.origin.y += 58;
            [[allElements objectAtIndex:j] setFrame:tempFrame];
        }
        [self.scrollView setContentSize:CGSizeMake(320, self.scrollView.contentSize.height + 58)];
        
        NSIndexSet *indexBefore = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, indexLastBouton)];
        NSArray *arrayBefore = [allElements objectsAtIndexes:indexBefore];
        NSMutableArray *tempAllElements = [[NSMutableArray alloc] initWithArray:arrayBefore];
        [tempAllElements addObject:bouton];
        [tempAllElements addObject:labelPicker];
        [tempAllElements addObject:label];
        NSIndexSet *indexAfter = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexLastBouton, allElements.count-indexLastBouton)];
        NSArray *arrayAfter = [allElements objectsAtIndexes:indexAfter];
        [tempAllElements addObjectsFromArray:arrayAfter];
        allElements = [[NSMutableArray alloc] initWithArray:tempAllElements];
    }
}

- (void)addProduit
{
    if (arrayProduits.count < 10)
    {
        NSArray *linkProducts = [[NSUserDefaults standardUserDefaults] objectForKey:@"link_products"];
        if (linkProducts.count != 0)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ALAssetViewController *avc = [storyboard instantiateViewControllerWithIdentifier:@"ALAssetViewController"];
            avc.titleView = @"MES ARTICLES";
            avc.addProduct = YES;
            avc.fromInspiration = YES;
            [self.navigationController pushViewController:avc animated:YES];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Vous n'avez aucun article enregistré pour le moment." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Vous pouvez lier au maximum 1O articles." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Add inspiration delegate

- (void)proceedWithAddInspiration
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < textFields.count; i++)
    {
        if (![[imageTextFields[i] image] isEqual:[UIImage imageNamed:@"BOUTON CHAMP LIBRE PRET A VALIDER.png"]])
        {
            [[[UIAlertView alloc] initWithTitle:@"Champs incorrects" message:@"Veuillez compléter correctement tous les champs de texte. (Cadre vert)" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
    }
    for (int i = 0; i < textFields.count; i++)
    {
        if (i == 0)
        {
            [parameters setObject:[textFields[i] text] forKey:@"title"];
        }
        else
        {
            NSString *tempKey = [NSString stringWithFormat:@"tag%i",i-1];
            [parameters setObject:[textFields[i] text] forKey:tempKey];
        }
    }
    if (detailTextView.text.length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Description manquante" message:@"Veuillez compléter une description de votre inspiration." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    [parameters setObject:detailTextView.text forKey:@"description"];
    for (int j = 0; j < arrayLabels.count; j++)
    {
        if ([[arrayLabels[j] text] length] == 0)
        {
            [[[UIAlertView alloc] initWithTitle:@"Champs incomplets" message:@"Veuillez compléter correctement toutes les informations." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        NSString *tempKey = [NSString stringWithFormat:@"categorie%i",j+1];
        [parameters setObject:[arrayLabels[j] text] forKey:tempKey];
    }
    NSMutableArray *idProducts = [[NSMutableArray alloc] init];
    for (int l = 0; l < arrayProduits.count; l++)
    {
        [idProducts addObject:[arrayProduits[l] objectForKey:@"id"]];
    }
    [parameters setObject:[WebServices base64forData:UIImageJPEGRepresentation(self.pictureTaked, 0.5)] forKey:@"photo1"];
    [parameters setObject:idProducts forKey:@"products_id"];
    [parameters setObject:@"ios" forKey:@"device"];
    [self startAddInspiration:parameters];
}

- (void)startAddInspiration:(NSDictionary *)products
{
    //waitingDialog = [[UIAlertView alloc] initWithTitle:@"Ajout en cours .." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    //[waitingDialog show];
    [SVProgressHUD showWithStatus:@"Ajout en cours"];
    [self performSelector:@selector(addProductWebServices:) withObject:products afterDelay:0.3];
}

- (void)addProductWebServices:(NSDictionary *)products
{
    BOOL addProduct = [WebServices addProduct:products with:[NSArray arrayWithObject:self.pictureTaked]];
    //[waitingDialog dismissWithClickedButtonIndex:0 animated:YES];
    [SVProgressHUD dismiss];
    if (addProduct)
    {
        [self.navigationController popViewControllerAnimated:YES];
        [SVProgressHUD showSuccessWithStatus:@"Ajout réussi"];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"Échec lors de l'ajout"];
    }
}

#pragma mark - Image Picker delegate

- (void)receivePicture:(NSNotification *)note
{
    [collectionProduits reloadData];
    [self reorderScroll:collectionProduits];
}

- (void)reorderScroll:(UICollectionView *)collection
{
    CGRect previousFrame = collection.frame;
    if (collection == collectionProduits)
    {
        previousFrame.size.height = ceil(((float)arrayProduits.count)/4)*80;
        if (arrayProduits.count > 0)
        {
            produitsLabel.text = [NSString stringWithFormat:@"   Lier des articles (%i)",5-arrayProduits.count];
        }
        else
        {
            produitsLabel.text = @"   Lier des articles (5)";
        }
    }
    for (int i = [allElements indexOfObject:collection]+1; i < allElements.count; i++)
    {
        CGRect tempFrame = [[allElements objectAtIndex:i] frame];
        tempFrame.origin.y += (previousFrame.size.height - collection.frame.size.height);
        [[allElements objectAtIndex:i] setFrame:tempFrame];
    }
    [self.scrollView setContentSize:CGSizeMake(320, self.scrollView.contentSize.height + (previousFrame.size.height - collection.frame.size.height))];
    collection.frame = previousFrame;
}

#pragma mark - CollectionView datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    int numberOfItems = 0;
    if (collectionView == collectionProduits)
    {
        numberOfItems = arrayProduits.count;
    }
    NSLog(@"items : %i",numberOfItems);
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (collectionView == collectionProduits)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"produitsCell" forIndexPath:indexPath];
        UIImage *imgCache = [[UIImage alloc] init];
        NSString *pathUrl = [arrayProduits[indexPath.row] objectForKey:@"product_image"];
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
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        imageV.contentMode = UIViewContentModeScaleToFill;
        imageV.image = imgCache;
        [cell addSubview:imageV];
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(40, 0, 30, 30);
        deleteButton.tag = indexPath.row;
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"BOUTON MOINS.png"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deletePictureFromProduits:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:deleteButton];
    }
    return cell;
}

#pragma mark - CollectionView delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == collectionProduits)
    {
        return CGSizeMake(70, 70);
    }
    else
        return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 8;
}

- (void)deletePictureFromProduits:(UIButton *)sender
{
    [arrayProduits removeObjectAtIndex:sender.tag];
    [collectionProduits reloadData];
    [self reorderScroll:collectionProduits];
}

#pragma mark - PickerView datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return arrayData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return arrayData[row];
}

#pragma mark - PickerView delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    /*if (!alreadyDismiss)
    {
        alreadyDismiss = YES;
        [self dismissPickerView:arrayData[row]];
    }*/
}

- (void)dismissPickerView:(NSString *)text
{
    if (text != nil)
    {
        UILabel *pickerLabel = [allElements objectAtIndex:indexOfBouton+1];
        pickerLabel.text = text;
    }
    for (int i = 0; i < self.scrollView.subviews.count; i++)
    {
        id object = [self.scrollView.subviews objectAtIndex:i];
        if ([object isKindOfClass:[UIPickerView class]])
        {
            [[self.scrollView.subviews objectAtIndex:i]  removeFromSuperview];
            for (int i = indexOfBouton + 3; i < allElements.count; i++)
            {
                CGRect tempFrame = [[allElements objectAtIndex:i] frame];
                tempFrame.origin.y -= 172;
                [[allElements objectAtIndex:i] setFrame:tempFrame];
            }
            indexOfBouton = 0;
            [self.scrollView setContentSize:CGSizeMake(320, self.scrollView.contentSize.height - 172)];
            alreadyDismiss = NO;
        }
    }
}

#pragma mark - TextField delegate

- (void)dismissKeyboard
{
    for (int i = 0; i < textFields.count; i++)
    {
        [textFields[i] resignFirstResponder];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 20)];
    if (textField != textFields[0])
    {
        textField.text = @"#";
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
    if (textField == textFields[0])
    {
        if (newString.length == 0)
        {
            [imageTextFields[0] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE.png"]];
        }
        else
        {
            NSString *expression = @".{1,20}";
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
            NSRange rangeNewMatch = [regex rangeOfFirstMatchInString:newString options:0 range:NSMakeRange(0, newString.length)];
            NSRange rangeOldMatch = [regex rangeOfFirstMatchInString:textField.text options:0 range:NSMakeRange(0, textField.text.length)];
            if (!NSEqualRanges(rangeNewMatch, NSMakeRange(NSNotFound, 0)))
            {
                [imageTextFields[0] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE PRET A VALIDER.png"]];
                if (NSEqualRanges(rangeNewMatch, rangeOldMatch))
                {
                    return NO;
                }
            }
            else
            {
                [imageTextFields[0] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE ERREUR.png"]];
            }
        }
    }
    else
    {
        int index = [textFields indexOfObject:textField];
        if (newString.length == 0)
        {
            [imageTextFields[index] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE.png"]];
        }
        else
        {
            NSString *expression = @"[#]{1}[a-zA-Z0-9àâéèêôùûç]{1,20}";
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
            NSRange rangeNewMatch = [regex rangeOfFirstMatchInString:newString options:0 range:NSMakeRange(0, newString.length)];
            NSRange rangeOldMatch = [regex rangeOfFirstMatchInString:textField.text options:0 range:NSMakeRange(0, textField.text.length)];
            if (!NSEqualRanges(rangeNewMatch, NSMakeRange(NSNotFound, 0)))
            {
                [imageTextFields[index] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE PRET A VALIDER.png"]];
                if (NSEqualRanges(rangeNewMatch, rangeOldMatch))
                {
                    return NO;
                }
            }
            else
            {
                [imageTextFields[index] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE ERREUR.png"]];
            }
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TextView delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y - 120)];
    textViewImage.image = [UIImage imageNamed:@"LAIUS-2.png"];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newString = nil;
    if (text.length == 0)
    {
        newString = [textView.text substringWithRange:NSMakeRange(0, textView.text.length-1)];
    }
    else
    {
        newString = [textView.text stringByAppendingString:text];
    }
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        if (newString.length == 0)
        {
            textViewImage.image = [UIImage imageNamed:@"LAIUS.png"];
        }
    }
    else
    {
        NSString *expression = @".{1,200}";
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
        NSRange rangeNewMatch = [regex rangeOfFirstMatchInString:newString options:0 range:NSMakeRange(0, newString.length)];
        NSRange rangeOldMatch = [regex rangeOfFirstMatchInString:textView.text options:0 range:NSMakeRange(0, textView.text.length)];
        if (!NSEqualRanges(rangeNewMatch, NSMakeRange(NSNotFound, 0)))
        {
            if (NSEqualRanges(rangeNewMatch, rangeOldMatch))
            {
                return NO;
            }
        }
    }
    [self.scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y - 240)];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    if (textView.text.length == 0)
    {
        textViewImage.image = [UIImage imageNamed:@"LAIUS.png"];
    }
    return YES;
}

@end
