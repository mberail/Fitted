//
//  CameraCustomView.m
//  Fitted
//
//  Created by Maxime Berail on 10/01/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import "CameraCustomView.h"

@implementation CameraCustomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        UIImageView *upperView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height - 100, 320, 100)];
        upperView.image = [UIImage imageNamed:@"BANDEAU PHOTO.png"];
        upperView.opaque = NO;
        [self addSubview:upperView];
        
        UIButton *pictureButton = [[UIButton alloc] initWithFrame:CGRectMake(125, frame.size.height - 75, 70, 50)];
        [pictureButton setImage:[UIImage imageNamed:@"PICTO PHOTO.png"] forState:UIControlStateNormal];
        [pictureButton addTarget:self action:@selector(pictureCustom) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pictureButton];
        
        UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(20, frame.size.height - 70, 40, 40)];
        [dismissButton setImage:[UIImage imageNamed:@"BOUTON RETOUR 2.png"] forState:UIControlStateNormal];
        [dismissButton addTarget:self action:@selector(dismissCustom) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dismissButton];
        
        UIButton *pelliculeButton = [[UIButton alloc] initWithFrame:CGRectMake(260, frame.size.height - 70, 40, 43)];
        [pelliculeButton setImage:[UIImage imageNamed:@"BOUTON PELLICULE.png"] forState:UIControlStateNormal];
        [pelliculeButton addTarget:self action:@selector(pelliculeCustom) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pelliculeButton];
    }
    return self;
}

- (void)pictureCustom
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pictureArticle" object:nil];
}

- (void)dismissCustom
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissArticle" object:nil];
}

- (void)pelliculeCustom
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pelliculeArticle" object:nil];
}

@end
