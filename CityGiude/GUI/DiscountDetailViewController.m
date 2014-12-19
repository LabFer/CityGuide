//
//  DiscountDetailViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 22/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "DiscountDetailViewController.h"
#import "UIUserSettings.h"
#import "Constants.h"
#import "UIImageView+AFNetworking.h"

@implementation DiscountDetailViewController{

    UIUserSettings *_userSettings;
    UIImage *_webImage;
}

-(void)viewDidLoad{
    
    _userSettings = [[UIUserSettings alloc] init];
    
    [super viewDidLoad];
    
    [self setNavBarButtons];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, self.aDiscount.image];
    NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@\n%@", urlStr, imgUrl);
    
    UIImageView *img = [[UIImageView alloc] init];
    [img setImageWithURLRequest:[NSURLRequest requestWithURL:imgUrl] placeholderImage:[UIImage imageNamed:@""] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NSLog(@"setImageWithURLRequest successful");
        
        _webImage = image;
        [self showString];
    
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"setImageWithURLRequest fail");
        [self showString];
    }];

    
    
    //[self showString];
    
}



#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button ====
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    self.navigationItem.title = kNavigationTitleDiscount;
    //NSLog(@"self.navigationItem.title = %@", self.aPlace);
    
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WebView

- (void)showString
{
    NSString *htmlString = @"<html><body>";
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.aDiscount.dateStart.doubleValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    

    NSData *imageData = UIImagePNGRepresentation(_webImage);
    
    NSString *bodyString = [NSString stringWithFormat:@"<h1 style=\"text-align: center\">%@</h1><table style=\"width:100%%\"><tr><td style=\"text-align:left\">%@</td><td style=\"text-align: right\">%@</td></tr><tr><td colspan=2><img src='data:image/png;base64,%@' style=\"width:100%%\"/></td></tr></table><div>%@</div>", self.aDiscount.name, [dateFormatter stringFromDate:startDate], [self timeDifferenceToString:self.aDiscount.dateEnd], imageData, self.aDiscount.text];
    
    htmlString = [htmlString stringByAppendingString:bodyString];
    htmlString = [htmlString stringByAppendingString:@"</body></html>"];
    // UIWebView uses baseURL to find style sheets, images, etc that you include in your HTML.
    NSURL *bundleUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [self.discountDetailWebView loadHTMLString:htmlString baseURL:bundleUrl];
}

-(NSString*)timeDifferenceToString:(NSNumber*)endTime{
    
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *currentDate = [NSDate date];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:endTime.doubleValue];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:currentDate  toDate:endDate  options:0];
    
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    //    NSLog(@"currentDate: %@", [dateFormatter stringFromDate:currentDate]);
    //    NSLog(@"endDate: %@", [dateFormatter stringFromDate:endDate]);
    
    //    NSLog(@"Break down: %ld min : %ld hours : %ld days : %ld months", [breakdownInfo minute], [breakdownInfo hour], [breakdownInfo day], [breakdownInfo month]);
    
    NSString *resultString = @"";
    if([breakdownInfo month] != 0){
        resultString = [NSString stringWithFormat:@"Осталось %li месяцев %li дней", (long)[breakdownInfo month], (long)[breakdownInfo day]];
    }
    else{
        if([breakdownInfo day] != 0){
            resultString = [NSString stringWithFormat:@"Осталось %li дней", (long)[breakdownInfo day]];
        }
        else{
            resultString = [NSString stringWithFormat:@"Осталось %li часов %li минут", (long)[breakdownInfo hour], (long)[breakdownInfo minute]];
        }
    }
    
    return resultString;
}

@end
