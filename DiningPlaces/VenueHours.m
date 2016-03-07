//
//  VenueHours.m
//  DiningPlaces
//
//  Created by Irfan Lone on 3/6/16.
//  Copyright © 2016 Yuzu. All rights reserved.
//

#import "VenueHours.h"
#import "Transport.h"
#import "AppDelegate.h"

@implementation VenueHours

+ (BOOL)isVenueOpen:(Venue*)venue {
    
//    NSString * baseUrl = @"https://api.foursquare.com/v2/venues/";
//    NSString * venueId = venue.identifier;
//    NSString * operation = @"/hours?";
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyyMMdd"];
//    NSString * dateStr = [dateFormat stringFromDate:[NSDate date]];
//    NSString * urlString = [NSString stringWithFormat:@"%@%@%@&client_id=%@&client_secret=%@&v=%@",baseUrl,venueId,operation,kCLIENTID,kCLIENTSECRET,dateStr];
//    NSURL * url = [NSURL URLWithString:urlString];
//    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
//    Transport * transport = [[Transport alloc] init];
//    [transport retrieve:request completionBlock:^(BOOL success, TransportResponseObject *responseObject) {
//        if(success) {
//            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject.data options:0 error:nil];
//            NSArray *response = [jsonArray valueForKey:@"response"];
//            NSArray *hours = [response valueForKey:@"hours"];
//            NSArray *timeframes = [hours valueForKey:@"timeframes"];
//            
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay) fromDate:[NSDate date]];
//            NSInteger hour = [components hour];
//            NSInteger minute = [components minute];
//            NSInteger day = [components day] + 1;
//            
//            NSArray * openTimeFrame = nil;
//            for (NSDictionary * dict in timeframes) {
//                NSArray * days = [dict valueForKey:@"days"];
//                if ([days containsObject:@(day)]) {
//                    openTimeFrame = [dict valueForKey:@"open"];
//                    break;
//                }
//            }
//            if (openTimeFrame) {
//                for (NSDictionary * dict in openTimeFrame) {
//                    NSNumber * startTime = [dict valueForKey:@"open"];
//                    NSNumber * endTime = [dict valueForKey:@"open"];
//                    
//                    // check
//                    if (hour*10+minute >= [startTime integerValue] && hour*10+minute <= [endTime integerValue]) {
//                    }
//                }
//            }
//            NSLog(@"%ld%ld%ld",hour,(long)minute,(long)day);
//        }
//    }];
    
    return YES;
}



@end
