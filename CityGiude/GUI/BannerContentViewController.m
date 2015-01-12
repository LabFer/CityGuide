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
#import "NIPaths.h"

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
        NSLog(@"BannerContentViewController: %@", imgUrl);
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicatorView.center = self.bannerImageView.center;
        [self.view addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
        
        
        //cell.placeImage.image = [UIImage imageNamed:@"default50"];
        UIImage *img = [UIImage imageWithContentsOfFile: NIPathForBundleResource(nil, @"NimbusPhotos.bundle/gfx/default.png")];
        [self.bannerImageView setImageWithURLRequest:[NSURLRequest requestWithURL:imgUrl]
                                          placeholderImage:img /*[UIImage imageNamed:@"defaulticonbig"]*/
                                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                       
                                                       [activityIndicatorView removeFromSuperview];
                                                       
                                                       // do image resize here
                                                       
                                                       // then set image view
                                                       //NSLog(@"Image downloaded");
                                                       self.bannerImageView.image = image;
                                                   }
                                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                       [activityIndicatorView removeFromSuperview];
                                                       //NSLog(@"Fail to download image");
                                                       // do any other error handling you want here
                                                   }];

        
        
        
        
        //[self.bannerImageView setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"banner"]];
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
