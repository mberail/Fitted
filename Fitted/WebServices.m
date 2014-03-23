//
//  WebServices.m
//  Fitted
//
//  Created by Maxime Berail on 18/02/14.
//  Copyright (c) 2014 Maxime Berail. All rights reserved.
//

#import "WebServices.h"
#import "ImageCache.h"

@implementation WebServices

+ (NSString *)md5:(NSString *)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

+ (NSString *)base64forData:(NSData *)theData
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

/*+ (id)sendDataByPost:(NSDictionary *)parameters atUrl:(NSString *)url with:(NSArray *)photos
{
    NSLog(@"url : %@",url);
    NSError *error;
    NSMutableData *requestData = [NSMutableData data];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSString *authStr = [NSString stringWithFormat:@"JBaise:Jfeet!IDE"];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [self base64forData:authData]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"POST"];
    //[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    for (int j = 0; j < [parameters count]; j++)
    {
        NSString *appendString = [NSString stringWithFormat:@"------WebKitFormBoundaryTA9Y9uVvwxakiNeH Content-Disposition: form-data; name=\"%@\" %@",[[parameters allKeys] objectAtIndex:j],[[parameters allValues] objectAtIndex:j]];
        [requestData appendData:[appendString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    for (int i = 0; i < photos.count; i++)
    {
        NSString *appendDataString = [NSString stringWithFormat:@"\r\n--%@\r\n Content-Disposition: form-data; name=\"photo%i\"; filename=\"photo%i.jpg\" Content-Type: image/jpeg",boundary,i+1,i+1];
        [requestData appendData:[appendDataString dataUsingEncoding:NSUTF8StringEncoding]];
        [requestData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [requestData appendData:UIImageJPEGRepresentation(photos[i], 0.5)];
        [requestData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [request addValue:[NSString stringWithFormat:@"%lu",(unsigned long)requestData.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:requestData];
    NSLog(@"request after length : %i",requestData.length);
    NSLog(@"request : %@",[[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding]);
    NSHTTPURLResponse *response = nil;
    NSError *errors = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errors];
    //NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    return responseData;
}*/

+ (id)sendDataByPost:(NSDictionary *)parameters atUrl:(NSString *)url with:(NSArray *)photos
{
    NSLog(@"url : %@",url);
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *authStr = [NSString stringWithFormat:@"JBaise:Jfeet!IDE"];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [self base64forData:authData]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    [request addValue:[NSString stringWithFormat:@"%lu",(unsigned long)requestData.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:requestData];
    NSHTTPURLResponse *response = nil;
    NSError *errors = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errors];
    NSLog(@"responsePost : %@",[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    return responseData;
}

+ (id)sendDataByGetAtUrl:(NSString *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *authStr = [NSString stringWithFormat:@"JBaise:Jfeet!IDE"];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [self base64forData:authData]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response = nil;
    NSError *errors = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errors];
    return responseData;
}

+ (BOOL)login:(NSArray *)parameters
{
    NSString *urlGet = [NSString stringWithFormat:@"%@connect/connectIphone?COemail_address=%@&COpassword=%@",kURL,parameters[0],parameters[1]];
    if ([self sendDataByGetAtUrl:urlGet] != nil)
    {
        NSString *stringData = [[NSString alloc] initWithData:[self sendDataByGetAtUrl:urlGet] encoding:NSUTF8StringEncoding];
        if ([stringData isEqualToString:@"not ok"])
        {
            return 0;
        }
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:[self sendDataByGetAtUrl:urlGet] options:NSJSONReadingMutableContainers error:nil];
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        [pref setInteger:[[dictData objectForKey:@"id"] integerValue] forKey:@"id"];
        [pref setObject:[dictData objectForKey:@"pseudo"] forKey:@"pseudo"];
        [pref setObject:parameters[0] forKey:@"email"];
        [pref setObject:parameters[1] forKey:@"pass"];
        [self getProductsFromUser:[dictData objectForKey:@"pseudo"]];
        return 1;
    }
    else
    {
        return 0;
    }
}

+ (BOOL)loginFacebook:(NSString *)idFacebook
{
    NSString *urlPost = [NSString stringWithFormat:@"%@connect/facebookConnectMobile",kURL];
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] init];
    NSString *para = [NSString stringWithFormat:@"ad61dqsd%@6ad1sd31a",idFacebook];
    [mutDict setObject:[self md5:para] forKey:@"user_profile"];
    NSData *responseData = [self sendDataByPost:mutDict atUrl:urlPost with:nil];
    if (responseData != nil)
    {
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (dictData.count > 1)
        {
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            [pref setInteger:[[dictData objectForKey:@"id"] integerValue] forKey:@"id"];
            [pref setObject:[dictData objectForKey:@"pseudo"] forKey:@"pseudo"];
            [pref setObject:[dictData objectForKey:@"email_address"] forKey:@"email"];
            [self getProductsFromUser:[dictData objectForKey:@"pseudo"]];
            return 1;
        }
    }
    return 0;
}

+ (void)logout
{
    NSString *urlGet = [NSString stringWithFormat:@"%@connect/deconnexion",kURL];
    [self sendDataByGetAtUrl:urlGet];
}

+ (void)getProductsFromUser:(NSString *)pseudo
{
    NSString *urlGet = [NSString stringWithFormat:@"%@search/loadThumbProduct?sh_owner=%@",kURL,pseudo];
    urlGet = [urlGet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([self sendDataByGetAtUrl:urlGet] != nil)
    {
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:[self sendDataByGetAtUrl:urlGet] options:NSJSONReadingMutableContainers error:nil];
        NSArray *temp = [[NSArray alloc] init];
        if ([[dictData objectForKey:@"prodfile"] count] > 0)
        {
            temp = [dictData objectForKey:@"prodfile"];
        }
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        [pref setObject:temp forKey:@"link_products"];
        
        [self cacheThumbProducts:temp];
    }
}

+ (void)cacheThumbProducts:(NSArray *)products
{
    for (NSDictionary *dictProduct in products)
    {
        UIImage *imgCache = [[UIImage alloc] init];
        NSString *pathUrl = [dictProduct objectForKey:@"product_image"];
        NSRange rangePath = NSMakeRange(0, pathUrl.length - 4);
        NSString *thumbUrl = [NSString stringWithFormat:@"%@webroot/images/products/%@_thumb.jpg",kURL,[pathUrl substringWithRange:rangePath]];
        if ([[ImageCache sharedImageCache] doesExist:thumbUrl] == NO)
        {
            NSData *imageData = [self sendDataByGetAtUrl:thumbUrl];
            imgCache = [UIImage imageWithData:imageData];
            if (imgCache != nil)
                [[ImageCache sharedImageCache] addImage:thumbUrl with:imgCache];
        }
    }
}

+ (BOOL)addProduct:(NSDictionary *)parameters with:(NSArray *)photos
{
    NSString *postUrl = [NSString stringWithFormat:@"%@product/add",kURL];
    NSData *responseData = [self sendDataByPost:parameters atUrl:postUrl with:photos];
    if (responseData != nil && responseData.length > 0)
    {
        NSString *stringData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        if ([[stringData substringWithRange:NSMakeRange(stringData.length-1, 1)] intValue] == 1)
        {
            NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
            [self getProductsFromUser:[preferences objectForKey:@"pseudo"]];
            return 1;
        }
    }
    return 0;
}

+ (BOOL)addInspiration:(NSDictionary *)parameters with:(NSArray *)photos
{
    NSString *postUrl = [NSString stringWithFormat:@"%@inspiration/add",kURL];
    NSData *responseData = [self sendDataByPost:parameters atUrl:postUrl with:photos];
    if (responseData != nil && responseData.length > 0)
    {
        NSString *stringData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        if ([[stringData substringWithRange:NSMakeRange(stringData.length-1, 1)] intValue] == 1)
        {
            return 1;
        }
    }
    return 0;
}

+ (BOOL)amIConnected
{
    NSString *getUrl = [NSString stringWithFormat:@"%@connect/amIConnected",kURL];
    NSData *response = [self sendDataByGetAtUrl:getUrl];
    if (response != nil)
    {
        NSString *stringResponse = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        if ([stringResponse isEqualToString:@"Connected"])
        {
            return 1;
        }
    }
    return 0;
}

@end
