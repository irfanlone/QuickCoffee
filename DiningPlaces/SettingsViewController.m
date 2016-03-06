//
//  SettingsViewController.m
//  DiningPlaces
//
//  Created by Irfan Lone on 3/6/16.
//  Copyright © 2016 Yuzu. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *filterRadius;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) NSNumber * filterValue;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.filterValue) {
        self.distanceSlider.value = [self.filterValue floatValue];
    } else {
        self.distanceSlider.value = 25.0;
    }
    [self sliderValueChanged:self];
}

- (IBAction)sliderValueChanged:(id)sender {
    self.filterRadius.text = [NSString stringWithFormat:@"%0.2f miles",self.distanceSlider.value];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)applyFilterPressed:(id)sender {
    self.filterValue = @(self.distanceSlider.value);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.filterRadiusValue = self.filterValue;
}

@end
