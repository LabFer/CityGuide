//
//  BookDataSource.h
//  ChildBook
//
//  Created by Dmitry Kuznetsov on 07/09/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//@protocol BookDataSourceDelegate
//@required
//-(BOOL)isMyBooksModeActive;
//@end

@interface SubCategoryListDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, assign) id delegate;
@property (assign) BOOL myBooksMode;

@property (nonatomic, strong) NSArray* filteredBooks;
@property (nonatomic, strong) NSArray *itemsArray;

-(id)initWithDelegate:(id)delegate;

@end
