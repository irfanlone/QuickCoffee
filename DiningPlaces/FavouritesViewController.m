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

@interface FavouritesViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong) NSMutableArray<Venue*> * favouriteVenues;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    cell.venueDistance.text = [venueItem.distance stringValue];
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
            NSManagedObjectID * objectID = (NSManagedObjectID*)itemToDelete.identifier;
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



- (NSArray *)managedObjectsForClass:(NSString *)className InManagedObjectContext:(NSManagedObjectContext*)moc {
    __block NSArray *results = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
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
        newVenue.identifier = [obj valueForKey:@"objectID"];
        [self.favouriteVenues addObject:newVenue];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
