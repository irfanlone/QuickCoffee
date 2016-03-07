//
//  DetailViewController.m
//  DiningPlaces
//
//  Created by Irfan Lone on 3/5/16.
//  Copyright © 2016 Yuzu. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "Transport.h"
#import "PhotoCell.h"
#import "PhotoFullScreenViewController.h"

NSString *const kAlreadyStar = @"Star It";
NSString *const kRemoveStar = @"Un Star";


@interface DetailViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (strong, nonnull) NSMutableArray * favouritesList;
@property (strong, nonatomic) UIBarButtonItem * starButton;
@property (strong, nonatomic) NSMutableArray * venuePhotosList;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.favouritesList = [NSMutableArray array];
    self.venuePhotosList = [NSMutableArray array];
    [self loadPhotos];
    [self configureView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)configureView {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext * moc = [appDelegate managedObjectContext];
    NSArray * starredVenues = [self managedObjectsForClass:@"FavouriteVenue" InManagedObjectContext:moc];
    [self managedObjectsToVenuesfromArray:starredVenues];
    BOOL isFavourite = NO;
    for (Venue * item in self.favouritesList) {
        if ([item.name isEqualToString:self.venue.name] && [item.address isEqualToString:self.venue.address]) {
            isFavourite = YES;
            self.venue.objectID = item.objectID;
            break;
        }
    }
    if (isFavourite) {
        self.starButton = [[UIBarButtonItem alloc] initWithTitle:kRemoveStar style:UIBarButtonItemStyleDone target:self action:@selector(starClicked:)];
    } else {
        self.starButton = [[UIBarButtonItem alloc] initWithTitle:kAlreadyStar style:UIBarButtonItemStylePlain target:self action:@selector(starClicked:)];
    }
    self.navigationItem.rightBarButtonItem = self.starButton;
    self.name.text = self.venue.name;
    self.address.text = self.venue.address;
}

- (void)loadPhotos {
    NSString * baseUrl = @"https://api.foursquare.com/v2/venues/";
    NSString * venueId = self.venue.identifier;
    NSString * operation = @"/photos?";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString * dateStr = [dateFormat stringFromDate:[NSDate date]];
    NSString * urlString = [NSString stringWithFormat:@"%@%@%@&client_id=%@&client_secret=%@&v=%@",baseUrl,venueId,operation,kCLIENTID,kCLIENTSECRET,dateStr];
    NSURL * url = [NSURL URLWithString:urlString];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    Transport * transport = [[Transport alloc] init];
    [transport retrieve:request completionBlock:^(BOOL success, TransportResponseObject *responseObject) {
        if(success) {
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject.data options:0 error:nil];
            NSArray *response = [jsonArray valueForKey:@"response"];
            NSArray * photos = [response valueForKey:@"photos"];
            self.venuePhotosList = [photos valueForKey:@"items"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
    }];
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
            NSManagedObjectID * objectID = (NSManagedObjectID*)self.venue.objectID;
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
            [favouriteVenue setValue:self.venue.identifier forKey:@"identifier"];
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
        newVenue.objectID = [obj valueForKey:@"objectID"];
        newVenue.identifier = [obj valueForKey:@"identifier"];
        [self.favouritesList addObject:newVenue];
    }
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.venuePhotosList.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = (PhotoCell*)[cv dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    NSDictionary * photoItem = self.venuePhotosList[indexPath.row];
    NSString * prefix = [photoItem valueForKey:@"prefix"];
    NSString * suffix = [photoItem valueForKey:@"suffix"];
    NSString * photoSize = @"100x100";
    NSString * imageUrl = [NSString stringWithFormat:@"%@%@%@",prefix,photoSize,suffix];
    
    NSURL * url = [NSURL URLWithString:imageUrl];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    Transport * transport = [[Transport alloc] init];
    [transport retrieve:request completionBlock:^(BOOL success, TransportResponseObject *responseObject) {
        if(success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage * image = [UIImage imageWithData:responseObject.data];
                cell.imageView.image = image;
            });
        }
    }];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoFullScreenViewController *fvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"photoFullScreen"];
    NSDictionary * photoItem = self.venuePhotosList[indexPath.row];
    NSString * prefix = [photoItem valueForKey:@"prefix"];
    NSString * suffix = [photoItem valueForKey:@"suffix"];
    NSString * photoWidth = [photoItem valueForKey:@"width"];
    NSString * photoHeight = [photoItem valueForKey:@"height"];
    NSString * photoSize = [NSString stringWithFormat:@"%@x%@",photoWidth,photoHeight];
    NSString * imageUrl = [NSString stringWithFormat:@"%@%@%@",prefix,photoSize,suffix];
    NSURL * url = [NSURL URLWithString:imageUrl];
    fvc.imageUrl = url;
    [self presentViewController:fvc animated:YES completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5, 5, 0, 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(118, 118);
}


@end
