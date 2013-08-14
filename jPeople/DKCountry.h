//
//  DKCountry.h
//  jPeople
//
//  Created by Dmitry on 5/6/13.
//  Copyright (c) 2013 Dmitrii Cucleschin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKCountry : NSObject {

}

+(UIImage*) iconForCountry: (NSString*)country;

@property (nonatomic,strong) NSDictionary *countryNamesByCode;
@property (nonatomic,strong) NSDictionary *countryCodesByName;

@end
