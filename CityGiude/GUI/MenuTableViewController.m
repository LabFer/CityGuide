//
//  MenuTableViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 13/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "MenuTableViewController.h"
#import "UIViewController+MMDrawerController.h"

@implementation MenuTableViewController

-(void)viewDidLoad{

    [super viewDidLoad];
    
    self.navigationControllerArray = [[NSMutableArray alloc] initWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return 11;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
//    //NSLog(@"cellForRowAtIndexPath: %@", CellIdentifier);
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    return cell;
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.row == 0)
//        return 20.0f;
//    
//    return 44.0f;
//}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath: %li", indexPath.row);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    NSObject *navigationController = [self.navigationControllerArray objectAtIndex:indexPath.row];
    
    if (![navigationController isKindOfClass:[UINavigationController class]]) {
    
        UIViewController *newViewController;
        
        switch (indexPath.row) {
            case 2:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AboutUserViewController"];
                break;
            case 3: //goto catalog screen
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                break;
            case 4: //goto catalog screen
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                break;
            case 5:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DiscountListViewController"];
                break;
            case 6:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NearMapViewController"];
                break;
            case 7:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"FavourViewController"];
                break;
            case 8:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
                break; 
            case 10:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AuthUserViewController"];
                break;
            default:
                break;
        }
        
        navigationController = (UINavigationController *)[[UINavigationController alloc] initWithRootViewController:(UIViewController *)newViewController];
        
        [self.navigationControllerArray replaceObjectAtIndex:indexPath.row withObject:navigationController];
    }
    
    [self.mm_drawerController setCenterViewController:(UINavigationController *)navigationController withCloseAnimation:YES completion:nil];
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSObject *navigationController = [self.viewControllerArray objectAtIndex:indexPath.row];
//    
//    if (![navigationController isKindOfClass:[UINavigationController class]]) {
//        
//        UIViewController *newViewController;
//        
//        switch (indexPath.row) {
//            case 0:
//                newViewController = (UIViewController *)[[AccountListTableViewController alloc] init];
//                break;
//            case 1:
//                newViewController = (UIViewController *)[[PageDetailViewController alloc] init];
//                break;
//            case 2:
//                newViewController = (UIViewController *)[[LoginViewController alloc] init];
//                break;
//                
//            default:
//                newViewController = (UIViewController *)[[AccountListTableViewController alloc] init];
//                break;
//        }
//        
//        navigationController = (UINavigationController *)[[UINavigationController alloc] initWithRootViewController:(UIViewController *)newViewController];
//        
//        [self.viewControllerArray replaceObjectAtIndex:indexPath.row withObject:navigationController];
//        
//    }
//    
//    [self.mm_drawerController setCenterViewController:(UINavigationController *)navigationController withCloseAnimation:YES completion:nil];
    
    return indexPath;
}
@end
