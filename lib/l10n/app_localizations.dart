import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @cleancity1.
  ///
  /// In en, this message translates to:
  /// **'Clean City'**
  String get cleancity1;

  /// No description provided for @recycleorigin.
  ///
  /// In en, this message translates to:
  /// **'Recycle Origin'**
  String get recycleorigin;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @appexit.
  ///
  /// In en, this message translates to:
  /// **'Exit from app'**
  String get appexit;

  /// No description provided for @doyouwanttoexit.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit from the app?'**
  String get doyouwanttoexit;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @forexit.
  ///
  /// In en, this message translates to:
  /// **'In order to exit, press back again'**
  String get forexit;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @dearuser.
  ///
  /// In en, this message translates to:
  /// **'Dear User'**
  String get dearuser;

  /// No description provided for @logoutsuccess.
  ///
  /// In en, this message translates to:
  /// **'You logged out successfully'**
  String get logoutsuccess;

  /// No description provided for @collectrequest.
  ///
  /// In en, this message translates to:
  /// **'Request collect'**
  String get collectrequest;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @articles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get articles;

  /// No description provided for @forarticles.
  ///
  /// In en, this message translates to:
  /// **'In order to get profile information go to profile section'**
  String get forarticles;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @shoppingCartLabel.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get shoppingCartLabel;

  /// No description provided for @supportHelpLabel.
  ///
  /// In en, this message translates to:
  /// **'Support & Help'**
  String get supportHelpLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @applicationLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Application language'**
  String get applicationLanguageLabel;

  /// No description provided for @englishLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLabel;

  /// No description provided for @turkishLabel.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkishLabel;

  /// No description provided for @charities.
  ///
  /// In en, this message translates to:
  /// **'Charities'**
  String get charities;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @cources.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get cources;

  /// No description provided for @supports.
  ///
  /// In en, this message translates to:
  /// **'Supports'**
  String get supports;

  /// No description provided for @guids.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get guids;

  /// No description provided for @contactus.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactus;

  /// No description provided for @aboutus.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutus;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @kilogram.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kilogram;

  /// No description provided for @price_unit.
  ///
  /// In en, this message translates to:
  /// **'\$'**
  String get price_unit;

  /// No description provided for @youarenotlogin.
  ///
  /// In en, this message translates to:
  /// **'You are not logged in.'**
  String get youarenotlogin;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guideTitle;

  /// No description provided for @sectionReturnPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Return policy'**
  String get sectionReturnPolicyTitle;

  /// No description provided for @sectionPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get sectionPrivacyTitle;

  /// No description provided for @sectionHowToOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'How to order'**
  String get sectionHowToOrderTitle;

  /// No description provided for @sectionFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get sectionFaqTitle;

  /// No description provided for @sectionPaymentMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get sectionPaymentMethodsTitle;

  /// No description provided for @supportScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportScreenTitle;

  /// No description provided for @supportIntroMessage.
  ///
  /// In en, this message translates to:
  /// **'Send us any suggestion or comment you have'**
  String get supportIntroMessage;

  /// No description provided for @messagesInboxLabel.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesInboxLabel;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @messageQuestionTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Question title:'**
  String get messageQuestionTitleLabel;

  /// No description provided for @messageNoThreadYet.
  ///
  /// In en, this message translates to:
  /// **'No messages in this thread yet'**
  String get messageNoThreadYet;

  /// No description provided for @messageReplyAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get messageReplyAppBarTitle;

  /// No description provided for @messageReplyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Reply:'**
  String get messageReplyPrefix;

  /// No description provided for @messageReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write your reply here'**
  String get messageReplyHint;

  /// No description provided for @signOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutDialogTitle;

  /// No description provided for @signOutDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutDialogMessage;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @signOutConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutConfirmButton;

  /// No description provided for @navigationErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Navigation error: '**
  String get navigationErrorPrefix;

  /// No description provided for @signOutErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error signing out: '**
  String get signOutErrorPrefix;

  /// No description provided for @guestUserLabel.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestUserLabel;

  /// No description provided for @fieldRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get fieldRequiredValidation;

  /// No description provided for @selectProductColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a product color'**
  String get selectProductColorTitle;

  /// No description provided for @addToCartLabel.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCartLabel;

  /// No description provided for @couldNotOpenUrlPrefix.
  ///
  /// In en, this message translates to:
  /// **'Could not open URL: '**
  String get couldNotOpenUrlPrefix;

  /// No description provided for @paymentFailedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Payment failed: '**
  String get paymentFailedPrefix;

  /// No description provided for @failedLoadOrderDetailsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Failed to load order details: '**
  String get failedLoadOrderDetailsPrefix;

  /// No description provided for @invalidOrderId.
  ///
  /// In en, this message translates to:
  /// **'Invalid order ID'**
  String get invalidOrderId;

  /// No description provided for @noWasteAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No waste added yet'**
  String get noWasteAddedYet;

  /// No description provided for @pleaseSelectUserType.
  ///
  /// In en, this message translates to:
  /// **'Please select a user type'**
  String get pleaseSelectUserType;

  /// No description provided for @informationUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Information updated successfully'**
  String get informationUpdatedSuccess;

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @editLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editLabel;

  /// No description provided for @failedToLoadDataRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data. Please try again.'**
  String get failedToLoadDataRetry;

  /// No description provided for @pleaseSelectCollectionHour.
  ///
  /// In en, this message translates to:
  /// **'Please select a collection hour'**
  String get pleaseSelectCollectionHour;

  /// No description provided for @invalidTimeSelection.
  ///
  /// In en, this message translates to:
  /// **'Invalid time selection'**
  String get invalidTimeSelection;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @failedToLoadMoreItems.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more items. Please try again.'**
  String get failedToLoadMoreItems;

  /// No description provided for @cartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartIsEmpty;

  /// No description provided for @failedSendRequestPrefix.
  ///
  /// In en, this message translates to:
  /// **'Failed to send request: '**
  String get failedSendRequestPrefix;

  /// No description provided for @pleaseAddWasteItems.
  ///
  /// In en, this message translates to:
  /// **'Please add waste items to your cart'**
  String get pleaseAddWasteItems;

  /// No description provided for @addWasteItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add waste items'**
  String get addWasteItemsTitle;

  /// No description provided for @noItemsInCart.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItemsInCart;

  /// No description provided for @pleaseSelectLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Please select a location on the map'**
  String get pleaseSelectLocationOnMap;

  /// No description provided for @pleaseSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Please select a country'**
  String get pleaseSelectCountry;

  /// No description provided for @pleaseSelectProvince.
  ///
  /// In en, this message translates to:
  /// **'Please select a province'**
  String get pleaseSelectProvince;

  /// No description provided for @pleaseSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get pleaseSelectCity;

  /// No description provided for @pleaseSelectRegion.
  ///
  /// In en, this message translates to:
  /// **'Please select a region'**
  String get pleaseSelectRegion;

  /// No description provided for @addressSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address saved successfully'**
  String get addressSavedSuccess;

  /// No description provided for @failedSaveAddress.
  ///
  /// In en, this message translates to:
  /// **'Failed to save address. Please try again.'**
  String get failedSaveAddress;

  /// No description provided for @errorRemovingAddressPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error removing address: '**
  String get errorRemovingAddressPrefix;

  /// No description provided for @failedLoadAddressesPrefix.
  ///
  /// In en, this message translates to:
  /// **'Failed to load addresses: '**
  String get failedLoadAddressesPrefix;

  /// No description provided for @pleaseSelectAddress.
  ///
  /// In en, this message translates to:
  /// **'Please select an address'**
  String get pleaseSelectAddress;

  /// No description provided for @authProblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Authentication problem'**
  String get authProblemTitle;

  /// No description provided for @addressSingular.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressSingular;

  /// No description provided for @addressesPlural.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addressesPlural;

  /// No description provided for @navMyRequestsTab.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get navMyRequestsTab;

  /// No description provided for @onTapUrlDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get onTapUrlDebugTitle;

  /// No description provided for @wasteCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Waste cart'**
  String get wasteCartTitle;

  /// No description provided for @failedLoadCountriesRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load countries. Check your connection and try again.'**
  String get failedLoadCountriesRetry;

  /// No description provided for @failedLoadProvincesRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load provinces. Check your connection and try again.'**
  String get failedLoadProvincesRetry;

  /// No description provided for @failedLoadCitiesRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cities. Check your connection and try again.'**
  String get failedLoadCitiesRetry;

  /// No description provided for @failedLoadRegionsRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load regions. Check your connection and try again.'**
  String get failedLoadRegionsRetry;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingLabel;

  /// No description provided for @selectCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get selectCountryHint;

  /// No description provided for @selectProvinceHint.
  ///
  /// In en, this message translates to:
  /// **'Select province'**
  String get selectProvinceHint;

  /// No description provided for @selectCityHint.
  ///
  /// In en, this message translates to:
  /// **'Select city'**
  String get selectCityHint;

  /// No description provided for @selectRegionHint.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get selectRegionHint;

  /// No description provided for @signInRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get signInRequiredTitle;

  /// No description provided for @pleaseLoginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue.'**
  String get pleaseLoginToContinue;

  /// No description provided for @okLabel.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okLabel;

  /// No description provided for @confirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmLabel;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameHint;

  /// No description provided for @emailInputHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailInputHint;

  /// No description provided for @passwordInputHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordInputHint;

  /// No description provided for @userInformationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'User information'**
  String get userInformationDialogTitle;

  /// No description provided for @profileInformationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile information'**
  String get profileInformationDialogTitle;

  /// No description provided for @goToLoginScreenButton.
  ///
  /// In en, this message translates to:
  /// **'Login screen'**
  String get goToLoginScreenButton;

  /// No description provided for @goToProfileScreenButton.
  ///
  /// In en, this message translates to:
  /// **'Profile screen'**
  String get goToProfileScreenButton;

  /// No description provided for @completeProfileToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile to continue.'**
  String get completeProfileToContinue;

  /// No description provided for @personalInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformationTitle;

  /// No description provided for @contactInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get contactInformationTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @userTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'User type'**
  String get userTypeLabel;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailAddressLabel;

  /// No description provided for @provinceFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get provinceFieldLabel;

  /// No description provided for @countryFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryFieldLabel;

  /// No description provided for @cityFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityFieldLabel;

  /// No description provided for @regionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get regionFieldLabel;

  /// No description provided for @zipCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Zip code'**
  String get zipCodeLabel;

  /// No description provided for @mapPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select address location'**
  String get mapPickerTitle;

  /// No description provided for @newAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'New address'**
  String get newAddressTitle;

  /// No description provided for @locationDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Location details'**
  String get locationDetailsSection;

  /// No description provided for @addressNameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Address name'**
  String get addressNameFieldLabel;

  /// No description provided for @addressNameHintExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, Office'**
  String get addressNameHintExample;

  /// No description provided for @pleaseEnterAddressName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name for this address'**
  String get pleaseEnterAddressName;

  /// No description provided for @fullAddressFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Full address'**
  String get fullAddressFieldLabel;

  /// No description provided for @fullAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, number, building…'**
  String get fullAddressHint;

  /// No description provided for @pleaseEnterFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter the full address'**
  String get pleaseEnterFullAddress;

  /// No description provided for @saveAddressButton.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get saveAddressButton;

  /// No description provided for @tapToSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap to select location'**
  String get tapToSelectLocation;

  /// No description provided for @tapToChangeLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap to change location'**
  String get tapToChangeLocation;

  /// No description provided for @cartItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get cartItemsLabel;

  /// No description provided for @cartTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotalLabel;

  /// No description provided for @weightKgFullLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKgFullLabel;

  /// No description provided for @addItemsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add items'**
  String get addItemsTooltip;

  /// No description provided for @numberFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get numberFieldLabel;

  /// No description provided for @totalPriceFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Total price'**
  String get totalPriceFieldLabel;

  /// No description provided for @totalWeightFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Total weight'**
  String get totalWeightFieldLabel;

  /// No description provided for @collectDateFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Collection date'**
  String get collectDateFieldLabel;

  /// No description provided for @collectHourFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Collection time'**
  String get collectHourFieldLabel;

  /// No description provided for @regionColonPrefix.
  ///
  /// In en, this message translates to:
  /// **'Region:'**
  String get regionColonPrefix;

  /// No description provided for @driverInformationSection.
  ///
  /// In en, this message translates to:
  /// **'Driver information'**
  String get driverInformationSection;

  /// No description provided for @orderSummarySection.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummarySection;

  /// No description provided for @detailsSection.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsSection;

  /// No description provided for @wasteItemsSection.
  ///
  /// In en, this message translates to:
  /// **'Waste items'**
  String get wasteItemsSection;

  /// No description provided for @summaryWeightKgTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get summaryWeightKgTitle;

  /// No description provided for @summaryPriceUsdTitle.
  ///
  /// In en, this message translates to:
  /// **'Price (\$)'**
  String get summaryPriceUsdTitle;

  /// No description provided for @statusRequestLabel.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get statusRequestLabel;

  /// No description provided for @statusDeliveredLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDeliveredLabel;

  /// No description provided for @composeMessageTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get composeMessageTitleLabel;

  /// No description provided for @composeMessageBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Write your message'**
  String get composeMessageBodyHint;

  /// No description provided for @understandLabel.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get understandLabel;

  /// No description provided for @ordersLabel.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersLabel;

  /// No description provided for @personalInfoShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal info'**
  String get personalInfoShortLabel;

  /// No description provided for @wasteListTitle.
  ///
  /// In en, this message translates to:
  /// **'Waste list'**
  String get wasteListTitle;

  /// No description provided for @addressListTitle.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressListTitle;

  /// No description provided for @addNewAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Add new address'**
  String get addNewAddressLabel;

  /// No description provided for @requestCollectionHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Request collection'**
  String get requestCollectionHeroTitle;

  /// No description provided for @templatePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get templatePageTitle;

  /// No description provided for @drawerLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get drawerLoginTitle;

  /// No description provided for @drawerGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get drawerGuideTitle;

  /// No description provided for @drawerLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get drawerLogoutTitle;

  /// No description provided for @searchProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Search products…'**
  String get searchProductsHint;

  /// No description provided for @homeWelcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Recycle Origin'**
  String get homeWelcomeHeadline;

  /// No description provided for @homeWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make a difference for our planet'**
  String get homeWelcomeSubtitle;

  /// No description provided for @selectWasteTitle.
  ///
  /// In en, this message translates to:
  /// **'Select waste'**
  String get selectWasteTitle;

  /// No description provided for @shopCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping cart'**
  String get shopCartTitle;

  /// No description provided for @cartNumberSummaryPrefix.
  ///
  /// In en, this message translates to:
  /// **'Number:'**
  String get cartNumberSummaryPrefix;

  /// No description provided for @cartTotalSummaryPrefix.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get cartTotalSummaryPrefix;

  /// No description provided for @loginToContinueShort.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue'**
  String get loginToContinueShort;

  /// No description provided for @completeProfileShort.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to continue'**
  String get completeProfileShort;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @profileRequestsMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get profileRequestsMenuTitle;

  /// No description provided for @newMessageScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessageScreenTitle;

  /// No description provided for @composeMessageIntroParagraph.
  ///
  /// In en, this message translates to:
  /// **'Please enter your question. Our team will review it and send you an answer.'**
  String get composeMessageIntroParagraph;

  /// No description provided for @authConfirmationCodeButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirmation code'**
  String get authConfirmationCodeButtonLabel;

  /// No description provided for @valueNotAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get valueNotAvailableLabel;

  /// No description provided for @requestDetailsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Request details'**
  String get requestDetailsSectionTitle;

  /// No description provided for @registerWasteRequestAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Register request'**
  String get registerWasteRequestAppBarTitle;

  /// No description provided for @wasteRequestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your request has been sent successfully.'**
  String get wasteRequestSentSuccess;

  /// No description provided for @pleaseLoginToViewWallet.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your wallet'**
  String get pleaseLoginToViewWallet;

  /// No description provided for @walletNoTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get walletNoTransactionsYet;

  /// No description provided for @walletWithdrawRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw request'**
  String get walletWithdrawRequestButton;

  /// No description provided for @clearingPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get clearingPayTitle;

  /// No description provided for @clearingRequestRegisteredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your request was registered successfully.'**
  String get clearingRequestRegisteredSuccess;

  /// No description provided for @walletCreditUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit (\$)'**
  String get walletCreditUsdLabel;

  /// No description provided for @clearingAccountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get clearingAccountNumberLabel;

  /// No description provided for @clearingRequestAmountUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'Request amount (\$)'**
  String get clearingRequestAmountUsdLabel;

  /// No description provided for @clearingPaymentListTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment list'**
  String get clearingPaymentListTitle;

  /// No description provided for @clearingEnterAccountNumberSnack.
  ///
  /// In en, this message translates to:
  /// **'Enter an account number'**
  String get clearingEnterAccountNumberSnack;

  /// No description provided for @clearingAmountExceedsBalance.
  ///
  /// In en, this message translates to:
  /// **'Your request amount exceeds your available balance'**
  String get clearingAmountExceedsBalance;

  /// No description provided for @tableColumnFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get tableColumnFromLabel;

  /// No description provided for @tableColumnStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get tableColumnStatusLabel;

  /// No description provided for @tableColumnDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get tableColumnDateLabel;

  /// No description provided for @drawerHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recycle Origin'**
  String get drawerHeaderSubtitle;

  /// No description provided for @parentheticalUsd.
  ///
  /// In en, this message translates to:
  /// **'(\$)'**
  String get parentheticalUsd;

  /// No description provided for @parentheticalKg.
  ///
  /// In en, this message translates to:
  /// **'(kg)'**
  String get parentheticalKg;

  /// No description provided for @selectUserTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select user type'**
  String get selectUserTypeHint;

  /// No description provided for @saveChangesLabel.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChangesLabel;

  /// No description provided for @savingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingLabel;

  /// No description provided for @editPersonalInformationAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit personal information'**
  String get editPersonalInformationAppBarTitle;

  /// No description provided for @failedLoadUserTypesMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user types. Please try again.'**
  String get failedLoadUserTypesMessage;

  /// No description provided for @failedSaveCustomerInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to save information. Please try again.'**
  String get failedSaveCustomerInfoMessage;

  /// No description provided for @orderNoItemsInCartSnack.
  ///
  /// In en, this message translates to:
  /// **'No items in cart.'**
  String get orderNoItemsInCartSnack;

  /// No description provided for @orderInsufficientWalletSnack.
  ///
  /// In en, this message translates to:
  /// **'Your wallet balance is not enough.'**
  String get orderInsufficientWalletSnack;

  /// No description provided for @orderSentSuccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Your order has been sent successfully.'**
  String get orderSentSuccessDescription;

  /// No description provided for @productPriceZeroSnack.
  ///
  /// In en, this message translates to:
  /// **'Price is not set for this product.'**
  String get productPriceZeroSnack;

  /// No description provided for @productAlreadyInCartSnack.
  ///
  /// In en, this message translates to:
  /// **'This product is already in your cart.'**
  String get productAlreadyInCartSnack;

  /// No description provided for @productAddedToCartSnack.
  ///
  /// In en, this message translates to:
  /// **'Added to cart.'**
  String get productAddedToCartSnack;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
