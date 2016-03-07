//
//  FavouritesViewController.m
//  DiningPlaces
//
//  Created by Irfan Lone on 3/6/16.
//  Copyright © 2016 Yuzu. All rights reserved.
//

#import "FavouritesViewController.h"
#import "Venue.h"
#import "VenueCell.h"
#import "AppDelegate.h"
#import "DetailViewController.h"

@interface FavouritesViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong) NSMutableArray<Venue*> * favouriteVenues;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath * selectedIndexpath;

@end

@implementation FavouritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.favouriteVenues = [NSMutableArray array];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext * moc = [appDelegate managedObjectContext];
    NSArray * starredVenues = [self managedObjectsForClass:@"FavouriteVenue" InManagedObjectContext:moc];
    [self managedObjectsToVenuesfromArray:starredVenues];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favouriteVenues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VenueCell *cell = (VenueCell*)[tableView dequeueReusableCellWithIdentifier:@"FCell" forIndexPath:indexPath];
    Venue * venueItem = [self.favouriteVenues objectAtIndex:indexPath.row];
    cell.venueName.text = venueItem.name;
    cell.venueAddresss.text = venueItem.address;
    float miles = [venueItem.distance integerValue] / 1000.0;
    cell.venueDistance.text = [NSString stringWithFormat:@"%0.2f miles",miles];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Venue * itemToDelete = self.favouriteVenues[indexPath.row];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext * moc = [appDelegate managedObjectContext];
        [moc performBlockAndWait:^{
            NSManagedObjectID * objectID = (NSManagedObjectID*)itemToDelete.objectID;
            NSManagedObject * object =[moc existingObjectWithID:objectID error:nil];
            if (object) {
                [moc deleteObject:object];
                [moc save:nil];
            } else {
                NSAssert(NO, @"Failed to retrieve object from core data that needs to be delete");
            }
        }];
        [self.favouriteVenues removeObject:itemToDelete];
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexpath = indexPath;
    [self performSegueWithIdentifier:@"FavouritesShowDetail" sender:self];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *)managedObjectsForClass:(NSString *)className InManagedObjectContext:(NSManagedObjectContext*)moc {
    __block NSArray *results = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
    fetchRequest.sortDescriptors = @[ sort ];
    NSPredicate *predicate = nil;
    [fetchRequest setPredicate:predicate];
    [moc performBlockAndWait:^{
        NSError *error = nil;
        results = [moc executeFetchRequest:fetchRequest error:&error];
    }];
    return results;
}

- (void)managedObjectsToVenuesfromArray:(NSArray*)array {
    for (NSManagedObject * obj in array) {
        Venue * newVenue = [[Venue alloc] init];
        newVenue.name = [obj valueForKey:@"name"];
        newVenue.address = [obj valueForKey:@"address"];
        newVenue.website = [obj valueForKey:@"website"];
        newVenue.distance = [obj valueForKey:@"distance"];
        newVenue.objectID = [obj valueForKey:@"objectID"];
        newVenue.identifier = [obj valueForKey:@"identifier"];
        [self.favouriteVenues addObject:newVenue];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"FavouritesShowDetail"]) {
        DetailViewController * deatailVC = [segue destinationViewController];
        deatailVC.venue = self.favouriteVenues[self.selectedIndexpath.row];
    }
}


@end
