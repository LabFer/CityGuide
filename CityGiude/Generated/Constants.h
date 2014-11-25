//
//  Constants.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 10/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#ifndef CityGiude_Constants_h
#define CityGiude_Constants_h


// ======== Devices =========
#define IS_IPAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

// ====== Directories =======
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

// ========= URLs ===========
#define URL_API @"http://lsg.appsgroup.ru/api/ios_v1/api.php"
#define URL_BASE @"http://lsg.appsgroup.ru/"

// ========= CollectionView and TableView Layouts =======
#define kReuseCellTileID @"CategoryTileCell"
#define kReuseCellListID @"CategoryListCell"
#define kReusePlaceCellListID @"PlaceListCell"
#define kReuseFilterCommonCellID @"FilterCommonCell"
#define kReuseFilterListCellID @"FilterListCell"
#define kReuseDiscountListCellID @"DiscountListCell"
#define kReuseFavourCategoryCellID @"FavourCategoryCell"
#define kReuseSettingsCellID @"SettingsCell"
#define kReuseBannerHeaderCollectionViewKind @"BannerHeaderCollectionView"

// ========= Presentation Mode =========
typedef enum {
    UICatalogTile,
    UICatalogList
} UIPresentationMode;

#define kPresentationMode @"UIPresentationMode"
#define kPresentationModeTile @"UICatalogTile"
#define kPresentationModeList @"UICatalogList"

// ========= Colors =========
#define kDefaultNavItemTintColor [UIColor colorWithRed:156.0f/255.0f green:202.0f/255.0f blue:238.0f/255.0f alpha:1.0f]
#define kDefaultNavBarColor [UIColor colorWithRed:35.0f/255.0f green:113.0f/255.0f blue:175.0f/255.0f alpha:1.0f]

// ========== Navigation Bar ========
#define kNavigationTitle @"КАТЕГОРИИ"
#define kTitleFilter @"ФИЛЬТР"
#define kNavigationTitleDiscount @"АКЦИИ И СКИДКИ"
#define kNavigationTitleAboutUser @"ИМЯ ПОЛЬЗОВАТЕЛЯ"
#define kNavigationTitleAboutProgramm @"О ПРОГРАММЕ"
#define kNavigationTitleFavour @"ИЗБРАННОЕ"
#define kNavigationTitleSettings @"НАСТРОЙКИ"
#define kNavigationTitleMapNear @"РЯДОМ"
#define kNavigationTitleResponse @"ОТЗЫВЫ"
#define kNavigationTitleNewResponse @"НОВЫЙ ОТЗЫВ"
#define kNavigationTitleAuth @"АВТОРИЗАЦИЯ"

// ====== CoreData parameters ======
#define kCoreDataCommentsEntity @"Comments"
#define kCoreDataCategoriesEntity @"Categories"
#define kCoreDataPlacesEntity @"Places"
#define kCoreDataAttributesEntity @"Attributes"
#define kCoreDataBannersEntity @"Banners"
#define kCoreDataKeysEntity @"Keys"
#define kCoreDataPhonesEntity @"Phones"
#define kCoreDataGalleryEntity @"Gallery"

#define kCoreDataModelName @"CityGiude"
#define kCoreDataSQLiteName @"CityGiude.sqlite"
#define kSortKeyDB @"position"

// =========== Button titles ========
#define kFilterAllTime @"Круглосуточно"
#define kFilterWorkNow @"Работает сейчас"
#define kFilterWebsiteExists @"Есть веб сайт"
#define kPlaceholderTextView @"Ключевые слова:"

// ============ Email ===============
#define kMailSubject @"Отзыв о программе CityGuide"
#define kMailNoEmailAccount @"На вашем устройстве не настроен почтовый аккаунт"
#define kMailAdress @"app@appsgroup.ru"

// ============ Settings ==========
#define kSettingsNotification @"Уведомление"
#define kSettingsDiscount @"Акции и скидки"
#define kSettingsFavour @"Избранное"
#define kSettingsComments @"Комментарии"

#endif
