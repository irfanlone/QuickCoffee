//
//  PhotoFullScreenViewController.m
//  DiningPlaces
//
//  Created by Irfan Lone on 3/6/16.
//  Copyright © 2016 Yuzu. All rights reserved.
//

#import "PhotoFullScreenViewController.h"
#import "Transport.h"

@interface PhotoFullScreenViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation PhotoFullScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:self.imageUrl];
    Transport * transport = [[Transport alloc] init];
    [transport retrieve:request completionBlock:^(BOOL success, TransportResponseObject *responseObject) {
        if(success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage * image = [UIImage imageWithData:responseObject.data];
                self.imageView.image = image;
                [self.activityIndicator stopAnimating];
            });
        }
    }];

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
    CGRect viewBounds = self.view.bounds;
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds));
}


- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
