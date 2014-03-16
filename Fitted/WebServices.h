//
//  WebServices.h
//  Fitted
//
//  Created by Maxime Berail on 18/02/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServices : NSObject

+ (NSString *)base64forData:(NSData *)theData;
+ (BOOL)login:(NSArray *)parameters;
+ (BOOL)loginFacebook:(NSString *)idFacebook;
+ (id)sendDataByGetAtUrl:(NSString *)url;
+ (BOOL)addProduct:(NSDictionary *)parameters with:(NSArray *)photos;
+ (BOOL)addInspiration:(NSDictionary *)parameters with:(NSArray *)photos;
+ (BOOL)amIConnected;
+ (void)logout;

@end
