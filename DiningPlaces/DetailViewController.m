//
//  DetailViewController.m
//  DiningPlaces
//
//  Created by Irfan Lone on 3/5/16.
//  Copyright © 2016 Yuzu. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"


@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *address;

@end

@implementation DetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *starButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(starClicked:)];
    self.navigationItem.rightBarButtonItem = starButton;
    [self configureView];
}


- (void)configureView {
    self.name.text = self.venue.name;
    self.address.text = self.venue.address;
}

- (void)starClicked:(id)sender {
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
    
    if ([[mutableFetchResults valueForKey:@"name"] containsObject:self.venue.name]) {
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
            [moc save:nil];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
