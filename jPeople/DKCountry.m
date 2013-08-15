//
//  DKCountry.m
//  jPeople
//
//  Created by Dmitry on 5/6/13.
//  Copyright (c) 2013 Dmitrii Cucleschin. All rights reserved.
//

#import "DKCountry.h"

@implementation DKCountry

@synthesize countryCodesByName;
@synthesize countryNamesByCode;

+(UIImage*) iconForCountry: (NSString*)country {
    
    DKCountry *manager = [[DKCountry alloc]init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Countries" ofType:@"plist"];
    manager.countryNamesByCode = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSMutableDictionary *codesByName = [NSMutableDictionary dictionary];
    for (NSString *code in [manager.countryNamesByCode allKeys])
    {
        [codesByName setObject:code forKey:[manager.countryNamesByCode objectForKey:code]];
    }
    manager.countryCodesByName = [codesByName copy];
    
    UIImage *result = [UIImage imageNamed:[manager.countryCodesByName valueForKey:country]];
    
    if (result)
        return result;
    else {
        NSLog(@"Warning! Image for country (%@) was not found!",country);
        return [UIImage imageNamed:@"_United-Nations"];
    }
}

@end
