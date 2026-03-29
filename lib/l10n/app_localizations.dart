import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_nl.dart';

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
    Locale('fr'),
    Locale('nl')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Budget'**
  String get appTitle;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonValidate.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonValidate;

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your family budget.'**
  String get loginSubtitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account to start managing your family budget.'**
  String get signupSubtitle;

  /// No description provided for @loginPrimaryButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginPrimaryButton;

  /// No description provided for @signupPrimaryButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupPrimaryButton;

  /// No description provided for @loginSwitchToSignup.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get loginSwitchToSignup;

  /// No description provided for @loginSwitchToSignin.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get loginSwitchToSignin;

  /// No description provided for @loginFirebaseSecure.
  ///
  /// In en, this message translates to:
  /// **'Secure sign in with Firebase'**
  String get loginFirebaseSecure;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get loginSending;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get loginProcessing;

  /// No description provided for @loginEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get loginEnterEmail;

  /// No description provided for @loginInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get loginInvalidEmail;

  /// No description provided for @loginEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginEnterPassword;

  /// No description provided for @loginPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 6 characters'**
  String get loginPasswordMinLength;

  /// No description provided for @loginAccountCreatedVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Account created. A verification email has been sent to {email}.'**
  String loginAccountCreatedVerificationSent(Object email);

  /// No description provided for @loginPasswordResetSent.
  ///
  /// In en, this message translates to:
  /// **'A password reset email has been sent to {email}.'**
  String loginPasswordResetSent(Object email);

  /// No description provided for @emailVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email address'**
  String get emailVerificationTitle;

  /// No description provided for @emailVerificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verification is required before accessing your budget.'**
  String get emailVerificationSubtitle;

  /// No description provided for @emailVerificationAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailVerificationAddressLabel;

  /// No description provided for @emailVerificationAddressUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Email address unavailable'**
  String get emailVerificationAddressUnavailable;

  /// No description provided for @emailVerificationInstruction.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent. Click the link you received, then come back to the app.'**
  String get emailVerificationInstruction;

  /// No description provided for @emailVerificationSpamHint.
  ///
  /// In en, this message translates to:
  /// **'Also check your spam / junk folder.'**
  String get emailVerificationSpamHint;

  /// No description provided for @emailVerificationNotVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'The email address is not verified yet.'**
  String get emailVerificationNotVerifiedYet;

  /// No description provided for @emailVerificationYourEmail.
  ///
  /// In en, this message translates to:
  /// **'your email address'**
  String get emailVerificationYourEmail;

  /// No description provided for @emailVerificationChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get emailVerificationChecking;

  /// No description provided for @emailVerificationConfirmed.
  ///
  /// In en, this message translates to:
  /// **'I verified it'**
  String get emailVerificationConfirmed;

  /// No description provided for @emailVerificationSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get emailVerificationSending;

  /// No description provided for @emailVerificationResend.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get emailVerificationResend;

  /// No description provided for @emailVerificationSigningOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out...'**
  String get emailVerificationSigningOut;

  /// No description provided for @emailVerificationSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get emailVerificationSignOut;

  /// No description provided for @emailVerificationResent.
  ///
  /// In en, this message translates to:
  /// **'A new verification email has been sent to {email}.'**
  String emailVerificationResent(Object email);

  /// No description provided for @welcomeHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal or family budget, track your expenses and savings, and review your results month after month.'**
  String get welcomeHeroDescription;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Get started simply'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account to sync your budget, enable family features, and access your data across multiple devices.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeFeatureBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget tracking'**
  String get welcomeFeatureBudgetTitle;

  /// No description provided for @welcomeFeatureBudgetDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your income, expenses, savings and monthly balance.'**
  String get welcomeFeatureBudgetDescription;

  /// No description provided for @welcomeFeatureAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget analysis'**
  String get welcomeFeatureAnalysisTitle;

  /// No description provided for @welcomeFeatureAnalysisDescription.
  ///
  /// In en, this message translates to:
  /// **'Compare periods and view important trends.'**
  String get welcomeFeatureAnalysisDescription;

  /// No description provided for @welcomeFeatureFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Family mode'**
  String get welcomeFeatureFamilyTitle;

  /// No description provided for @welcomeFeatureFamilyDescription.
  ///
  /// In en, this message translates to:
  /// **'Share a common budget with cloud synchronization.'**
  String get welcomeFeatureFamilyDescription;

  /// No description provided for @welcomePremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Free and Premium version'**
  String get welcomePremiumTitle;

  /// No description provided for @welcomePremiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Start for free, then unlock advanced analysis, advice, Excel export and family features with Premium.'**
  String get welcomePremiumDescription;

  /// No description provided for @welcomePremiumButton.
  ///
  /// In en, this message translates to:
  /// **'See Premium offers'**
  String get welcomePremiumButton;

  /// No description provided for @welcomeCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get welcomeCreateAccount;

  /// No description provided for @welcomeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get welcomeSignIn;

  /// No description provided for @dashboardIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get dashboardIncome;

  /// No description provided for @dashboardExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get dashboardExpenses;

  /// No description provided for @dashboardSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get dashboardSavings;

  /// No description provided for @dashboardBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get dashboardBalance;

  /// No description provided for @dashboardFamilyIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Family ID copied.'**
  String get dashboardFamilyIdCopied;

  /// No description provided for @dashboardFamilyShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Invite to family budget'**
  String get dashboardFamilyShareSubject;

  /// No description provided for @dashboardFamilyShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Join my family budget with this ID: {familyId}'**
  String dashboardFamilyShareMessage(Object familyId);

  /// No description provided for @dashboardFamilyShareError.
  ///
  /// In en, this message translates to:
  /// **'Unable to share family ID: {error}'**
  String dashboardFamilyShareError(Object error);

  /// No description provided for @dashboardTransferOwnershipTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer ownership'**
  String get dashboardTransferOwnershipTitle;

  /// No description provided for @dashboardTransferOwnershipMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose the member who will become the family budget owner.'**
  String get dashboardTransferOwnershipMessage;

  /// No description provided for @dashboardMemberLabel.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get dashboardMemberLabel;

  /// No description provided for @dashboardTransferOwnershipHint.
  ///
  /// In en, this message translates to:
  /// **'After the transfer, this member will be able to manage the family.'**
  String get dashboardTransferOwnershipHint;

  /// No description provided for @dashboardTransferOwnershipAction.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get dashboardTransferOwnershipAction;

  /// No description provided for @dashboardDeleteFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete family'**
  String get dashboardDeleteFamilyTitle;

  /// No description provided for @dashboardDeleteFamilyIntro.
  ///
  /// In en, this message translates to:
  /// **'You are about to permanently delete the family.'**
  String get dashboardDeleteFamilyIntro;

  /// No description provided for @dashboardDeleteFamilyConsequences.
  ///
  /// In en, this message translates to:
  /// **'Consequences:'**
  String get dashboardDeleteFamilyConsequences;

  /// No description provided for @dashboardDeleteFamilyConsequenceMembers.
  ///
  /// In en, this message translates to:
  /// **'• All members will lose access to the shared budget.'**
  String get dashboardDeleteFamilyConsequenceMembers;

  /// No description provided for @dashboardDeleteFamilyConsequenceBudget.
  ///
  /// In en, this message translates to:
  /// **'• The shared family budget will be deleted.'**
  String get dashboardDeleteFamilyConsequenceBudget;

  /// No description provided for @dashboardDeleteFamilyConsequencePersonal.
  ///
  /// In en, this message translates to:
  /// **'• Personal budgets remain separate.'**
  String get dashboardDeleteFamilyConsequencePersonal;

  /// No description provided for @dashboardDeleteFamilyIrreversible.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get dashboardDeleteFamilyIrreversible;

  /// No description provided for @dashboardDeleteFamilyAction.
  ///
  /// In en, this message translates to:
  /// **'Delete family'**
  String get dashboardDeleteFamilyAction;

  /// No description provided for @dashboardCreateFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a family'**
  String get dashboardCreateFamilyTitle;

  /// No description provided for @dashboardFamilyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get dashboardFamilyNameLabel;

  /// No description provided for @dashboardFamilyCreatedSharedActivated.
  ///
  /// In en, this message translates to:
  /// **'Family created and shared budget activated.'**
  String get dashboardFamilyCreatedSharedActivated;

  /// No description provided for @dashboardFamilyCreated.
  ///
  /// In en, this message translates to:
  /// **'Family created successfully.'**
  String get dashboardFamilyCreated;

  /// No description provided for @dashboardCreateFamilyError.
  ///
  /// In en, this message translates to:
  /// **'Unable to create family: {error}'**
  String dashboardCreateFamilyError(Object error);

  /// No description provided for @dashboardJoinFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a family'**
  String get dashboardJoinFamilyTitle;

  /// No description provided for @dashboardFamilyIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Family ID'**
  String get dashboardFamilyIdLabel;

  /// No description provided for @dashboardFamilyIdExample.
  ///
  /// In en, this message translates to:
  /// **'Example: ABC123XYZ'**
  String get dashboardFamilyIdExample;

  /// No description provided for @dashboardFamilyJoinedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Joined family successfully.'**
  String get dashboardFamilyJoinedSuccess;

  /// No description provided for @dashboardJoinFamilyError.
  ///
  /// In en, this message translates to:
  /// **'Unable to join family: {error}'**
  String dashboardJoinFamilyError(Object error);

  /// No description provided for @dashboardNoMemberAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'No member available'**
  String get dashboardNoMemberAvailableTitle;

  /// No description provided for @dashboardNoMemberAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'No other member is available to receive ownership.'**
  String get dashboardNoMemberAvailableMessage;

  /// No description provided for @dashboardTransferOwnershipSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ownership transferred successfully.'**
  String get dashboardTransferOwnershipSuccess;

  /// No description provided for @dashboardTransferOwnershipError.
  ///
  /// In en, this message translates to:
  /// **'Unable to transfer ownership: {error}'**
  String dashboardTransferOwnershipError(Object error);

  /// No description provided for @dashboardDeleteFamilySuccess.
  ///
  /// In en, this message translates to:
  /// **'Family deleted.'**
  String get dashboardDeleteFamilySuccess;

  /// No description provided for @dashboardDeleteFamilyError.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete family: {error}'**
  String dashboardDeleteFamilyError(Object error);

  /// No description provided for @dashboardLeaveFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave family'**
  String get dashboardLeaveFamilyTitle;

  /// No description provided for @dashboardLeaveFamilyChoiceIntro.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do when leaving the family?'**
  String get dashboardLeaveFamilyChoiceIntro;

  /// No description provided for @dashboardLeaveFamilyChoiceRestorePersonal.
  ///
  /// In en, this message translates to:
  /// **'Restore my previous personal budget.'**
  String get dashboardLeaveFamilyChoiceRestorePersonal;

  /// No description provided for @dashboardLeaveFamilyChoiceCopyFamily.
  ///
  /// In en, this message translates to:
  /// **'Copy the family budget into my personal budget.'**
  String get dashboardLeaveFamilyChoiceCopyFamily;

  /// No description provided for @dashboardLeaveFamilyRestoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore my budget'**
  String get dashboardLeaveFamilyRestoreAction;

  /// No description provided for @dashboardLeaveFamilyCopyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy family budget'**
  String get dashboardLeaveFamilyCopyAction;

  /// No description provided for @dashboardLeaveFamilyCopiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'You left the family and copied the family budget.'**
  String get dashboardLeaveFamilyCopiedSuccess;

  /// No description provided for @dashboardLeaveFamilyRestoredSuccess.
  ///
  /// In en, this message translates to:
  /// **'You left the family and restored your personal budget.'**
  String get dashboardLeaveFamilyRestoredSuccess;

  /// No description provided for @dashboardLeaveFamilyError.
  ///
  /// In en, this message translates to:
  /// **'Unable to leave family: {error}'**
  String dashboardLeaveFamilyError(Object error);

  /// No description provided for @dashboardAddCategoryForSection.
  ///
  /// In en, this message translates to:
  /// **'Add a category in {section}'**
  String dashboardAddCategoryForSection(Object section);

  /// No description provided for @dashboardCategoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get dashboardCategoryNameLabel;

  /// No description provided for @dashboardExistingCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Existing category'**
  String get dashboardExistingCategoryTitle;

  /// No description provided for @dashboardExistingCategoryInSection.
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists in {section}.'**
  String dashboardExistingCategoryInSection(Object section);

  /// No description provided for @dashboardRenameCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get dashboardRenameCategoryTitle;

  /// No description provided for @dashboardNewNameLabel.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get dashboardNewNameLabel;

  /// No description provided for @dashboardAnotherCategorySameName.
  ///
  /// In en, this message translates to:
  /// **'Another category already has this name.'**
  String get dashboardAnotherCategorySameName;

  /// No description provided for @dashboardAddExpenseCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense category'**
  String get dashboardAddExpenseCategoryTitle;

  /// No description provided for @dashboardExistingExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'This expense category already exists.'**
  String get dashboardExistingExpenseCategory;

  /// No description provided for @dashboardAddExpenseSubCategoryFor.
  ///
  /// In en, this message translates to:
  /// **'Add a subcategory in {category}'**
  String dashboardAddExpenseSubCategoryFor(Object category);

  /// No description provided for @dashboardSubCategoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Subcategory name'**
  String get dashboardSubCategoryNameLabel;

  /// No description provided for @dashboardExistingSubCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Existing subcategory'**
  String get dashboardExistingSubCategoryTitle;

  /// No description provided for @dashboardExistingSubCategoryIn.
  ///
  /// In en, this message translates to:
  /// **'This subcategory already exists in {category}.'**
  String dashboardExistingSubCategoryIn(Object category);

  /// No description provided for @dashboardRenameSubCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename subcategory'**
  String get dashboardRenameSubCategoryTitle;

  /// No description provided for @dashboardAnotherSubCategorySameNameIn.
  ///
  /// In en, this message translates to:
  /// **'Another subcategory already has this name in {category}.'**
  String dashboardAnotherSubCategorySameNameIn(Object category);

  /// No description provided for @dashboardAddAmountFor.
  ///
  /// In en, this message translates to:
  /// **'Add amount for {subCategory}'**
  String dashboardAddAmountFor(Object subCategory);

  /// No description provided for @dashboardAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get dashboardAmountLabel;

  /// No description provided for @dashboardInvalidAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get dashboardInvalidAmountTitle;

  /// No description provided for @dashboardInvalidAmountMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than 0.'**
  String get dashboardInvalidAmountMessage;

  /// No description provided for @dashboardRestoreSuccessPremium.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored, Premium activated.'**
  String get dashboardRestoreSuccessPremium;

  /// No description provided for @dashboardRestoreFinishedNoPremium.
  ///
  /// In en, this message translates to:
  /// **'Restore finished, no active Premium purchase found.'**
  String get dashboardRestoreFinishedNoPremium;

  /// No description provided for @dashboardRestoreError.
  ///
  /// In en, this message translates to:
  /// **'Restore error: {error}'**
  String dashboardRestoreError(Object error);

  /// No description provided for @dashboardPrivacyOpened.
  ///
  /// In en, this message translates to:
  /// **'Privacy options opened.'**
  String get dashboardPrivacyOpened;

  /// No description provided for @dashboardPrivacyNotRequired.
  ///
  /// In en, this message translates to:
  /// **'No privacy options required at the moment.'**
  String get dashboardPrivacyNotRequired;

  /// No description provided for @dashboardPrivacyError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open privacy options: {error}'**
  String dashboardPrivacyError(Object error);

  /// No description provided for @dashboardSignOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully.'**
  String get dashboardSignOutSuccess;

  /// No description provided for @dashboardSignOutError.
  ///
  /// In en, this message translates to:
  /// **'Sign out error: {error}'**
  String dashboardSignOutError(Object error);

  /// No description provided for @dashboardSubscriptionTooltip.
  ///
  /// In en, this message translates to:
  /// **'See Premium offers'**
  String get dashboardSubscriptionTooltip;

  /// No description provided for @dashboardOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get dashboardOptionsTooltip;

  /// No description provided for @dashboardMenuPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get dashboardMenuPremium;

  /// No description provided for @dashboardRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring...'**
  String get dashboardRestoring;

  /// No description provided for @dashboardRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get dashboardRestorePurchases;

  /// No description provided for @dashboardOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening...'**
  String get dashboardOpening;

  /// No description provided for @dashboardPrivacyRgpd.
  ///
  /// In en, this message translates to:
  /// **'Privacy / GDPR'**
  String get dashboardPrivacyRgpd;

  /// No description provided for @dashboardSigningOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out...'**
  String get dashboardSigningOut;

  /// No description provided for @dashboardSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get dashboardSignOut;

  /// No description provided for @dashboardConnectedAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String dashboardConnectedAs(Object email);

  /// No description provided for @dashboardFamilyModeActive.
  ///
  /// In en, this message translates to:
  /// **'Family mode active'**
  String get dashboardFamilyModeActive;

  /// No description provided for @dashboardPersonalBudgetActive.
  ///
  /// In en, this message translates to:
  /// **'Personal budget active'**
  String get dashboardPersonalBudgetActive;

  /// No description provided for @dashboardFamilySharedDescription.
  ///
  /// In en, this message translates to:
  /// **'The budget is currently shared with family members.'**
  String get dashboardFamilySharedDescription;

  /// No description provided for @dashboardPersonalBudgetDescription.
  ///
  /// In en, this message translates to:
  /// **'You are currently working on your personal budget.'**
  String get dashboardPersonalBudgetDescription;

  /// No description provided for @dashboardFamilyName.
  ///
  /// In en, this message translates to:
  /// **'Family: {name}'**
  String dashboardFamilyName(Object name);

  /// No description provided for @dashboardFamilyIdTitle.
  ///
  /// In en, this message translates to:
  /// **'Family ID'**
  String get dashboardFamilyIdTitle;

  /// No description provided for @dashboardProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get dashboardProcessing;

  /// No description provided for @dashboardTransferOwnershipPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium required to transfer'**
  String get dashboardTransferOwnershipPremium;

  /// No description provided for @dashboardDeleteFamilyPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium required to delete'**
  String get dashboardDeleteFamilyPremium;

  /// No description provided for @dashboardCreateFamilyAction.
  ///
  /// In en, this message translates to:
  /// **'Create family'**
  String get dashboardCreateFamilyAction;

  /// No description provided for @dashboardCreateFamilyPremium.
  ///
  /// In en, this message translates to:
  /// **'Create family (Premium)'**
  String get dashboardCreateFamilyPremium;

  /// No description provided for @dashboardJoinFamilyAction.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get dashboardJoinFamilyAction;

  /// No description provided for @dashboardFamilyPremiumHint.
  ///
  /// In en, this message translates to:
  /// **'Creating and advanced family management require Premium.'**
  String get dashboardFamilyPremiumHint;

  /// No description provided for @dashboardLeaveFamilyAction.
  ///
  /// In en, this message translates to:
  /// **'Leave family'**
  String get dashboardLeaveFamilyAction;

  /// No description provided for @dashboardPremiumActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'{plan} active'**
  String dashboardPremiumActiveLabel(Object plan);

  /// No description provided for @dashboardFreeVersionActive.
  ///
  /// In en, this message translates to:
  /// **'Free version active'**
  String get dashboardFreeVersionActive;

  /// No description provided for @dashboardSeeOffers.
  ///
  /// In en, this message translates to:
  /// **'See offers'**
  String get dashboardSeeOffers;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardActivePeriod.
  ///
  /// In en, this message translates to:
  /// **'Active period: {month} {year}'**
  String dashboardActivePeriod(Object month, Object year);

  /// No description provided for @dashboardYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get dashboardYearLabel;

  /// No description provided for @dashboardMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get dashboardMonthLabel;

  /// No description provided for @dashboardAnalysisAction.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get dashboardAnalysisAction;

  /// No description provided for @dashboardDetailAction.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get dashboardDetailAction;

  /// No description provided for @dashboardManagePremium.
  ///
  /// In en, this message translates to:
  /// **'Manage Premium'**
  String get dashboardManagePremium;

  /// No description provided for @dashboardSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get dashboardSubscription;

  /// No description provided for @dashboardRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get dashboardRestore;

  /// No description provided for @dashboardUnlockPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium features'**
  String get dashboardUnlockPremiumFeatures;

  /// No description provided for @dashboardPremiumBenefitsActive.
  ///
  /// In en, this message translates to:
  /// **'Excel export, smart analysis, premium family features and ad-free experience are active.'**
  String get dashboardPremiumBenefitsActive;

  /// No description provided for @dashboardPremiumBenefitsLocked.
  ///
  /// In en, this message translates to:
  /// **'Unlock Excel export, smart advice, premium family features and remove ads.'**
  String get dashboardPremiumBenefitsLocked;

  /// No description provided for @dashboardPremiumPillSmartAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Smart analysis'**
  String get dashboardPremiumPillSmartAnalysis;

  /// No description provided for @dashboardPremiumPillAdvice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get dashboardPremiumPillAdvice;

  /// No description provided for @dashboardPremiumPillExcel.
  ///
  /// In en, this message translates to:
  /// **'Excel export'**
  String get dashboardPremiumPillExcel;

  /// No description provided for @dashboardPremiumPillFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get dashboardPremiumPillFamily;

  /// No description provided for @dashboardManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get dashboardManageSubscription;

  /// No description provided for @dashboardSeePremiumOffers.
  ///
  /// In en, this message translates to:
  /// **'See Premium offers'**
  String get dashboardSeePremiumOffers;

  /// No description provided for @recapDetailOperationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Operation details'**
  String get recapDetailOperationsTitle;

  /// No description provided for @recapTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get recapTitle;

  /// No description provided for @recapOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get recapOperations;

  /// No description provided for @recapTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get recapTotalExpenses;

  /// No description provided for @recapEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses'**
  String get recapEmptyTitle;

  /// No description provided for @recapEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No operation has been recorded for this period.'**
  String get recapEmptyMessage;

  /// No description provided for @recapOperationsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} operation(s)'**
  String recapOperationsCount(Object count);

  /// No description provided for @recapDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get recapDelete;

  /// No description provided for @paywallAnnualTitle.
  ///
  /// In en, this message translates to:
  /// **'Annual Premium'**
  String get paywallAnnualTitle;

  /// No description provided for @paywallMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Premium'**
  String get paywallMonthlyTitle;

  /// No description provided for @paywallFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Premium'**
  String get paywallFamilyTitle;

  /// No description provided for @paywallAnnualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The best price to unlock all premium features.'**
  String get paywallAnnualSubtitle;

  /// No description provided for @paywallMonthlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flexible, without long-term commitment.'**
  String get paywallMonthlySubtitle;

  /// No description provided for @paywallFamilySubtitle.
  ///
  /// In en, this message translates to:
  /// **'To create and manage a shared family budget in premium mode.'**
  String get paywallFamilySubtitle;

  /// No description provided for @paywallDefaultPackageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock all premium features.'**
  String get paywallDefaultPackageSubtitle;

  /// No description provided for @paywallBadgeBestOffer.
  ///
  /// In en, this message translates to:
  /// **'Best offer'**
  String get paywallBadgeBestOffer;

  /// No description provided for @paywallBadgeFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get paywallBadgeFamily;

  /// No description provided for @paywallBadgeFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get paywallBadgeFlexible;

  /// No description provided for @paywallPurchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Premium activated successfully.'**
  String get paywallPurchaseSuccess;

  /// No description provided for @paywallPurchaseCanceled.
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled.'**
  String get paywallPurchaseCanceled;

  /// No description provided for @paywallPurchaseError.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete the purchase: {error}'**
  String paywallPurchaseError(Object error);

  /// No description provided for @paywallRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully.'**
  String get paywallRestoreSuccess;

  /// No description provided for @paywallRestoreNoPurchaseFound.
  ///
  /// In en, this message translates to:
  /// **'No active premium purchase found.'**
  String get paywallRestoreNoPurchaseFound;

  /// No description provided for @paywallRestoreError.
  ///
  /// In en, this message translates to:
  /// **'Error while restoring purchases: {error}'**
  String paywallRestoreError(Object error);

  /// No description provided for @paywallRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring...'**
  String get paywallRestoring;

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get paywallRestore;

  /// No description provided for @paywallUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock all premium features'**
  String get paywallUnlockTitle;

  /// No description provided for @paywallUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Excel export, smart tips, premium family management, advanced analysis and an ad-free experience.'**
  String get paywallUnlockSubtitle;

  /// No description provided for @paywallChooseOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get paywallChooseOfferTitle;

  /// No description provided for @paywallProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get paywallProcessing;

  /// No description provided for @paywallChooseOfferButton.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get paywallChooseOfferButton;

  /// No description provided for @paywallContinueWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Continue with {price}'**
  String paywallContinueWithPrice(Object price);

  /// No description provided for @paywallStoreNotice.
  ///
  /// In en, this message translates to:
  /// **'Subscription payment and management via Apple / Google.'**
  String get paywallStoreNotice;

  /// No description provided for @paywallImportantInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Important information'**
  String get paywallImportantInfoTitle;

  /// No description provided for @paywallImportantInfoBody.
  ///
  /// In en, this message translates to:
  /// **'• The subscription renews automatically according to store rules.\n• You can manage or cancel your subscription from your Apple / Google account.\n• Restore allows you to reactivate an existing purchase on the same store account.\n• Premium family creation and management depend on your active subscription.\n• Native family sharing also depends on App Store or Google Play rules.'**
  String get paywallImportantInfoBody;

  /// No description provided for @paywallPartialUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Monetization partially unavailable: {error}'**
  String paywallPartialUnavailable(Object error);

  /// No description provided for @paywallHeroPremiumActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium active'**
  String get paywallHeroPremiumActiveTitle;

  /// No description provided for @paywallHeroUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get paywallHeroUpgradeTitle;

  /// No description provided for @paywallHeroPremiumActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All premium features are already unlocked.'**
  String get paywallHeroPremiumActiveSubtitle;

  /// No description provided for @paywallHeroUpgradeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Excel export, smart advice, premium family management and an ad-free experience.'**
  String get paywallHeroUpgradeSubtitle;

  /// No description provided for @paywallFeatureExcelTitle.
  ///
  /// In en, this message translates to:
  /// **'Full Excel export'**
  String get paywallFeatureExcelTitle;

  /// No description provided for @paywallFeatureExcelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Detailed exports to manage and archive your budget.'**
  String get paywallFeatureExcelSubtitle;

  /// No description provided for @paywallFeatureAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart advice'**
  String get paywallFeatureAdviceTitle;

  /// No description provided for @paywallFeatureAdviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recommendations, alerts and advanced analysis.'**
  String get paywallFeatureAdviceSubtitle;

  /// No description provided for @paywallFeatureFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium family management'**
  String get paywallFeatureFamilyTitle;

  /// No description provided for @paywallFeatureFamilySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a family, transfer ownership and manage the shared structure.'**
  String get paywallFeatureFamilySubtitle;

  /// No description provided for @paywallFeatureNoAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get paywallFeatureNoAdsTitle;

  /// No description provided for @paywallFeatureNoAdsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A smoother experience for premium users.'**
  String get paywallFeatureNoAdsSubtitle;

  /// No description provided for @paywallFeatureFutureTitle.
  ///
  /// In en, this message translates to:
  /// **'Future features included'**
  String get paywallFeatureFutureTitle;

  /// No description provided for @paywallFeatureFutureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming premium improvements will be unlocked.'**
  String get paywallFeatureFutureSubtitle;

  /// No description provided for @paywallPremiumAlreadyActive.
  ///
  /// In en, this message translates to:
  /// **'Your premium subscription is already active.'**
  String get paywallPremiumAlreadyActive;

  /// No description provided for @paywallNoOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'No offer available'**
  String get paywallNoOfferTitle;

  /// No description provided for @paywallNoOfferMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your RevenueCat, App Store Connect or Google Play Console configuration.'**
  String get paywallNoOfferMessage;

  /// No description provided for @budgetSectionAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get budgetSectionAddButton;

  /// No description provided for @budgetSectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No category yet. Add a line.'**
  String get budgetSectionEmpty;

  /// No description provided for @budgetSectionAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get budgetSectionAmountLabel;

  /// No description provided for @budgetSectionTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String budgetSectionTotalLabel(Object amount);

  /// No description provided for @expenseSectionAddCategoryButton.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseSectionAddCategoryButton;

  /// No description provided for @expenseSectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No expense category. Add a category.'**
  String get expenseSectionEmpty;

  /// No description provided for @expenseSectionAddSubCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add subcategory'**
  String get expenseSectionAddSubCategoryTooltip;

  /// No description provided for @expenseSectionRenameCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get expenseSectionRenameCategoryTooltip;

  /// No description provided for @expenseSectionDeleteCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get expenseSectionDeleteCategoryTooltip;

  /// No description provided for @expenseSectionNoSubCategory.
  ///
  /// In en, this message translates to:
  /// **'No subcategory.'**
  String get expenseSectionNoSubCategory;

  /// No description provided for @expenseSectionDeleteSubCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete subcategory'**
  String get expenseSectionDeleteSubCategoryTooltip;

  /// No description provided for @expenseSectionOperationsCount.
  ///
  /// In en, this message translates to:
  /// **'Operations: {count}'**
  String expenseSectionOperationsCount(Object count);

  /// No description provided for @expenseSectionTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String expenseSectionTotalLabel(Object amount);

  /// No description provided for @expenseSectionAddAmountButton.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseSectionAddAmountButton;
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
      <String>['en', 'fr', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
