//
//  BannerContentViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 09/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "BannerContentViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"

@interface BannerContentViewController ()

@end

@implementation BannerContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if([self.dataObject isKindOfClass:[Banners class]]){
        Banners *aBanner = (Banners*)self.dataObject;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, aBanner.picture];
        NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self.bannerImageView setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"banner"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
