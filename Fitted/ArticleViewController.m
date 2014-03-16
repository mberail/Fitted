//
//  ArticleViewController.m
//  Fitted
//
//  Created by Maxime Berail on 05/01/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import "ArticleViewController.h"
#import "CameraCustomView.h"
#import "ALAssetViewController.h"
#import "WebServices.h"
#import "ImageCache.h"
#import "UIImage+fixOrientation.h"
#import "SVProgressHUD.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ArticleViewController ()
{
    UIImagePickerController *imagePicker;
    UICollectionView *collectionColor;
    UICollectionView *collectionPhoto;
    UILabel *photoLabel;
    UICollectionView *collectionProduits;
    UILabel *produitsLabel;
    UITextView *detailTextView;
    UIImageView *textViewImage;
    
    NSMutableArray *allElements;
    NSMutableArray *imageTextFields;
    NSArray *textFields;
    NSArray *arrayGender;
    NSArray *arrayNatureHomme;
    NSArray *arrayNatureFemme;
    NSArray *dataColors;
    NSArray *arraySaisons;
    NSMutableArray *arrayColors;
    NSArray *arrayLabels;
    NSArray *currentArray;
    int indexOfBouton;
    BOOL addPhotoOrProduits;
    BOOL alreadyDismiss;
    
    UIAlertView *waitingDialog;
    UIPickerView *currentPickerView;
}
@end

@implementation ArticleViewController
@synthesize arrayPhotos,arrayProduits;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customNavigationBar];
    [self loadAllElements];
    arrayGender = [NSArray arrayWithObjects:@"Homme",@"Femme", nil];
    arrayNatureHomme = [NSArray arrayWithObjects:@"Sport", @"Déguisements", @"Pantalons", @"Maillots de bain", @"Costumes et Blazers", @"Shorts", @"Chaussures", @"Chemises", @"T-Shirt-Polos", @"Pulls-Cardigans", @"Jeans", @"Manteaux-Vestes", @"Sacs", @"Accessoires", @"Sweat-Shirts", nil];
    arrayNatureFemme = [NSArray arrayWithObjects:@"Sport", @"Déguisements", @"Pantalons", @"Maillots de bain", @"Ensembles et Tailleurs", @"Shorts", @"Chaussures", @"Chemises", @"T-Shirt-Débardeurs", @"Tops", @"Pulls-Cardigans", @"Jeans", @"Manteaux-Vestes", @"Sacs", @"Accessoires", @"Sweat-Shirts", @"Robes-Jupes", nil];
    dataColors = [NSArray arrayWithObjects:UIColorFromRGB(0x530000),UIColorFromRGB(0x860004),UIColorFromRGB(0xf60d16),UIColorFromRGB(0xcd000a),UIColorFromRGB(0xe33777),UIColorFromRGB(0x852089),UIColorFromRGB(0x5d3092),UIColorFromRGB(0x212189),UIColorFromRGB(0x004fc3),UIColorFromRGB(0x0086c2),UIColorFromRGB(0x54c1c0),UIColorFromRGB(0x69c417),UIColorFromRGB(0x568900),UIColorFromRGB(0x295500),UIColorFromRGB(0x545400),UIColorFromRGB(0xffff00),UIColorFromRGB(0xffc317),UIColorFromRGB(0xff8800),UIColorFromRGB(0xfe5200),UIColorFromRGB(0xc05325),UIColorFromRGB(0x875424),UIColorFromRGB(0x532600),UIColorFromRGB(0x000000),UIColorFromRGB(0x878787),UIColorFromRGB(0xc1c1c1),UIColorFromRGB(0xefefef),UIColorFromRGB(0xffffff), nil];
    arraySaisons = [NSArray arrayWithObjects:@"Aucune",@"Automne-Hiver",@"Printemps-Été",@"Toutes", nil];
    arrayColors = [[NSMutableArray alloc] init];
    arrayPhotos = [[NSMutableArray alloc] init];
    arrayProduits = [[NSMutableArray alloc] init];
    indexOfBouton = 0;
    alreadyDismiss = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pictureArticle) name:@"pictureArticle" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissArticle) name:@"dismissArticle" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pelliculeArticle) name:@"pelliculeArticle" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePicture:) name:@"receivePictureArticle" object:nil];
}

#pragma mark - CustomNavigationBar datasource

- (void)customNavigationBar
{
    self.navigationController.navigationBar.translucent = NO;
    UIView *customTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    customTitle.backgroundColor = [UIColor clearColor];
    UILabel *title = [[UILabel alloc] initWithFrame:customTitle.frame];
    title.text = @"AJOUT ARTICLE";
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

#pragma mark - CustomNavigationBar delegate

- (void)previousView
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*- (void)settings
{
    
}*/

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
    
    UIButton *genreBouton = [UIButton buttonWithType:UIButtonTypeCustom];
    genreBouton.frame = CGRectMake(20, 78, 280, 48);
    [genreBouton setBackgroundImage:[UIImage imageNamed:@"BOUTON MD SEUL.png"] forState:UIControlStateNormal];
    [genreBouton addTarget:self action:@selector(displayPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:genreBouton];
    
    UILabel *genreLabelPicker = [[UILabel alloc] initWithFrame:CGRectMake(100, 78, 190, 48)];
    genreLabelPicker.text = @"";
    genreLabelPicker.textAlignment = NSTextAlignmentRight;
    genreLabelPicker.font = [UIFont boldSystemFontOfSize:17];
    genreLabelPicker.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    [self.scrollView addSubview:genreLabelPicker];
    
    UILabel *genreLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 78, 80, 48)];
    genreLabel.text = @"   Genre";
    genreLabel.font = [UIFont systemFontOfSize:17];
    genreLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    [self.scrollView addSubview:genreLabel];
    
    UIButton *natureBouton = [UIButton buttonWithType:UIButtonTypeCustom];
    natureBouton.frame = CGRectMake(20, 136, 280, 48);
    [natureBouton setBackgroundImage:[UIImage imageNamed:@"BOUTON MD SEUL.png"] forState:UIControlStateNormal];
    [natureBouton addTarget:self action:@selector(displayPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:natureBouton];
    
    UILabel *natureLabelPicker = [[UILabel alloc] initWithFrame:CGRectMake(100, 136, 190, 48)];
    natureLabelPicker.text = @"";
    natureLabelPicker.textAlignment = NSTextAlignmentRight;
    natureLabelPicker.font = [UIFont boldSystemFontOfSize:17];
    natureLabelPicker.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    [self.scrollView addSubview:natureLabelPicker];
    
    UILabel *natureLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 136, 80, 48)];
    natureLabel.text = @"   Nature";
    natureLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    natureLabel.font = [UIFont systemFontOfSize:17];
    [self.scrollView addSubview:natureLabel];
    
    UIButton *typeBouton = [UIButton buttonWithType:UIButtonTypeCustom];
    typeBouton.frame = CGRectMake(20, 194, 280, 48);
    [typeBouton setBackgroundImage:[UIImage imageNamed:@"BOUTON MD SEUL.png"] forState:UIControlStateNormal];
    [typeBouton addTarget:self action:@selector(displayPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:typeBouton];
    
    UILabel *typeLabelPicker = [[UILabel alloc] initWithFrame:CGRectMake(100, 194, 190, 48)];
    typeLabelPicker.text = @"";
    typeLabelPicker.textAlignment = NSTextAlignmentRight;
    typeLabelPicker.font = [UIFont boldSystemFontOfSize:17];
    typeLabelPicker.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    [self.scrollView addSubview:typeLabelPicker];
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 194, 80, 48)];
    typeLabel.text = @"   Type";
    typeLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    typeLabel.font = [UIFont systemFontOfSize:17];
    [self.scrollView addSubview:typeLabel];
    
    UIImageView *tailleImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 252, 280, 48)];
    tailleImage.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE.png"];
    [self.scrollView addSubview:tailleImage];
    
    UITextField *tailleTextField = [[UITextField alloc] initWithFrame:CGRectMake(35, 252, 260, 48)];
    tailleTextField.placeholder = @"Taille_";
    tailleTextField.delegate = self;
    [self.scrollView addSubview:tailleTextField];
    
    UIImageView *marqueImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 310, 280, 48)];
    marqueImage.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE.png"];
    [self.scrollView addSubview:marqueImage];
    
    UITextField *marqueTextField = [[UITextField alloc] initWithFrame:CGRectMake(35, 310, 260, 48)];
    marqueTextField.placeholder = @"Marque_";
    marqueTextField.delegate = self;
    [self.scrollView addSubview:marqueTextField];
    
    UIImageView *couleurImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 368, 280, 202)];
    couleurImage.image = [UIImage imageNamed:@"BOUTON CHOIX COULEUR.png"];
    [self.scrollView addSubview:couleurImage];
    
    UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 368, 100, 48)];
    colorLabel.text = @"   Couleurs";
    colorLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    colorLabel.font = [UIFont systemFontOfSize:17];
    [self.scrollView addSubview:colorLabel];
    
    UICollectionViewFlowLayout *flowLayout0 = [[UICollectionViewFlowLayout alloc] init];
    collectionColor = [[UICollectionView alloc] initWithFrame:CGRectMake(30, 410, 260, 160) collectionViewLayout:flowLayout0];
    collectionColor.dataSource = self;
    collectionColor.delegate = self;
    [collectionColor registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"colorCell"];
    collectionColor.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:collectionColor];
    
    UIImageView *prixImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 580, 280, 48)];
    prixImage.image = [UIImage imageNamed:@"BOUTON CHAMP LIBRE.png"];
    [self.scrollView addSubview:prixImage];
    
    UITextField *prixTextField = [[UITextField alloc] initWithFrame:CGRectMake(35, 580, 260, 48)];
    prixTextField.placeholder = @"Prix_";
    prixTextField.delegate = self;
    prixTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.scrollView addSubview:prixTextField];
    
    UIButton *saisonBouton = [UIButton buttonWithType:UIButtonTypeCustom];
    saisonBouton.frame = CGRectMake(20, 638, 280, 48);
    [saisonBouton setBackgroundImage:[UIImage imageNamed:@"BOUTON MD SEUL.png"] forState:UIControlStateNormal];
    [saisonBouton addTarget:self action:@selector(displayPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:saisonBouton];
    
    UILabel *saisonLabelPicker = [[UILabel alloc] initWithFrame:CGRectMake(100, 638, 190, 48)];
    saisonLabelPicker.text = @"";
    saisonLabelPicker.textAlignment = NSTextAlignmentRight;
    saisonLabelPicker.font = [UIFont boldSystemFontOfSize:17];
    saisonLabelPicker.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    [self.scrollView addSubview:saisonLabelPicker];
    
    UILabel *saisonLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 638, 80, 48)];
    saisonLabel.text = @"   Saison";
    saisonLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    saisonLabel.font = [UIFont systemFontOfSize:17];
    [self.scrollView addSubview:saisonLabel];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionPhoto = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 696, 300, 0) collectionViewLayout:flowLayout];
    collectionPhoto.dataSource = self;
    collectionPhoto.delegate = self;
    [collectionPhoto registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"photoCell"];
    collectionPhoto.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:collectionPhoto];
    
    UIButton *photoBouton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoBouton.frame = CGRectMake(20, 696, 280, 48);
    [photoBouton setBackgroundImage:[UIImage imageNamed:@"BOUTON MD SEUL.png"] forState:UIControlStateNormal];
    [photoBouton addTarget:self action:@selector(addPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:photoBouton];
    
    photoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 696, 150, 48)];
    photoLabel.text = @"   Ajouter Photo (5)";
    photoLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    photoLabel.font = [UIFont systemFontOfSize:17];
    [self.scrollView addSubview:photoLabel];
    
    UICollectionViewFlowLayout *flowLayout2 = [[UICollectionViewFlowLayout alloc] init];
    collectionProduits = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 754, 300, 0) collectionViewLayout:flowLayout2];
    collectionProduits.dataSource = self;
    collectionProduits.delegate = self;
    [collectionProduits registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"produitsCell"];
    collectionProduits.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:collectionProduits];
    
    UIButton *produitsBouton = [UIButton buttonWithType:UIButtonTypeCustom];
    produitsBouton.frame = CGRectMake(20, 754, 280, 48);
    [produitsBouton setBackgroundImage:[UIImage imageNamed:@"BOUTON MD SEUL.png"] forState:UIControlStateNormal];
    [produitsBouton addTarget:self action:@selector(addProduit) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:produitsBouton];
    
    produitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 754, 180, 48)];
    produitsLabel.text = @"   Je le porte avec (10)";
    produitsLabel.font = [UIFont systemFontOfSize:17];
    produitsLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1];
    [self.scrollView addSubview:produitsLabel];
    
    textViewImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 812, 280, 165)];
    textViewImage.image = [UIImage imageNamed:@"LAIUS.png"];
    [self.scrollView addSubview:textViewImage];
    
    detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(30, 822, 260, 145)];
    detailTextView.font = [UIFont systemFontOfSize:15];
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.delegate = self;
    [self.scrollView addSubview:detailTextView];
    
    UIButton *validerBouton = [UIButton buttonWithType:UIButtonTypeCustom];
    validerBouton.frame = CGRectMake(20, 987, 280, 50);
    [validerBouton setTitle:@"VALIDER" forState:UIControlStateNormal];
    [validerBouton setFont:[UIFont systemFontOfSize:22]];
    [validerBouton setBackgroundImage:[UIImage imageNamed:@"BOUTON VALIDATION.png"] forState:UIControlStateNormal];
    [validerBouton addTarget:self action:@selector(proceedWithAddProduct) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:validerBouton];
    
    [self.scrollView setContentSize:CGSizeMake(320, 1055)];
    
    allElements = [[NSMutableArray alloc] initWithObjects:titreImage,titreTextField,genreBouton,genreLabelPicker,genreLabel,natureBouton,natureLabelPicker,natureLabel,typeBouton,typeLabelPicker,typeLabel,tailleImage,tailleTextField,marqueImage,marqueTextField,couleurImage,colorLabel,collectionColor,prixImage,prixTextField,saisonBouton,saisonLabelPicker,saisonLabel,collectionPhoto,photoBouton,photoLabel,collectionProduits,produitsLabel,produitsBouton,textViewImage,detailTextView,validerBouton, nil];
    arrayLabels = [NSArray arrayWithObjects:genreLabelPicker,natureLabelPicker,typeLabelPicker,saisonLabelPicker, nil];
    textFields = [NSArray arrayWithObjects:titreTextField,tailleTextField,marqueTextField,prixTextField, nil];
    imageTextFields = [[NSMutableArray alloc] initWithObjects:titreImage,tailleImage,marqueImage,prixImage, nil];
}

#pragma mark - ScrollView delegate

- (void)displayPickerView:(UIButton *)sender
{
    [self dismissKeyboard];
    alreadyDismiss = NO;
    if (indexOfBouton == 0)
    {
        currentArray = [[NSArray alloc] init];
        UILabel *temp = allElements[[allElements indexOfObject:sender]+2];
        if ([temp.text isEqualToString:@"   Genre"])
        {
            currentArray = arrayGender;
        }
        else if ([temp.text isEqualToString:@"   Nature"])
        {
            UILabel *gender = allElements[[allElements indexOfObject:sender]-2];
            if ([gender.text isEqualToString:@"Homme"])
            {
                currentArray = arrayNatureHomme;
            }
            else if ([gender.text isEqualToString:@"Femme"])
            {
                currentArray = arrayNatureFemme;
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Sélectionnez un Genre" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                return;
            }
        }
        else if ([temp.text isEqualToString:@"   Type"])
        {
            UILabel *gender = allElements[[allElements indexOfObject:sender]-5];
            UILabel *nature = allElements[[allElements indexOfObject:sender]-2];
            if (gender.text.length > 0)
            {
                if (nature.text.length > 0)
                {
                    currentArray = [self returnType:gender.text nature:nature.text];
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Sélectionnez une Nature" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    return;
                }
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Sélectionnez un Genre" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                return;
            }
        }
        else if ([temp.text isEqualToString:@"   Saison"])
        {
            currentArray = arraySaisons;
        }
        [self.scrollView setContentOffset:CGPointMake(0, sender.frame.origin.y - 20)];
        currentPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, sender.frame.origin.y + 58, 320, 162)];
        currentPickerView.dataSource = self;
        currentPickerView.delegate = self;
        currentPickerView.tag = [allElements indexOfObject:sender];
        currentPickerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BOUTON MD SEUL.png"]];
        [self.scrollView addSubview:currentPickerView];
        indexOfBouton = [allElements indexOfObject:sender];
        for (int i = [allElements indexOfObject:sender] + 3; i < allElements.count; i++)
        {
            CGRect tempFrame = [allElements[i] frame];
            tempFrame.origin.y += 172;
            [allElements[i] setFrame:tempFrame];
        }
        [self.scrollView setContentSize:CGSizeMake(320, self.scrollView.contentSize.height + 172)];
    }
    else
    {
        int indexOfSender = [allElements indexOfObject:sender];
        if (indexOfSender == indexOfBouton)
        {
            NSInteger selected = [currentPickerView selectedRowInComponent:0];
            [self dismissPickerView:currentArray[selected]];
        }
        else
        {
            [self dismissPickerView:[[allElements objectAtIndex:indexOfBouton+1] text]];
            [self displayPickerView:sender];
        }
    }
}

- (NSArray *)returnType:(NSString *)genre nature:(NSString *)nature
{
    NSArray *tempArray = [[NSArray alloc] init];
    if ([genre isEqualToString:@"Homme"])
    {
        if ([nature isEqualToString:@"Sport"])
        {
            tempArray = [NSArray arrayWithObjects:@"Maillots équipe de sports", @"Chaussures de sport", @"Vêtements de sport", @"Accessoires", @"Autres",nil];
        }
        else if ([nature isEqualToString:@"Déguisements"])
        {
            tempArray = [NSArray arrayWithObjects:@"Classique", nil];
        }
        else if ([nature isEqualToString:@"Pantalons"])
        {
            tempArray = [NSArray arrayWithObjects:@"Chino", @"Velours", @"Joggings", @"Salopettes", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Maillots de bain"])
        {
            tempArray = [NSArray arrayWithObjects:@"Slips", @"Shorts", @"Bermudas", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Costumes et Blazers"])
        {
            tempArray = [NSArray arrayWithObjects:@"Costumes", @"Vestes de costume", @"Blazers", @"Pantalons", @"Chemises de Costume", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Shorts"])
        {
            tempArray = [NSArray arrayWithObjects:@"Courts", @"Bermudas", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Chaussures"])
        {
            tempArray = [NSArray arrayWithObjects:@"Chaussures de ville", @"Bottes/Bottines", @"Baskets/Sneakers", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Chemises"])
        {
            tempArray = [NSArray arrayWithObjects:@"Décontractées", @"Habillées", @"Chemisettes", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"T-Shirt-Polos"])
        {
            tempArray = [NSArray arrayWithObjects:@"Tshirt uni", @"Tshirt à motifs", @"Débardeurs unis", @"Débardeurs à Motifs", @"Polos unis", @"Polos à Motifs", @"Les imprimés", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Pulls-Cardigans"])
        {
            tempArray = [NSArray arrayWithObjects:@"Pulls unis", @"Pulls à motifs", @"Cardigans unis", @"Cardigans à motifs", @"Tricots unis", @"Tricots à motifs", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Jeans"])
        {
            tempArray = [NSArray arrayWithObjects:@"Large", @"Droit", @"Slim", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Manteaux-Vestes"])
        {
            tempArray = [NSArray arrayWithObjects:@"Blousons en cuir", @"Blousons", @"Vestes", @"Vestes en jean", @"Surchemises", @"Manteaux d'hiver", @"Manteaux mi-saison", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Couvres-Chefs"])
        {
            tempArray = [NSArray arrayWithObjects:@"Bonnets", @"Casquettes", @"Chapeaux", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Sacs"])
        {
            tempArray = [NSArray arrayWithObjects:@"Sacs à dos", @"Sacoches", @"Sacs de voyage", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Accessoires"])
        {
            tempArray = [NSArray arrayWithObjects:@"Ceintures", @"Lunettes", @"Gants", @"Écharpes", @"Cravates", @"Portefeuilles", @"Montres", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Sweat-Shirts"])
        {
            tempArray = [NSArray arrayWithObjects:@"Sweats à capuche", @"Sweats unis", @"Sweats imprimés", @"Autres", nil];
        }
    }
    else if ([genre isEqualToString:@"Femme"])
    {
        if ([nature isEqualToString:@"Accessoires"])
        {
            tempArray = [NSArray arrayWithObjects:@"Ceintures", @"Lunettes", @"Gants", @"Écharpes/Foulards", @"Portefeuille/Porte monnaie", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Déguisements"])
        {
            tempArray = [NSArray arrayWithObjects:@"Classique", nil];
        }
        else if ([nature isEqualToString:@"Chemises"])
        {
            tempArray = [NSArray arrayWithObjects:@"Décontractées", @"Habillées", @"Chemisettes", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Sacs"])
        {
            tempArray = [NSArray arrayWithObjects:@"Pochettes", @"Sacs à dos", @"Sacs à main", @"Sacs de voyage", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Manteaux-Vestes"])
        {
            tempArray = [NSArray arrayWithObjects:@"Blazers", @"Blousons", @"Blousons en cuir", @"Vestes courtes", @"Vestes en jean", @"Manteaux d'hiver", @"Manteaux mi-saison", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Jeans"])
        {
            tempArray = [NSArray arrayWithObjects:@"Bootcut", @"Large", @"Slim", @"Droit", @"Taille haute", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Robes-Jupes"])
        {
            tempArray = [NSArray arrayWithObjects:@"Mini jupes", @"Jupes courtes", @"Jupes mi-longues", @"jupes en jean", @"Robes courtes", @"Robes longues", @"Robes mi-longues", @"Dos nu", @"Tuniques", @"Bustiers", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Sweat-Shirts"])
        {
            tempArray = [NSArray arrayWithObjects:@"Sweats à capuche", @"Sweats unis", @"Sweats imprimés", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Debardeurs"])
        {
            tempArray = [NSArray arrayWithObjects:@"Décontractées", @"Habillées", @"Chemisettes", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Tops"])
        {
            tempArray = [NSArray arrayWithObjects:@"Sans-manches unis", @"Sans-manches à motifs", @"Manches courtes unis", @"Manches courtes à motifs", @"Manches longues unis", @"Manches longues à motifs", @"Chemises et surchemisiers", @"Les imprimés", @"Hauts de soirées", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Pulls-Cardigans"])
        {
            tempArray = [NSArray arrayWithObjects:@"Pulls unis", @"Pulls à motifs", @"Cardigans unis", @"Cardigans à motifs", @"Tricots unis", @"Tricots à motifs", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Bijoux"])
        {
            tempArray = [NSArray arrayWithObjects:@"Montres", @"Bracelets", @"Boucles d'oreilles", @"Accessoires cheveux", @"Colliers/Pendentifs", @"Bagues", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Ensembles et Tailleurs"])
        {
            tempArray = [NSArray arrayWithObjects:@"Ensemble", @"Tailleur", @"Pantalon de costume", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Maillots de bain"])
        {
            tempArray = [NSArray arrayWithObjects:@"2 Pièces", @"1 Pièce", @"Dépareillés", @"Vêtements de plage", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Pantalons"])
        {
            tempArray = [NSArray arrayWithObjects:@"Droits", @"Évasés", @"Slim", @"Sarouel/Carotte", @"Tregging", @"Leggings", @"Salopettes", @"Combinaisons", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Shorts"])
        {
            tempArray = [NSArray arrayWithObjects:@"Shorts", @"Shorts en Jean", @"Minishorts", @"Combishort", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Chaussures"])
        {
            tempArray = [NSArray arrayWithObjects:@"Bottes/Bottines", @"Mocassins", @"Ballerines" ,@"Sandales", @"Sabots", @"Derbies", @"Escarpins", @"Boots", @"Baskets/Sneakers", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"T-Shirt-Débardeurs"])
        {
            tempArray = [NSArray arrayWithObjects:@"Tshirt uni", @"Tshirt à motifs", @"Débardeurs unis", @"Débardeurs à Motifs", @"Polos unis", @"Polos à Motifs", @"Les imprimés", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Sport"])
        {
            tempArray = [NSArray arrayWithObjects:@"Maillots équipe de sports", @"Chaussures de sport", @"Vêtements de sport", @"Accessoires", @"Autres", nil];
        }
        else if ([nature isEqualToString:@"Couvres-Chefs"])
        {
            tempArray = [NSArray arrayWithObjects:@"Bonnets", @"Casquettes", @"Chapeaux", @"Autres", nil];
        }
    }
    return tempArray;
}

- (void)addPhoto
{
    if (arrayPhotos.count < 5)
    {
        CameraCustomView *camera = [[CameraCustomView alloc] initWithFrame:self.view.frame];
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.showsCameraControls = NO;
        imagePicker.navigationBarHidden = YES;
        imagePicker.wantsFullScreenLayout = YES;
        //picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, CAMERA_TRANSFORM_X, CAMERA_TRANSFORM_Y);
        imagePicker.cameraOverlayView = camera;
        imagePicker.delegate = self;
        addPhotoOrProduits = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Vous pouvez ajouter au maximum 5 photos." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)addProduit
{
    if (arrayProduits.count < 10)
    {
        addPhotoOrProduits = NO;
        NSArray *linkProducts = [[NSUserDefaults standardUserDefaults] objectForKey:@"link_products"];
        if (linkProducts.count != 0)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ALAssetViewController *avc = [storyboard instantiateViewControllerWithIdentifier:@"ALAssetViewController"];
            avc.titleView = @"MES ARTICLES";
            avc.addProduct = YES;
            avc.fromInspiration = NO;
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

#pragma mark - Add product delegate

- (void)proceedWithAddProduct
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSArray *nameTextFields = [NSArray arrayWithObjects:@"name",@"size",@"brand",@"price", nil];
    NSArray *nameLabels = [NSArray arrayWithObjects:@"gender",@"nature",@"type",@"season", nil];
    for (int i = 0; i < textFields.count; i++)
    {
        if (![[imageTextFields[i] image] isEqual:[UIImage imageNamed:@"BOUTON CHAMP LIBRE PRET A VALIDER.png"]])
        {
            [[[UIAlertView alloc] initWithTitle:@"Champs incorrects" message:@"Veuillez compléter correctement tous les champs de texte. (Cadre vert)" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        [parameters setObject:[textFields[i] text] forKey:nameTextFields[i]];
    }
    for (int j = 0; j < arrayLabels.count; j++)
    {
        if ([[arrayLabels[j] text] length] == 0)
        {
            [[[UIAlertView alloc] initWithTitle:@"Champs incomplets" message:@"Veuillez compléter correctement toutes les informations." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        [parameters setObject:[arrayLabels[j] text] forKey:nameLabels[j]];
    }
    if (detailTextView.text.length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Description manquante" message:@"Veuillez compléter une description de votre article." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    [parameters setObject:detailTextView.text forKey:@"description"];
    for (int k = 0; k < arrayColors.count; k++)
    {
        UIColor *colorTemp = arrayColors[k];
        const CGFloat *components = CGColorGetComponents(colorTemp.CGColor);
        NSString *colorString = [NSString stringWithFormat:@"rgb(%i, %i, %i)",(int)(components[0]*255),(int)(components[1]*255),(int)(components[2]*255)];
        NSString *keyTemp = [NSString stringWithFormat:@"color%i",k+1];
        [parameters setObject:colorString forKey:keyTemp];
    }
    NSMutableArray *idProducts = [[NSMutableArray alloc] init];
    for (int l = 0; l < arrayProduits.count; l++)
    {
        [idProducts addObject:[arrayProduits[l] objectForKey:@"id"]];
    }
    if (arrayPhotos.count == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Photo manquante" message:@"Veuillez ajouter au moins une photo de votre article." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    for (int m = 0; m < arrayPhotos.count; m++)
    {
        [parameters setObject:[WebServices base64forData:UIImageJPEGRepresentation(arrayPhotos[m], 0.5)] forKey:[NSString stringWithFormat:@"photo%i",m+1]];
    }
    [parameters setObject:idProducts forKey:@"products_id"];
    [parameters setObject:@"ios" forKey:@"device"];
    [self startAddProduct:parameters];
}

- (void)startAddProduct:(NSDictionary *)products
{
    //waitingDialog = [[UIAlertView alloc] initWithTitle:@"Ajout en cours .." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    //[waitingDialog show];
    [SVProgressHUD showWithStatus:@"Ajout en cours"];
    [self performSelector:@selector(addProductWebServices:) withObject:products afterDelay:0.3];
}

- (void)addProductWebServices:(NSDictionary *)products
{
    BOOL addProduct = [WebServices addProduct:products with:arrayPhotos];
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

#pragma mark - CameraCustom delegate

- (void)dismissArticle
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pictureArticle
{
    [imagePicker takePicture];
}

- (void)pelliculeArticle
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
            UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage] fixOrientation];
            if (addPhotoOrProduits)
            {
                //[arrayPhotos addObject:UIImagePNGRepresentation(image)];
                [arrayPhotos addObject:image];
                [collectionPhoto reloadData];
                [self reorderScroll:collectionPhoto];
            }
            else
            {
                [arrayProduits addObject:UIImagePNGRepresentation(image)];
                [collectionProduits reloadData];
                [self reorderScroll:collectionProduits];
            }
        }
    }}];
}

- (void)receivePicture:(NSNotification *)note
{
    if (addPhotoOrProduits)
    {
        //[arrayPhotos addObject:imageTemp];
        [collectionPhoto reloadData];
        [self reorderScroll:collectionPhoto];
    }
    else
    {
        //[arrayProduits addObject:[UIImage imageWithData:[[note userInfo] objectForKey:@"picture"]]];
        [collectionProduits reloadData];
        [self reorderScroll:collectionProduits];
    }
}

- (void)reorderScroll:(UICollectionView *)collection
{
    CGRect previousFrame = collection.frame;
    if (collection == collectionPhoto)
    {
        previousFrame.size.height = ceil(((float)arrayPhotos.count)/2)*203;
        if (arrayPhotos.count > 0)
        {
            photoLabel.text = [NSString stringWithFormat:@"   Ajouter Photo (%i)",5-arrayPhotos.count];
        }
        else
            photoLabel.text = @"   Ajouter Photo (5)";
    }
    else
    {
        previousFrame.size.height = ceil(((float)arrayProduits.count)/4)*80;
        if (arrayProduits.count > 0)
        {
            produitsLabel.text = [NSString stringWithFormat:@"   Je le porte avec (%i)",10-arrayProduits.count];
        }
        else
        {
            produitsLabel.text = @"   Je le porte avec (10)";
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
    if (collectionView == collectionPhoto)
    {
        numberOfItems = arrayPhotos.count;
    }
    else if (collectionView == collectionProduits)
    {
        numberOfItems = arrayProduits.count;
    }
    else if (collectionView == collectionColor)
    {
        numberOfItems = dataColors.count;
    }
    NSLog(@"items : %i",numberOfItems);
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (collectionView == collectionPhoto)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        imageV.contentMode = UIViewContentModeScaleAspectFit;
        //imageV.image = [UIImage imageWithData:[arrayPhotos objectAtIndex:indexPath.row]];
        imageV.image = [arrayPhotos objectAtIndex:indexPath.row];
        [cell addSubview:imageV];
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(115, 0, 30, 30);
        deleteButton.tag = indexPath.row;
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"BOUTON MOINS.png"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deletePictureFromPhotos:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:deleteButton];
    }
    else if (collectionView == collectionProduits)
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
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
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
    else if (collectionView == collectionColor)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"colorCell" forIndexPath:indexPath];
        cell.layer.cornerRadius = 3;
        cell.backgroundColor = dataColors[indexPath.row];
        cell.alpha = 1;
        for (UIColor *colorInArray in arrayColors)
        {
            if ([colorInArray isEqual:dataColors[indexPath.row]])
            {
                cell.alpha = 0.2;
            }
        }
    }
    return cell;
}

#pragma mark - CollectionView delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == collectionPhoto)
    {
        NSArray *temp = [[NSArray alloc] initWithArray:arrayPhotos copyItems:YES];
        UIImage *imageTemp2 = [temp objectAtIndex:indexPath.row];
        if (imageTemp2.size.width > imageTemp2.size.height)
        {
            return CGSizeMake(145, 109);
        }
        else
            return CGSizeMake(145, 193);
    }
    else if (collectionView == collectionProduits)
    {
        return CGSizeMake(70, 70);
    }
    else if (collectionView == collectionColor)
    {
        return CGSizeMake(30, 30);
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == collectionColor)
    {
        BOOL colorAlreadyAdded = NO;
        for (UIColor *color in arrayColors)
        {
            if (color == dataColors[indexPath.row])
            {
                colorAlreadyAdded = YES;
            }
        }
        if (colorAlreadyAdded)
        {
            [arrayColors removeObject:dataColors[indexPath.row]];
        }
        else if (arrayColors.count < 3)
        {
            [arrayColors addObject:dataColors[indexPath.row]];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Vous ne pouvez sélectionner que 3 couleurs" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    [collectionColor reloadData];
}

- (void)deletePictureFromPhotos:(UIButton *)sender
{
    [arrayPhotos removeObjectAtIndex:sender.tag];
    [collectionPhoto reloadData];
    [self reorderScroll:collectionPhoto];
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
    return currentArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return currentArray[row];
}

#pragma mark - PickerView delegate

- (void)dismissPickerView:(NSString *)text
{
    UILabel *pickerLabel = [allElements objectAtIndex:indexOfBouton+1];
    pickerLabel.text = text;
    for (int i = 0; i < self.scrollView.subviews.count; i++)
    {
        id object = [self.scrollView.subviews objectAtIndex:i];
        if ([object isKindOfClass:[UIPickerView class]])
        {
            [[self.scrollView.subviews objectAtIndex:i]  removeFromSuperview];
        }
    }
    for (int i = indexOfBouton + 3; i < allElements.count; i++)
    {
        CGRect tempFrame = [[allElements objectAtIndex:i] frame];
        tempFrame.origin.y -= 172;
        [[allElements objectAtIndex:i] setFrame:tempFrame];
    }
    indexOfBouton = 0;
    [self.scrollView setContentSize:CGSizeMake(320, self.scrollView.contentSize.height - 172)];
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
    else if (textField == textFields[1])
    {
        if (newString.length == 0)
        {
            [imageTextFields[1] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE.png"]];
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
                [imageTextFields[1] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE PRET A VALIDER.png"]];
                if (NSEqualRanges(rangeNewMatch, rangeOldMatch))
                {
                    return NO;
                }
            }
            else
            {
                [imageTextFields[1] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE ERREUR.png"]];
            }
        }
    }
    else if (textField == textFields[2])
    {
        if (newString.length == 0)
        {
            [imageTextFields[2] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE.png"]];
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
                [imageTextFields[2] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE PRET A VALIDER.png"]];
                if (NSEqualRanges(rangeNewMatch, rangeOldMatch))
                {
                    return NO;
                }
            }
            else
            {
                [imageTextFields[2] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE ERREUR.png"]];
            }
        }
    }
    else if (textField == textFields[3])
    {
        if (newString.length == 0)
        {
            [imageTextFields[3] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE.png"]];
        }
        else
        {
            NSString *expression = @"[0-9]{1,5}";
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
            NSRange rangeNewMatch = [regex rangeOfFirstMatchInString:newString options:0 range:NSMakeRange(0, newString.length)];
            NSRange rangeOldMatch = [regex rangeOfFirstMatchInString:textField.text options:0 range:NSMakeRange(0, textField.text.length)];
            if (!NSEqualRanges(rangeNewMatch, NSMakeRange(NSNotFound, 0)))
            {
                [imageTextFields[3] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE PRET A VALIDER.png"]];
                if (NSEqualRanges(rangeNewMatch, rangeOldMatch))
                {
                    return NO;
                }
            }
            else
            {
                [imageTextFields[3] setImage:[UIImage imageNamed:@"BOUTON CHAMP LIBRE ERREUR.png"]];
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
