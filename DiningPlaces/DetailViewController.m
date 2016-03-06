//
//  DetailViewController.m
//  DiningPlaces
//
//  Created by Irfan Lone on 3/5/16.
//  Copyright © 2016 Yuzu. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"

NSString *const kAlreadyStar = @"Star It";
NSString *const kRemoveStar = @"Un Star";

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (strong, nonnull) NSMutableArray * favouritesList;
@property (strong, nonatomic) UIBarButtonItem * starButton;

@end

@implementation DetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.favouritesList = [NSMutableArray array];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext * moc = [appDelegate managedObjectContext];
    NSArray * starredVenues = [self managedObjectsForClass:@"FavouriteVenue" InManagedObjectContext:moc];
    [self managedObjectsToVenuesfromArray:starredVenues];
    BOOL isFavourite = NO;
    for (Venue * item in self.favouritesList) {
        if ([item.name isEqualToString:self.venue.name] && [item.address isEqualToString:self.venue.address]) {
            isFavourite = YES;
            self.venue.identifier = item.identifier;
            break;
        }
    }
    if (isFavourite) {
        self.starButton = [[UIBarButtonItem alloc] initWithTitle:kRemoveStar style:UIBarButtonItemStyleDone target:self action:@selector(starClicked:)];
    } else {
        self.starButton = [[UIBarButtonItem alloc] initWithTitle:kAlreadyStar style:UIBarButtonItemStylePlain target:self action:@selector(starClicked:)];
    }
    self.navigationItem.rightBarButtonItem = self.starButton;
    [self configureView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)configureView {
    self.name.text = self.venue.name;
    self.address.text = self.venue.address;
}

- (void)starClicked:(id)sender {
    BOOL addToFavourite = NO;
    if ([self.starButton.title isEqualToString:kAlreadyStar]) {
        addToFavourite = YES;
        [self.starButton setTitle:kRemoveStar];
    } else {
        [self.starButton setTitle:kAlreadyStar];
    }
    
    if (!addToFavourite) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext * moc = [appDelegate managedObjectContext];
        [moc performBlockAndWait:^{
            NSManagedObjectID * objectID = (NSManagedObjectID*)self.venue.identifier;
            NSManagedObject * object =[moc existingObjectWithID:objectID error:nil];
            if (object) {
                [moc deleteObject:object];
                [moc save:nil];
            } else {
                NSAssert(NO, @"Failed to retrieve object from core data that needs to be delete");
            }
        }];
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext * moc = [appDelegate managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FavouriteVenue" inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [request setSortDescriptors:sortDescriptors];
    
    NSError *Fetcherror;
    NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:request error:&Fetcherror] mutableCopy];
    
    if (!mutableFetchResults) {
        // error handling code.
    }
    
    if ([[mutableFetchResults valueForKey:@"name"] containsObject:self.venue.name] && [[mutableFetchResults valueForKey:@"address"] containsObject:self.venue.address]) {
        //notify duplicates
        return;
    }
    else
    {
        // create new managed obeject
        [moc performBlockAndWait:^{
            NSManagedObject *favouriteVenue = [NSEntityDescription insertNewObjectForEntityForName:@"FavouriteVenue" inManagedObjectContext:moc];
            [favouriteVenue setValue:self.venue.name forKey:@"name"];
            [favouriteVenue setValue:self.venue.address forKey:@"address"];
            [favouriteVenue setValue:self.venue.website forKey:@"website"];
            [favouriteVenue setValue:self.venue.menuUrl forKey:@"menuUrl"];
            [favouriteVenue setValue:self.venue.phoneNumber forKey:@"phoneNumber"];
            [favouriteVenue setValue:self.venue.checkins forKey:@"checkIns"];
            [favouriteVenue setValue:self.venue.usersCount forKey:@"usersCount"];
            [favouriteVenue setValue:self.venue.distance forKey:@"distance"];
            [favouriteVenue setValue:[NSDate date] forKey:@"createdAt"];
            [moc save:nil];
        }];
    }
}

- (NSArray *)managedObjectsForClass:(NSString *)className InManagedObjectContext:(NSManagedObjectContext*)moc {
    __block NSArray *results = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
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
        [self.favouritesList addObject:newVenue];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
