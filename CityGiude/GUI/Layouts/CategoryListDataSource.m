//
//  BookDataSource.m
//  ChildBook
//
//  Created by Dmitry Kuznetsov on 07/09/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "CategoryListDataSource.h"
#import "CategoryListCell.h"
#import "DBWork.h"
//#import "ChildBookData.h"
#import "Constants.h"
#import "Categories.h"

#import "AppDelegate.h"

@implementation CategoryListDataSource{
}

- (id)init
{
    if (!(self = [super init])) return nil;
    
    self.filteredBooks = [[NSArray alloc] init];
    [self initDataArrayFromCoreData];

    return self;
}

-(void)initDataArrayFromCoreData{
    
    NSString *str = [NSString stringWithFormat:@"parent_id == %i", 0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:str];
    NSFetchedResultsController *frc = [[DBWork shared] fetchedResultsController:kCoreDataCategoriesEntity sortKey:@"sort" predicate:predicate sectionName:nil delegate:self];
    self.itemsArray = frc.fetchedObjects;
    

}

#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return [[JournalData shared].books numberOfsections];
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    if([self isMyBooksModeOn])
//        return [self.filteredBooks count];
//    return [[DBWork shared].books count];
//    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    NSFetchedResultsController *frc = [DBWork shared] fetchedResultsController:<#(NSString *)#> sortKey:<#(NSString *)#> predicate:<#(NSPredicate *)#> sectionName:<#(NSString *)#> delegate:<#(id)#>

    return [self.itemsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CategoryListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CategoryListCell reuseId] forIndexPath:indexPath];
    
//    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    Categories *category = self.itemsArray[indexPath.item];
    [cell.labelCategoryName setText:category.name];
//    
//    ChildBookData* aJournal = nil;
//    
//    if([self isMyBooksModeOn]) //check book mode: all books vs my books vs search
//        aJournal = self.filteredBooks[indexPath.row];
//    else
//        aJournal = [DBWork shared].books[indexPath.row];
//    
//    cell.likeImage.hidden = !aJournal.book.social.boolValue; //setup LIKE flag
//    
//    [cell.titleLable setText:aJournal.book.name]; //setup book title
//    [cell.titleLable setVerticalAlignment:UIControlContentVerticalAlignmentTop];
//    [cell.durationLabel setText:[self timeToString:[aJournal.book.mp3Duration integerValue]]];
//    
//    if(aJournal.sound.playing){
//        cell.bookIsPlayingNowImage.hidden = NO;
//        [cell.durationLabel setTextAlignment:NSTextAlignmentRight];
//    }
//    else{
//        cell.bookIsPlayingNowImage.hidden = YES;
//        [cell.durationLabel setTextAlignment:NSTextAlignmentCenter];
//    }
//    
//    cell.layer.shouldRasterize = YES;
//    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
   
    
    return cell;
}

//-(BOOL)isMyBooksModeOn{
//    if([[self.delegate class] conformsToProtocol:@protocol(BookDataSourceDelegate)]){
//        return [(id)self.delegate isMyBooksModeActive];
//    }
//    return NO;
//}

//-(NSString*)timeToString:(NSInteger)durationInSeconds{
//    
//    NSInteger durationInMinutes = durationInSeconds / 60;
//    NSInteger durationInRemainder = durationInSeconds % 60;
//    
//    NSString *finalDurationString = @"";
//    if(labs(durationInRemainder) < 10)
//        finalDurationString = [NSString stringWithFormat:@"%li:0%li", (long)durationInMinutes, labs(durationInRemainder)];
//    else
//        finalDurationString = [NSString stringWithFormat:@"%li:%li", (long)durationInMinutes, labs(durationInRemainder)];
//    
//    return [finalDurationString stringByAppendingString:kMinSuffix];
//}

@end
