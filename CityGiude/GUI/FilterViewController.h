//
//  FilterViewController.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 21/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Categories.h"

@interface FilterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *filtersTableView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;

@property (nonatomic, strong) Categories *aCategory;
@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) NSMutableDictionary *filterDictionary;

- (IBAction)arrayFilterOkPressed:(id)sender;
- (IBAction)arrayFilterCancelPressed:(id)sender;
- (IBAction)btnCancelPressed:(id)sender;
- (IBAction)btnOKPressed:(id)sender;


@end
