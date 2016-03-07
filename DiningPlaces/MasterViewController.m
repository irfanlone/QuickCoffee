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
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "VenueHours.h"

@interface MasterViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray<Venue*> * venues;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation * currentLocation;
@property (nonatomic, strong) NSIndexPath * selectedIndexpath;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSMutableArray<Venue*> * filteredVenueList;

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
}

-(void)loadView {
    [super loadView];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.color = [UIColor grayColor];
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect viewBounds = self.tableView.bounds;
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.filterRadiusValue) {
        self.filteredVenueList = [NSMutableArray array];
        NSInteger radius = [appDelegate.filterRadiusValue integerValue] * 1000;
        for (Venue * item in self.venues) {
            if ([item.distance integerValue] <= radius) {
                [self.filteredVenueList addObject:item];
            }
        }
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

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
                [self.activityIndicator stopAnimating];
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
        newObj.menuUrl = [[venueItem valueForKey:@"menu"] valueForKey:@"mobileUrl"];
        newObj.phoneNumber = [[venueItem valueForKey:@"contact"] valueForKey:@"formattedPhone"];
        newObj.checkins = [[venueItem valueForKey:@"stats"] valueForKey:@"checkinsCount"];
        newObj.usersCount = [[venueItem valueForKey:@"contact"] valueForKey:@"usersCount"];
        newObj.identifier = [venueItem valueForKey:@"id"];
        [self.venues addObject:newObj];
    }
    
    // sort the list based on distance
    [self.venues sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [[obj1 distance] compare:[obj2 distance]];
    }];
    if (!self.filteredVenueList) {
        self.filteredVenueList = [[NSMutableArray alloc] initWithArray:self.venues];
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
        DetailViewController * deatailVC = [segue destinationViewController];
        deatailVC.venue = self.filteredVenueList[self.selectedIndexpath.row];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredVenueList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VenueCell *cell = (VenueCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Venue * venueItem = [self.filteredVenueList objectAtIndex:indexPath.row];
    cell.venueName.text = venueItem.name;
    cell.venueAddresss.text = venueItem.address;
    float miles = [venueItem.distance integerValue] / 1000.0;
    cell.venueDistance.text = [NSString stringWithFormat:@"%0.2f miles",miles];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [VenueHours isVenueOpen:self.venues[indexPath.row]];

    
    self.selectedIndexpath = indexPath;
    [self performSegueWithIdentifier:@"showDetail" sender:self];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
