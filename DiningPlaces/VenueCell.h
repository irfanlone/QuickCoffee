//
//  VenueCell.h
//  DiningPlaces
//
//  Created by Irfan Lone on 3/5/16.
//  Copyright © 2016 Yuzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *venueName;
@property (weak, nonatomic) IBOutlet UILabel *venueAddresss;
@property (weak, nonatomic) IBOutlet UILabel *venueDistance;
@property (weak, nonatomic) IBOutlet UILabel *openNowLabel;

@end
