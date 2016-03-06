//
//  DetailViewController.h
//  DiningPlaces
//
//  Created by Irfan Lone on 3/5/16.
//  Copyright © 2016 Yuzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

