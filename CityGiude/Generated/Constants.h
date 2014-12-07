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
#define DEVICE_KEY ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? @"Q1WT8ds": @"KJHB4Sd45"

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
#define kReuseSettingsCellID @"SettingsCell"
#define kReuseBannerHeaderCollectionViewKind @"BannerHeaderCollectionView"

#define kReusePlaceDetailedMainCellID @"PlaceDetailedMainCell"
#define kReusePlaceDetailedMainNoImageCellID @"PlaceDetailedMainCellNoImage"
#define kReusePlaceDetailedRatingCellID @"RatingCell"
#define kReusePlaceDetailPPImageScrollingTableViewCell @"PPImageScrollingTableViewCell"
#define kReusePlaceDetailedAboutCellID @"AboutCell"
#define kReusePlaceDetailedShareCellID @"ShareCell"
#define kReusePlaceDetailedInfoCellID @"InfoCell"
#define kReusePlaceDetailedCommonCellID @"CommonCell"
#define kReuseFavourPlaceListCellID @"FavourPlaceListCell"
#define kReuseFavourCategoryCellID @"FavourCategoryCell"

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
#define kPromotedPlaceCellColor [UIColor colorWithRed:156.0f/255.0f green:202.0f/255.0f blue:238.0f/255.0f alpha:0.3f]
#define kDefaultButtonBarColor [UIColor colorWithRed:70.0f/255.0f green:132.0f/255.0f blue:182.0f/255.0f alpha:1.0f]

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
#define kNavigationTitlePlace @"ЗАВЕДЕНИЯ"

// ====== CoreData parameters ======
#define kCoreDataCommentsEntity @"Comments"
#define kCoreDataCategoriesEntity @"Categories"
#define kCoreDataPlacesEntity @"Places"
#define kCoreDataAttributesEntity @"Attributes"
#define kCoreDataBannersEntity @"Banners"
#define kCoreDataKeysEntity @"Keys"
#define kCoreDataPhonesEntity @"Phones"
#define kCoreDataGalleryEntity @"Gallery"
#define kCoreDataDiscountEntity @"Discounts"
#define kCoreDatafavouriteEntity @"Favourites"

#define kCoreDataModelName @"CityGiude"
#define kCoreDataSQLiteName @"CityGiude.sqlite"

#define kCoreDataFavourTypeCategory @"category"
#define kCoreDataFavourTypePlace @"place"

// =========== Button titles ========
#define kFilterAllTime @"Круглосуточно"
#define kFilterWorkNow @"Работает сейчас"
#define kFilterWebsiteExists @"Есть веб сайт"
#define kPlaceholderTextView @"Ключевые слова:"
#define kTextViewShowAll @"Показать все"
#define kTextViewCollapse @"Свернуть"
#define kActionSheetPhoneTitle @"Позвонить"
#define kActionSheetPhoneCancel @"Отмена"
#define kAuthLogIn @"Авторизация"
#define kAuthLogOut @"Выход"

// ============ Email ===============
#define kMailSubject @"Отзыв о программе CityGuide"
#define kMailNoEmailAccount @"На вашем устройстве не настроен почтовый аккаунт"
#define kMailAdress @"app@appsgroup.ru"

// ============ Settings ==========
#define kSettingsNotification @"Уведомление"
#define kSettingsDiscount @"Акции и скидки"
#define kSettingsFavour @"Избранное"
#define kSettingsComments @"Комментарии"
#define kSettingsResponces @"Отзывы"

// ============ Sort Keys ==========
#define kSortKeyisAscending @"isAscending"
#define kSortKeyName @"keyName"
#define kSortKeyDB @"position"

#define kImageViewCornerRadius 5

// ============ Notifications =======
#define kFacebookNotification @"SessionStateChangeNotification"

// ============ Social ========

#define kSocialUserProfile @"socialUserProfile"
#define kSocialType @"socialType"
#define kSocialUserID @"userID"
#define kSocialUserEmail @"userEmail"
#define kSocialUserFirstName @"userFirstName"
#define kSocialUserLastName @"userLastName"
#define kSocialUserPhoto @"userPhoto"

#define kSocialFacebookProfile @"facebookProfile"
#define kSocialTwitterProfile @"twitterProfile"
#define kSocialVKontakteProfile @"vkontakteProfile"

// ============ App Secret Keys =====
#define kTwitterConsumerKey @"vXCMRNxTZDcb05NO5JRAeyT5h"
#define kTwitterConsumerSecret @"tVnBULG79hvmyzA8xLOr5IFuSXwqU6QQcEFPgTgLBH7thtmzUZ" 

#define kVkontakteID @"4666988"
#define kVkontakteKey @"4oX8h783YywrJLfiIlqO"

// =========== Alert View ========
#define kAlertLater @"Позже"
#define kAlertRepeat @"Повторить"
#define kAlertUpdateError @"Возникла ошибка при обновлении данных"
#define kAlertError @"Ошибка"
#define kAlertJSONError @"Возникла ошибка при запросе данных с сервера"

#define kAlertUpdateData @"Обновление данных"
#define kAlertUpdateDataMessage @"Хотите обновить данные?"
#define kAlertYes @"Да"
#define kAlertNo @"Нет"

#endif
