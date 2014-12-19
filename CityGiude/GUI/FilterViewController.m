//
//  FilterViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 21/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "FilterViewController.h"
#import "FilterCommonCell.h"
#import "FilterListCell.h"
#import "UIUserSettings.h"
#import "Constants.h"
#import "Attributes.h"
#import "Values.h"
#import "PlaceViewController.h"

@implementation FilterViewController{
    UIUserSettings *_userSettings;
    NSArray *_arrayOfAttributes;
    NSMutableArray *_pickerData;
    NSMutableArray *selectedItems;
    NSNumber *notImportant;
    NSIndexPath *_currentListAttributeIndex;
    Attributes *_currentListAttribute;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    _userSettings = [[UIUserSettings alloc] init];
    //[self setNavBarButtons];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.pickerView.hidden = YES;
    
    NSArray *tmp = [self.aCategory.attributes allObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@ OR type == %@", @"check", @"array"];
    _arrayOfAttributes = [tmp filteredArrayUsingPredicate:predicate];
    
    NSLog(@"tmp: %@", tmp);
    NSLog(@"_arrayOfAttributes: %@", _arrayOfAttributes);
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    selectedItems = [[NSMutableArray alloc] initWithCapacity:0];
    notImportant = [NSNumber numberWithInt:0];
    
    UITapGestureRecognizer * singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerViewTapGestureRecognized:)];
    singleTapGestureRecognizer.delegate = self;
    [self.pickerView addGestureRecognizer:singleTapGestureRecognizer];
    
    
    _pickerData = [[NSMutableArray alloc] initWithObjects:@"Не важно", nil];
   
    if(!self.filterDictionary)
        self.filterDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];

    self.navView.backgroundColor = kDefaultNavBarColor;
    self.btnOK.tintColor = kDefaultNavItemTintColor;
    self.btnCancel.tintColor = kDefaultNavItemTintColor;
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
//    self.navigationItem.rightBarButtonItem = [_userSettings setupConfirmButtonItem:self]; // ====== setup right nav button ======
//    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
//    
//    self.navigationItem.leftBarButtonItem = [_userSettings setupCancelButtonItem:self];// ====== setup back nav button =====
//    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
//    
//    self.navigationItem.title = kTitleFilter;
    
}

//-(void)confirmButtonPressed{
//    NSLog(@"confirmButtonPressed");
//    if([self.delegate isKindOfClass:[PlaceViewController class]]){
//        PlaceViewController *vc = (PlaceViewController*)self.delegate;
//        vc.filterDictionary = self.filterDictionary;
//        [vc createPlaceList];
//    }
//    
//    [self goBack];
//}

//-(void)cancelButtonPressed{
//    NSLog(@"cancelButtonPressed");
//    [self goBack];
//}

-(void)goBack{
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 3 + _arrayOfAttributes.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}
#pragma mark - TableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    
    if (indexPath.row < 3) {
        cell = [self.filtersTableView dequeueReusableCellWithIdentifier:[FilterCommonCell reuseId]];
        [self configureFilterCommonCell:(FilterCommonCell*)cell atIndexPath:indexPath];
    }
    else{
        Attributes *item = _arrayOfAttributes[indexPath.row - 3];
        if([item.type isEqualToString:@"array"]){
            cell = [self.filtersTableView dequeueReusableCellWithIdentifier:[FilterListCell reuseId]];
            [self configureFilterListCell:(FilterListCell*)cell atIndexPath:indexPath];
        }
        else if([item.type isEqualToString:@"check"]){
            cell = [self.filtersTableView dequeueReusableCellWithIdentifier:[FilterCommonCell reuseId]];
            [self configureFilterCommonCell:(FilterCommonCell*)cell atIndexPath:indexPath];
        }
    }
    
    // Configure the cell...
    
    
    return cell;
}

- (void)configureFilterCommonCell:(FilterCommonCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    

    if(indexPath.row == 0){
        NSNumber *selectedItem = [self.filterDictionary objectForKey:kFilterAllTime];
        if(selectedItem){
            NSLog(@"selectedItem for %@ exist: %@", kFilterAllTime, selectedItem);
           [cell.filterCheck setSelectedSegmentIndex:selectedItem.integerValue];
        }
        else{
            NSLog(@"selectedItem for %@ exists", kFilterAllTime);
            [self.filterDictionary setObject:[NSNumber numberWithInteger:1] forKey:kFilterAllTime];
        }
        [cell.filterTitle setText:kFilterAllTime];
    }
    else if(indexPath.row == 1){
        NSNumber *selectedItem = [self.filterDictionary objectForKey:kFilterWorkNow];
        if(selectedItem){
            NSLog(@"selectedItem for %@ exist: %@", kFilterWorkNow, selectedItem);
            [cell.filterCheck setSelectedSegmentIndex:selectedItem.integerValue];
        }
        else{
            NSLog(@"selectedItem for %@ not exists", kFilterWorkNow);
            [self.filterDictionary setObject:[NSNumber numberWithInteger:1] forKey:kFilterWorkNow];
        }
        [cell.filterTitle setText:kFilterWorkNow];
    }
    else if(indexPath.row == 2){
        NSNumber *selectedItem = [self.filterDictionary objectForKey:kFilterWebsiteExists];
        if(selectedItem){
            NSLog(@"selectedItem for %@ exist: %@", kFilterWebsiteExists, selectedItem);
            [cell.filterCheck setSelectedSegmentIndex:selectedItem.integerValue];
        }
        else{
            NSLog(@"selectedItem for %@ not exist", kFilterWebsiteExists);
            [self.filterDictionary setObject:[NSNumber numberWithInteger:1] forKey:kFilterWebsiteExists];
        }
        [cell.filterTitle setText:kFilterWebsiteExists];
    }
    else{
        Attributes *item = _arrayOfAttributes[indexPath.row - 3];
        //NSLog(@"Non common item.name: %@", item.name);
        [cell.filterTitle setText:item.name];
        cell.anAttribute = item;
        
        NSNumber *selectedItem = [self.filterDictionary objectForKey:item.name];
        if(selectedItem){
            NSLog(@"selectedItem for %@ exist: %@", item.name, selectedItem);
            [cell.filterCheck setSelectedSegmentIndex:selectedItem.integerValue];
        }
        else{
            NSLog(@"selectedItem for %@ not exists", item.name);
            [self.filterDictionary setObject:[NSNumber numberWithInteger:1] forKey:item.name];
        }
    }
    
    [cell.filterCheck addTarget:self action:@selector(segmentedConrolChanged:) forControlEvents:UIControlEventValueChanged];
    cell.filterCheck.tag = indexPath.row;
}

- (void)configureFilterListCell:(FilterListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Attributes *item = _arrayOfAttributes[indexPath.row - 3];
    
    cell.anAttribute = item;
    [cell.filterTitle setText:[NSString stringWithFormat:@"%@", item.name]];
    
    NSString *filter = [self.filterDictionary objectForKey:item.name];
    if(!filter || [filter isEqualToString:@""]){
        NSLog(@"filterString for %@ not exist", item.name);
        cell.filterValuesTitle.text = @"Не важно";
    }
    else{
        NSLog(@"filterString for %@ exist: %@", item.name, filter);
        cell.filterValuesTitle.text = filter;
    }
    
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.filtersTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Attributes *item = _arrayOfAttributes[indexPath.row - 3];
    if([item.type isEqualToString:@"array"]){
        [item.values enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            Values *value = (Values*)obj;
            
            [_pickerData addObject:value.valueName];
            
        }];
        
        NSString *str = [self.filterDictionary objectForKey:item.name];
        if(str && ![str isEqualToString:@""]){
            for(int i = 0; i < _pickerData.count; i++){
                NSString *obj = _pickerData[i];
                if([str rangeOfString:obj].location != NSNotFound){
                    [selectedItems addObject:[NSNumber numberWithInt:i]];
                }
            }
        }
        
        if(selectedItems.count == 0)
            [selectedItems addObject:notImportant];
        
        [self.pickerView reloadAllComponents];
        self.pickerView.hidden = NO;
        _currentListAttributeIndex = indexPath;
        _currentListAttribute = item;
        
    }
    
    //NSLog(@"Item selected: %@", self.frcPlaces.fetchedObjects[indexPath.row]);
    //[self performSegueWithIdentifier:@"segueFromHouseToHouseDetail" sender:indexPath];
    
}

-(void)segmentedConrolChanged:(UISegmentedControl *)segment{
    
    if(segment.tag == 0){
        [self.filterDictionary setObject:[NSNumber numberWithInteger:segment.selectedSegmentIndex] forKey:kFilterAllTime];
    }
    else if(segment.tag == 1){
        [self.filterDictionary setObject:[NSNumber numberWithInteger:segment.selectedSegmentIndex] forKey:kFilterWorkNow];
    
    }
    else if(segment.tag == 2){
        [self.filterDictionary setObject:[NSNumber numberWithInteger:segment.selectedSegmentIndex] forKey:kFilterWebsiteExists];
    
    }
    else{
        Attributes *item = _arrayOfAttributes[segment.tag - 3];
        [self.filterDictionary setObject:[NSNumber numberWithInteger:segment.selectedSegmentIndex] forKey:item.name];
    }
    NSLog(@"%ld, %ld", (long)segment.tag, (long)segment.selectedSegmentIndex);
}

#pragma mark - PickerView Delegate

-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UITableViewCell *cell = (UITableViewCell *)view;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setBounds:CGRectMake(0, 0, cell.frame.size.width - 20, 44)];
    }
    
    if ([selectedItems indexOfObject:[NSNumber numberWithInt:row]] != NSNotFound) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    cell.textLabel.text = [_pickerData objectAtIndex:row];
    return cell;
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _pickerData.count;
}

#pragma mark - Gesture Recognizer
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer  shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{

    return YES;
}

- (void)pickerViewTapGestureRecognized:(UITapGestureRecognizer*)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    CGRect frame = self.pickerView.frame;
    CGRect selectorFrame = CGRectInset( frame, 0.0, self.pickerView.bounds.size.height * 0.85 / 2.0 );
    
    if( CGRectContainsPoint( selectorFrame, touchPoint) )
    {
        NSLog( @"Selected Row: %@", [_pickerData objectAtIndex:[self.pickerView selectedRowInComponent:0]]);
        
        NSNumber *row = [NSNumber numberWithInt:[self.pickerView selectedRowInComponent:0]];
        NSUInteger index = [selectedItems indexOfObject:row];
        if (index != NSNotFound) {
            [selectedItems removeObjectAtIndex:index];
        } else {
            [selectedItems addObject:row];
        }
        
        if(selectedItems.count > 0){
            [selectedItems removeObject:notImportant];
        }
        else{
            [selectedItems addObject:notImportant];
        }
        
        [self.pickerView reloadAllComponents];
        
        NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSNumber *numIndex in selectedItems){
            if(numIndex.integerValue != 0){
                NSLog(@"index = %i", numIndex.integerValue);
                [tmp addObject:[_pickerData objectAtIndex:numIndex.integerValue]];
            }
        }
        
        if(tmp.count != 0){
            [self.filterDictionary setObject:[tmp componentsJoinedByString:@","] forKey:_currentListAttribute.name];
        }
        else{
            [self.filterDictionary removeObjectForKey:_currentListAttribute.name];
        }
        [self.filtersTableView reloadRowsAtIndexPaths:@[_currentListAttributeIndex] withRowAnimation:NO];
    }
}

- (IBAction)arrayFilterOkPressed:(id)sender {
    
    self.pickerView.hidden = YES;
    [selectedItems removeAllObjects];
    [self clearPickerViewData];
}

- (IBAction)arrayFilterCancelPressed:(id)sender {
    [self.filterDictionary removeObjectForKey:_currentListAttribute.name];
    [self.filtersTableView reloadRowsAtIndexPaths:@[_currentListAttributeIndex] withRowAnimation:NO];
    [selectedItems removeAllObjects];
    self.pickerView.hidden = YES;
    [self clearPickerViewData];
}

- (IBAction)btnCancelPressed:(id)sender {
    [self goBack];
}

- (IBAction)btnOKPressed:(id)sender {
    NSLog(@"OK ButtonPressed");
    if([self.delegate isKindOfClass:[PlaceViewController class]]){
        PlaceViewController *vc = (PlaceViewController*)self.delegate;
        
        vc.filterDictionary = nil;
        vc.filterDictionary = [[NSDictionary alloc] initWithDictionary:self.filterDictionary];
        
        NSLog(@"FilterController: %@", self.filterDictionary);
        [vc createPlaceList];
    }
    
    [self goBack];
}

-(void)clearPickerViewData{
    [_pickerData removeAllObjects];
    [_pickerData addObject:@"Не важно"];

}
@end
