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

#define kCLIENTID @"2M4QBWYTS5GO3EJGQYK3USK5XM0JZ0SFBELQBQPAKUFKXQ2L"
#define kCLIENTSECRET @"TNYFKM4SNJVC4QTOZ2HWOZEUQGSXWZNCR0EYMHPOQNTF4GHG"

@interface MasterViewController ()

@property (nonatomic,strong) NSMutableArray<Venue*> * venues;

@end


@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [self loadVenues];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadVenues {
    //NSString * baseUrl = @"https://api.foursquare.com/";
    //NSString * operation = @"v2/venues/search?";
    //categoryId=4bf58dd8d48988d1e0931735&client_id=TZM5LRSRF1QKX1M2PK13SLZXRXITT2GNMB1NN34ZE3PVTJKT&client_secret=250PUUO4N5P0ARWUJTN2KHSW5L31ZGFDITAUNFWVB5Q4WJWY&ll=37.33%2C-122.03&v=20160101
    NSURL * url = [NSURL URLWithString:@"https://api.foursquare.com/v2/venues/search?categoryId=4bf58dd8d48988d1e0931735&client_id=TZM5LRSRF1QKX1M2PK13SLZXRXITT2GNMB1NN34ZE3PVTJKT&client_secret=250PUUO4N5P0ARWUJTN2KHSW5L31ZGFDITAUNFWVB5Q4WJWY&ll=37.33%2C-122.03&v=20140118"];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    Transport * transport = [[Transport alloc] init];
    [transport retrieve:request completionBlock:^(BOOL success, TransportResponseObject *responseObject) {
        if(success) {
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject.data options:0 error:nil];
            // create venue objects from the response data
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

- (void)insertNewObject:(id)sender {
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//    [self.objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
