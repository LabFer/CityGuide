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
    
    
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button ====
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    self.navigationItem.title = kNavigationTitleNewResponse;
    //NSLog(@"self.navigationItem.title = %@", self.aPlace);
    
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)sendResponseBtnPressed:(id)sender {
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
    NSLog(@"textViewShouldBeginEditing:");
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
    NSLog(@"textViewShouldEndEditing:");
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    if(self.commentTextView.text.length > 1000) return;
    
    self.wordCountLabel.text = [NSString stringWithFormat:@"%li/1000", self.commentTextView.text.length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // Prevent crashing undo bug – see note below.
    NSLog(@"shouldChangeCharactersInRange");
    
    if(range.length + range.location > textView.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > 1000) ? NO : YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.commentTextView isFirstResponder] && [touch view] != self.commentTextView) {
        [self.commentTextView resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

//- (BOOL)canBecomeFirstResponder
//{
//    return NO;
//}

#pragma mark - Keyboard

-(void)hideKeyboard{
    NSLog(@"hideKeyboard:");
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
@end
