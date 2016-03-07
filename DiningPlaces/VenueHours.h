//
//  VenueHours.h
//  DiningPlaces
//
//  Created by Irfan Lone on 3/6/16.
//  Copyright © 2016 Yuzu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Venue.h"


@interface VenueHours : NSObject

+ (BOOL)isVenueOpen:(Venue*)venue;

@end
