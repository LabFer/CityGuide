//
//  ResponseViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 25/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "ResponseViewController.h"
#import "UIUserSettings.h"
#import "Constants.h"
#import "SyncEngine.h"
#import "AFNetworking.h"
#import "ResponceCollectionViewController.h"
#import "AuthUserViewController.h"

@implementation ResponseViewController{
    UIUserSettings *_userSettings;
}

-(void)viewDidLoad{
    
    _userSettings = [[UIUserSettings alloc] init];
    
    [super viewDidLoad];
    
    [self setNavBarButtons];
    
    self.rateView.editable = YES;
    self.rateView.notSelectedImage = [UIImage imageNamed:@"star_grey"];
    //self.rateView.halfSelectedImage = [UIImage imageNamed:@"kermit_half.png"];
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"star_yellow"];
    self.rateView.maxRating = 5;
    
    self.commentTextView.delegate = self;
    self.commentTextView.layer.borderWidth = 1.0f;
    self.commentTextView.layer.borderColor = [[UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f] CGColor];
    self.commentTextView.layer.cornerRadius = kImageViewCornerRadius;
    
    self.commentTextView.text = kPlaceholderTextViewComments;
    self.commentTextView.textColor = [UIColor lightGrayColor]; //optional
    
    [self registerForKeyboardNotifications];
    
    self.contentScrollView.delegate = self;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.contentScrollView addGestureRecognizer:gestureRecognizer];
    
    self.wordCountLabel.text = @"0/1000";
    
    NSString *userName = @"";
    
    if([_userSettings isUserAuthorized]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
        
        userName = [NSString stringWithFormat:@"%@ %@", [userProfile objectForKey:kSocialUserFirstName], [userProfile objectForKey:kSocialUserLastName]];
    }
    
    self.userNameLabel.text =  userName;
    self.activityIndicator.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:kReceiveRemoteNotification
                                               object:appDelegate];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiveRemoteNotification object:nil];
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button ====
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    self.navigationItem.title = kNavigationTitleNewResponse;
    //NSLog(@"self.navigationItem.title = %@", self.aPlace);
    
}

-(void)goBack{
    
    NSLog(@"Responce go back");
//    if([self.delegate isKindOfClass:[AuthUserViewController class]]){
//        NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
//        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index - 2] animated:YES];
//    }
//    else if([self.delegate isKindOfClass:[ResponceCollectionViewController class]]){
//        [self.navigationController popViewControllerAnimated:YES];
//    }
        //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)sendResponseBtnPressed:(id)sender {
    
    if(![[SyncEngine sharedEngine] allowUseInternetConnection]){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:kApplicationTitle
                                                                  message:kCommentMessage
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        [message show];
        return;
    }
    
    NSString *commentText = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                             
    if(commentText == nil || [commentText isEqualToString:@""] || [commentText isEqualToString:kPlaceholderTextViewComments]){
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:kApplicationTitle
                                                          message:kCommentsNoText
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
    
    if(self.rateView.rating == 0.0f){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:kApplicationTitle
                                                          message:kCommentsNoRating
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
   
    
    NSDictionary *aComment = [[NSDictionary alloc] initWithObjectsAndKeys:
                              self.aPlace.placeID.stringValue, @"placeID",
                              self.commentTextView.text, @"text",
                              [NSNumber numberWithFloat:self.rateView.rating].stringValue, @"rating", nil];
    
    [self postComment:aComment];

}

#pragma mark - Post Comment
-(void)postComment:(NSDictionary*)aComment{
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    

    
    NSString *userToken = @"", *userName = @"";
    
    if([_userSettings isUserAuthorized]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
        
        userToken = [userProfile objectForKey:kSocialUserToken];
        userName = [NSString stringWithFormat:@"%@ %@", [userProfile objectForKey:kSocialUserFirstName], [userProfile objectForKey:kSocialUserLastName]];
        
    }
    
    NSLog(@"userToken = %@, userName = %@", userToken, userName);
    NSLog(@"aComment: %@", aComment);
    
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys: DEVICE_KEY, @"typeDevice", userToken, @"usertoken", userName, @"name", [aComment objectForKey:@"placeID"], @"placeID", [aComment objectForKey:@"text"], @"text", [aComment objectForKey:@"rating"], @"rating", @"addcomment", @"method", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSLog(@"Post comment Parameters: %@", parameters);
    
    [manager POST:URL_API parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Post comment. Validation responceDict: %@", responseObject);
        NSDictionary *responce = (NSDictionary*)responseObject;
        NSNumber *code = [responce objectForKey:@"code"];
        NSLog(@"code: %@", code);
        if(code.intValue == 0){
            NSLog(@"Post comment success!");
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:kApplicationTitle
                                                              message:kCommentSuccess
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
            self.activityIndicator.hidden = YES;
            [self.activityIndicator stopAnimating];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        else{
            NSLog(@"Post comment Error: %@", [responseObject objectForKey:@"errorText"]);
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:kApplicationTitle
                                                              message:kCommentError
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
            self.activityIndicator.hidden = YES;
            [self.activityIndicator stopAnimating];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Post comment connection Error: %@", error);
              UIAlertView *message = [[UIAlertView alloc] initWithTitle:kApplicationTitle
                                                                message:kCommentError
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
              [message show];
              self.activityIndicator.hidden = YES;
              [self.activityIndicator stopAnimating];
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
          }];
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"alertView: %@", alertView.message);
    
    [self goBack];
}


#pragma mark - Text View Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.commentTextView.text isEqualToString:kPlaceholderTextViewComments]) {
        self.commentTextView.text = @"";
        self.commentTextView.textColor = [UIColor blackColor]; //optional
    }
    [self.commentTextView becomeFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    //NSLog(@"textViewShouldBeginEditing:");
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.commentTextView.text isEqualToString:@""]) {
        self.commentTextView.text = kPlaceholderTextViewComments;
        self.commentTextView.textColor = [UIColor lightGrayColor]; //optional
    }
    [self.commentTextView  resignFirstResponder];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    //NSLog(@"textViewShouldEndEditing:");
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    if(self.commentTextView.text.length > 1000) return;
    
    self.wordCountLabel.text = [NSString stringWithFormat:@"%lu/1000", (unsigned long)self.commentTextView.text.length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // Prevent crashing undo bug – see note below.
    //NSLog(@"shouldChangeCharactersInRange");
    
    if(range.length + range.location > textView.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > 1000) ? NO : YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesBegan:withEvent:");
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.commentTextView isFirstResponder] && [touch view] != self.commentTextView) {
        [self.commentTextView resignFirstResponder];
    }
    
    NSLog(@"ResponceViewController. touchesBegan");
    
    [super touchesBegan:touches withEvent:event];
}

//- (BOOL)canBecomeFirstResponder
//{
//    return NO;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

#pragma mark - Keyboard

-(void)hideKeyboard{
    //NSLog(@"hideKeyboard:");
    [self.commentTextView resignFirstResponder];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.contentScrollView.contentInset = contentInsets;
    self.contentScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbSize.height;
//    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
//        [self.contentScrollView scrollRectToVisible:activeField.frame animated:YES];
//    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.contentScrollView.contentInset = contentInsets;
    self.contentScrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Push Notification
-(void)didReceiveRemoteNotification:(NSNotification *)notification {
    // see http://stackoverflow.com/a/2777460/305149
    if (self.isViewLoaded && self.view.window) {
        // handle the notification
        [_userSettings showPushView:notification.userInfo inViewController:self];
    }
}

@end
