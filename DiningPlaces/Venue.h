//
//  Venue.h
//  DiningPlaces
//
//  Created by Irfan Lone on 3/5/16.
//  Copyright © 2016 Yuzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Venue : NSObject

@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * address;
@property (nonatomic, strong) NSString * website;
@property (nonatomic, strong) NSString * menuUrl;
@property (nonatomic, strong) NSString * phoneNumber;
@property (nonatomic, strong) NSNumber * checkins;
@property (nonatomic, strong) NSNumber * usersCount;
@property (nonatomic, strong) NSNumber * distance;

@end
