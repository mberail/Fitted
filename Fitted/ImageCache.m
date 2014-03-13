//
//  ImageCache.m
//  Fitted
//
//  Created by Maxime Berail on 21/02/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import "ImageCache.h"

@implementation ImageCache

@synthesize imgCache;

static ImageCache* sharedImageCache = nil;

+ (ImageCache*)sharedImageCache
{
    @synchronized([ImageCache class])
    {
        if (!sharedImageCache)
            sharedImageCache= [[self alloc] init];
        return sharedImageCache;
    }
    return nil;
}

+ (id)alloc
{
    @synchronized([ImageCache class])
    {
        NSAssert(sharedImageCache == nil, @"Attempted to allocate a second instance of a singleton.");
        sharedImageCache = [super alloc];
        
        return sharedImageCache;
    }
    
    return nil;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        imgCache = [[NSCache alloc] init];
    }
    
    return self;
}

- (void)addImage:(NSString *)imageURL with:(UIImage *)image
{
    [imgCache setObject:image forKey:imageURL];
}

- (UIImage *)getImage:(NSString *)imageURL
{
    return [imgCache objectForKey:imageURL];
}

- (BOOL)doesExist:(NSString *)imageURL
{
    if ([imgCache objectForKey:imageURL] == nil)
    {
        return false;
    }
    
    return true;
}

@end
