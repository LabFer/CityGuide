//
//  BannerContentViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 09/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "PhotoBrowserContentViewController.h"
#import "UIImageView+AFNetworking.h"

@interface PhotoBrowserContentViewController ()

@end

@implementation PhotoBrowserContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.center = self.bannerImageView.center;
    [self.bannerImageView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    
    //cell.placeImage.image = [UIImage imageNamed:@"default50"];
    [self.bannerImageView setImageWithURLRequest:[NSURLRequest requestWithURL:self.titleText]
                                      placeholderImage:[UIImage imageNamed:@"defaulticonbig"]
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   
                                                   [activityIndicatorView removeFromSuperview];
                                                   
                                                   // do image resize here
                                                   
                                                   // then set image view
                                                   NSLog(@"Image downloaded");
                                                   self.bannerImageView.image = image;
                                                   [self.bannerImageView setContentMode:UIViewContentModeScaleAspectFit];
                                               }
                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                   [activityIndicatorView removeFromSuperview];
                                                   NSLog(@"Fail to download image");
                                                   // do any other error handling you want here
                                                   [self.bannerImageView setContentMode:UIViewContentModeScaleAspectFit];
                                               }];

    
    
    
    [self.bannerImageView setImageWithURL:self.titleText];
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
