//
//  MasterViewController.m
//  DiningPlaces
//
//  Created by Irfan Lone on 3/5/16.
//  Copyright © 2016 Yuzu. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Transport.h"
#import "Venue.h"
#import "VenueCell.h"
#import <CoreLocation/CoreLocation.h>


#define kCLIENTID @"2M4QBWYTS5GO3EJGQYK3USK5XM0JZ0SFBELQBQPAKUFKXQ2L"
#define kCLIENTSECRET @"TNYFKM4SNJVC4QTOZ2HWOZEUQGSXWZNCR0EYMHPOQNTF4GHG"

@interface MasterViewController ()<CLLocationManagerDelegate>

@property (nonatomic,strong) NSMutableArray<Venue*> * venues;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CLLocation * currentLocation;

@end


@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/*
 NSURL * url = [NSURL URLWithString:@"https://api.foursquare.com/v2/venues/search?categoryId=4bf58dd8d48988d1e0931735&client_id=TZM5LRSRF1QKX1M2PK13SLZXRXITT2GNMB1NN34ZE3PVTJKT&client_secret=250PUUO4N5P0ARWUJTN2KHSW5L31ZGFDITAUNFWVB5Q4WJWY&ll=37.33%2C-122.03&v=20140118"];
 */
- (void)loadVenues {
    NSString * baseUrl = @"https://api.foursquare.com/";
    NSString * operation = @"v2/venues/search?";
    NSString * categoryId = @"4bf58dd8d48988d1e0931735";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString * dateStr = [dateFormat stringFromDate:[NSDate date]];
    NSString * urlString = [NSString stringWithFormat:@"%@%@categoryId=%@&client_id=%@&client_secret=%@&ll=%f%%2C%f&v=%@",baseUrl,operation,categoryId,kCLIENTID,kCLIENTSECRET,self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude,dateStr];
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    Transport * transport = [[Transport alloc] init];
    [transport retrieve:request completionBlock:^(BOOL success, TransportResponseObject *responseObject) {
        if(success) {
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject.data options:0 error:nil];
            [self createVenueObjecsFromResponseData:jsonArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)createVenueObjecsFromResponseData:(NSArray*)jsonArray {
 
    NSArray * response = [jsonArray valueForKey:@"response"];
    NSArray * venues = [response valueForKey:@"venues"];
    if(!self.venues) {
        self.venues = [NSMutableArray array];
    }
    for (int i = 0; i < [venues count]; i++) {
        id venueItem = [venues objectAtIndex:i];
        Venue * newObj = [[Venue alloc] init];
        newObj.name = [venueItem valueForKey:@"name"];
        NSDictionary * address = [venueItem valueForKey:@"location"];
        NSString * venueAddr = [NSString stringWithFormat:@"%@ %@",[address valueForKey:@"address"],[address valueForKey:@"city"]];
        newObj.address = venueAddr;
        newObj.distance = [address valueForKey:@"distance"];
        newObj.website = [venueItem valueForKey:@"url"];
        newObj.menu = [[venueItem valueForKey:@"menu"] valueForKey:@"mobileUrl"];
        newObj.phoneNumber = [[venueItem valueForKey:@"contact"] valueForKey:@"formattedPhone"];
        newObj.checkins = [[venueItem valueForKey:@"stats"] valueForKey:@"checkinsCount"];
        newObj.usersCount = [[venueItem valueForKey:@"contact"] valueForKey:@"usersCount"];
        [self.venues addObject:newObj];
    }
}

#pragma locationManager

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if(!self.currentLocation) {
        self.currentLocation = [[CLLocation alloc] init];
    }
    self.currentLocation = newLocation;
    [self loadVenues];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSDate *object = self.objects[indexPath.row];
//        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
//        [controller setDetailItem:object];
//        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VenueCell *cell = (VenueCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Venue * venueItem = [self.venues objectAtIndex:indexPath.row];
    cell.venueName.text = venueItem.name;
    cell.venueAddresss.text = venueItem.address;
    cell.venueDistance.text = [venueItem.distance stringValue];
    return cell;
}

@end
