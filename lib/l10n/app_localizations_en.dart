// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Family Budget';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonValidate => 'Confirm';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonShare => 'Share';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get signupTitle => 'Create account';

  @override
  String get loginSubtitle => 'Sign in to access your family budget.';

  @override
  String get signupSubtitle =>
      'Create your account to start managing your family budget.';

  @override
  String get loginPrimaryButton => 'Sign in';

  @override
  String get signupPrimaryButton => 'Create account';

  @override
  String get loginSwitchToSignup => 'Create an account';

  @override
  String get loginSwitchToSignin => 'I already have an account';

  @override
  String get loginFirebaseSecure => 'Secure sign in with Firebase';

  @override
  String get loginEmailLabel => 'Email address';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSending => 'Sending...';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginProcessing => 'Processing...';

  @override
  String get loginEnterEmail => 'Enter your email address';

  @override
  String get loginInvalidEmail => 'Invalid email address';

  @override
  String get loginEnterPassword => 'Enter your password';

  @override
  String get loginPasswordMinLength =>
      'Password must contain at least 6 characters';

  @override
  String loginAccountCreatedVerificationSent(Object email) {
    return 'Account created. A verification email has been sent to $email.';
  }

  @override
  String loginPasswordResetSent(Object email) {
    return 'A password reset email has been sent to $email.';
  }

  @override
  String get emailVerificationTitle => 'Verify your email address';

  @override
  String get emailVerificationSubtitle =>
      'Verification is required before accessing your budget.';

  @override
  String get emailVerificationAddressLabel => 'Email address';

  @override
  String get emailVerificationAddressUnavailable => 'Email address unavailable';

  @override
  String get emailVerificationInstruction =>
      'A verification email has been sent. Click the link you received, then come back to the app.';

  @override
  String get emailVerificationSpamHint => 'Also check your spam / junk folder.';

  @override
  String get emailVerificationNotVerifiedYet =>
      'The email address is not verified yet.';

  @override
  String get emailVerificationYourEmail => 'your email address';

  @override
  String get emailVerificationChecking => 'Checking...';

  @override
  String get emailVerificationConfirmed => 'I verified it';

  @override
  String get emailVerificationSending => 'Sending...';

  @override
  String get emailVerificationResend => 'Resend email';

  @override
  String get emailVerificationSigningOut => 'Signing out...';

  @override
  String get emailVerificationSignOut => 'Sign out';

  @override
  String emailVerificationResent(Object email) {
    return 'A new verification email has been sent to $email.';
  }

  @override
  String get welcomeHeroDescription =>
      'Manage your personal or family budget, track your expenses and savings, and review your results month after month.';

  @override
  String get welcomeTitle => 'Get started simply';

  @override
  String get welcomeSubtitle =>
      'Create your account to sync your budget, enable family features, and access your data across multiple devices.';

  @override
  String get welcomeFeatureBudgetTitle => 'Budget tracking';

  @override
  String get welcomeFeatureBudgetDescription =>
      'Manage your income, expenses, savings and monthly balance.';

  @override
  String get welcomeFeatureAnalysisTitle => 'Budget analysis';

  @override
  String get welcomeFeatureAnalysisDescription =>
      'Compare periods and view important trends.';

  @override
  String get welcomeFeatureFamilyTitle => 'Family mode';

  @override
  String get welcomeFeatureFamilyDescription =>
      'Share a common budget with cloud synchronization.';

  @override
  String get welcomePremiumTitle => 'Free and Premium version';

  @override
  String get welcomePremiumDescription =>
      'Start for free, then unlock advanced analysis, advice, Excel export and family features with Premium.';

  @override
  String get welcomePremiumButton => 'See Premium offers';

  @override
  String get welcomeCreateAccount => 'Create an account';

  @override
  String get welcomeSignIn => 'Sign in';

  @override
  String get dashboardIncome => 'Income';

  @override
  String get dashboardExpenses => 'Expenses';

  @override
  String get dashboardSavings => 'Savings';

  @override
  String get dashboardBalance => 'Balance';

  @override
  String get dashboardFamilyIdCopied => 'Family ID copied.';

  @override
  String get dashboardFamilyShareSubject => 'Invite to family budget';

  @override
  String dashboardFamilyShareMessage(Object familyId) {
    return 'Join my family budget with this ID: $familyId';
  }

  @override
  String dashboardFamilyShareError(Object error) {
    return 'Unable to share family ID: $error';
  }

  @override
  String get dashboardTransferOwnershipTitle => 'Transfer ownership';

  @override
  String get dashboardTransferOwnershipMessage =>
      'Choose the member who will become the family budget owner.';

  @override
  String get dashboardMemberLabel => 'Member';

  @override
  String get dashboardTransferOwnershipHint =>
      'After the transfer, this member will be able to manage the family.';

  @override
  String get dashboardTransferOwnershipAction => 'Transfer';

  @override
  String get dashboardDeleteFamilyTitle => 'Delete family';

  @override
  String get dashboardDeleteFamilyIntro =>
      'You are about to permanently delete the family.';

  @override
  String get dashboardDeleteFamilyConsequences => 'Consequences:';

  @override
  String get dashboardDeleteFamilyConsequenceMembers =>
      '• All members will lose access to the shared budget.';

  @override
  String get dashboardDeleteFamilyConsequenceBudget =>
      '• The shared family budget will be deleted.';

  @override
  String get dashboardDeleteFamilyConsequencePersonal =>
      '• Personal budgets remain separate.';

  @override
  String get dashboardDeleteFamilyIrreversible =>
      'This action cannot be undone.';

  @override
  String get dashboardDeleteFamilyAction => 'Delete family';

  @override
  String get dashboardCreateFamilyTitle => 'Create a family';

  @override
  String get dashboardFamilyNameLabel => 'Family name';

  @override
  String get dashboardFamilyCreatedSharedActivated =>
      'Family created and shared budget activated.';

  @override
  String get dashboardFamilyCreated => 'Family created successfully.';

  @override
  String dashboardCreateFamilyError(Object error) {
    return 'Unable to create family: $error';
  }

  @override
  String get dashboardJoinFamilyTitle => 'Join a family';

  @override
  String get dashboardFamilyIdLabel => 'Family ID';

  @override
  String get dashboardFamilyIdExample => 'Example: ABC123XYZ';

  @override
  String get dashboardFamilyJoinedSuccess => 'Joined family successfully.';

  @override
  String dashboardJoinFamilyError(Object error) {
    return 'Unable to join family: $error';
  }

  @override
  String get dashboardNoMemberAvailableTitle => 'No member available';

  @override
  String get dashboardNoMemberAvailableMessage =>
      'No other member is available to receive ownership.';

  @override
  String get dashboardTransferOwnershipSuccess =>
      'Ownership transferred successfully.';

  @override
  String dashboardTransferOwnershipError(Object error) {
    return 'Unable to transfer ownership: $error';
  }

  @override
  String get dashboardDeleteFamilySuccess => 'Family deleted.';

  @override
  String dashboardDeleteFamilyError(Object error) {
    return 'Unable to delete family: $error';
  }

  @override
  String get dashboardLeaveFamilyTitle => 'Leave family';

  @override
  String get dashboardLeaveFamilyChoiceIntro =>
      'What do you want to do when leaving the family?';

  @override
  String get dashboardLeaveFamilyChoiceRestorePersonal =>
      'Restore my previous personal budget.';

  @override
  String get dashboardLeaveFamilyChoiceCopyFamily =>
      'Copy the family budget into my personal budget.';

  @override
  String get dashboardLeaveFamilyRestoreAction => 'Restore my budget';

  @override
  String get dashboardLeaveFamilyCopyAction => 'Copy family budget';

  @override
  String get dashboardLeaveFamilyCopiedSuccess =>
      'You left the family and copied the family budget.';

  @override
  String get dashboardLeaveFamilyRestoredSuccess =>
      'You left the family and restored your personal budget.';

  @override
  String dashboardLeaveFamilyError(Object error) {
    return 'Unable to leave family: $error';
  }

  @override
  String dashboardAddCategoryForSection(Object section) {
    return 'Add a category in $section';
  }

  @override
  String get dashboardCategoryNameLabel => 'Category name';

  @override
  String get dashboardExistingCategoryTitle => 'Existing category';

  @override
  String dashboardExistingCategoryInSection(Object section) {
    return 'A category with this name already exists in $section.';
  }

  @override
  String get dashboardRenameCategoryTitle => 'Rename category';

  @override
  String get dashboardNewNameLabel => 'New name';

  @override
  String get dashboardAnotherCategorySameName =>
      'Another category already has this name.';

  @override
  String get dashboardAddExpenseCategoryTitle => 'Add expense category';

  @override
  String get dashboardExistingExpenseCategory =>
      'This expense category already exists.';

  @override
  String dashboardAddExpenseSubCategoryFor(Object category) {
    return 'Add a subcategory in $category';
  }

  @override
  String get dashboardSubCategoryNameLabel => 'Subcategory name';

  @override
  String get dashboardExistingSubCategoryTitle => 'Existing subcategory';

  @override
  String dashboardExistingSubCategoryIn(Object category) {
    return 'This subcategory already exists in $category.';
  }

  @override
  String get dashboardRenameSubCategoryTitle => 'Rename subcategory';

  @override
  String dashboardAnotherSubCategorySameNameIn(Object category) {
    return 'Another subcategory already has this name in $category.';
  }

  @override
  String dashboardAddAmountFor(Object subCategory) {
    return 'Add amount for $subCategory';
  }

  @override
  String get dashboardAmountLabel => 'Amount';

  @override
  String get dashboardInvalidAmountTitle => 'Invalid amount';

  @override
  String get dashboardInvalidAmountMessage =>
      'Enter a valid amount greater than 0.';

  @override
  String get dashboardRestoreSuccessPremium =>
      'Purchases restored, Premium activated.';

  @override
  String get dashboardRestoreFinishedNoPremium =>
      'Restore finished, no active Premium purchase found.';

  @override
  String dashboardRestoreError(Object error) {
    return 'Restore error: $error';
  }

  @override
  String get dashboardPrivacyOpened => 'Privacy options opened.';

  @override
  String get dashboardPrivacyNotRequired =>
      'No privacy options required at the moment.';

  @override
  String dashboardPrivacyError(Object error) {
    return 'Unable to open privacy options: $error';
  }

  @override
  String get dashboardSignOutSuccess => 'Signed out successfully.';

  @override
  String dashboardSignOutError(Object error) {
    return 'Sign out error: $error';
  }

  @override
  String get dashboardSubscriptionTooltip => 'See Premium offers';

  @override
  String get dashboardOptionsTooltip => 'Options';

  @override
  String get dashboardMenuPremium => 'Premium';

  @override
  String get dashboardRestoring => 'Restoring...';

  @override
  String get dashboardRestorePurchases => 'Restore purchases';

  @override
  String get dashboardOpening => 'Opening...';

  @override
  String get dashboardPrivacyRgpd => 'Privacy / GDPR';

  @override
  String get dashboardSigningOut => 'Signing out...';

  @override
  String get dashboardSignOut => 'Sign out';

  @override
  String dashboardConnectedAs(Object email) {
    return 'Signed in as $email';
  }

  @override
  String get dashboardFamilyModeActive => 'Family mode active';

  @override
  String get dashboardPersonalBudgetActive => 'Personal budget active';

  @override
  String get dashboardFamilySharedDescription =>
      'The budget is currently shared with family members.';

  @override
  String get dashboardPersonalBudgetDescription =>
      'You are currently working on your personal budget.';

  @override
  String dashboardFamilyName(Object name) {
    return 'Family: $name';
  }

  @override
  String get dashboardFamilyIdTitle => 'Family ID';

  @override
  String get dashboardProcessing => 'Processing...';

  @override
  String get dashboardTransferOwnershipPremium =>
      'Premium required to transfer';

  @override
  String get dashboardDeleteFamilyPremium => 'Premium required to delete';

  @override
  String get dashboardCreateFamilyAction => 'Create family';

  @override
  String get dashboardCreateFamilyPremium => 'Create family (Premium)';

  @override
  String get dashboardJoinFamilyAction => 'Join';

  @override
  String get dashboardFamilyPremiumHint =>
      'Creating and advanced family management require Premium.';

  @override
  String get dashboardLeaveFamilyAction => 'Leave family';

  @override
  String dashboardPremiumActiveLabel(Object plan) {
    return '$plan active';
  }

  @override
  String get dashboardFreeVersionActive => 'Free version active';

  @override
  String get dashboardSeeOffers => 'See offers';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String dashboardActivePeriod(Object month, Object year) {
    return 'Active period: $month $year';
  }

  @override
  String get dashboardYearLabel => 'Year';

  @override
  String get dashboardMonthLabel => 'Month';

  @override
  String get dashboardAnalysisAction => 'Analysis';

  @override
  String get dashboardDetailAction => 'View details';

  @override
  String get dashboardManagePremium => 'Manage Premium';

  @override
  String get dashboardSubscription => 'Subscription';

  @override
  String get dashboardRestore => 'Restore';

  @override
  String get dashboardUnlockPremiumFeatures => 'Unlock Premium features';

  @override
  String get dashboardPremiumBenefitsActive =>
      'Excel export, smart analysis, premium family features and ad-free experience are active.';

  @override
  String get dashboardPremiumBenefitsLocked =>
      'Unlock Excel export, smart advice, premium family features and remove ads.';

  @override
  String get dashboardPremiumPillSmartAnalysis => 'Smart analysis';

  @override
  String get dashboardPremiumPillAdvice => 'Advice';

  @override
  String get dashboardPremiumPillExcel => 'Excel export';

  @override
  String get dashboardPremiumPillFamily => 'Family';

  @override
  String get dashboardManageSubscription => 'Manage subscription';

  @override
  String get dashboardSeePremiumOffers => 'See Premium offers';

  @override
  String get recapDetailOperationsTitle => 'Operation details';

  @override
  String get recapTitle => 'Summary';

  @override
  String get recapOperations => 'Operations';

  @override
  String get recapTotalExpenses => 'Total expenses';

  @override
  String get recapEmptyTitle => 'No expenses';

  @override
  String get recapEmptyMessage =>
      'No operation has been recorded for this period.';

  @override
  String recapOperationsCount(Object count) {
    return '$count operation(s)';
  }

  @override
  String get recapDelete => 'Delete';

  @override
  String get paywallAnnualTitle => 'Annual Premium';

  @override
  String get paywallMonthlyTitle => 'Monthly Premium';

  @override
  String get paywallFamilyTitle => 'Family Premium';

  @override
  String get paywallAnnualSubtitle =>
      'The best price to unlock all premium features.';

  @override
  String get paywallMonthlySubtitle =>
      'Flexible, without long-term commitment.';

  @override
  String get paywallFamilySubtitle =>
      'To create and manage a shared family budget in premium mode.';

  @override
  String get paywallDefaultPackageSubtitle => 'Unlock all premium features.';

  @override
  String get paywallBadgeBestOffer => 'Best offer';

  @override
  String get paywallBadgeFamily => 'Family';

  @override
  String get paywallBadgeFlexible => 'Flexible';

  @override
  String get paywallPurchaseSuccess => 'Premium activated successfully.';

  @override
  String get paywallPurchaseCanceled => 'Purchase cancelled.';

  @override
  String paywallPurchaseError(Object error) {
    return 'Unable to complete the purchase: $error';
  }

  @override
  String get paywallRestoreSuccess => 'Purchases restored successfully.';

  @override
  String get paywallRestoreNoPurchaseFound =>
      'No active premium purchase found.';

  @override
  String paywallRestoreError(Object error) {
    return 'Error while restoring purchases: $error';
  }

  @override
  String get paywallRestoring => 'Restoring...';

  @override
  String get paywallRestore => 'Restore';

  @override
  String get paywallUnlockTitle => 'Unlock all premium features';

  @override
  String get paywallUnlockSubtitle =>
      'Excel export, smart tips, premium family management, advanced analysis and an ad-free experience.';

  @override
  String get paywallChooseOfferTitle => 'Choose your plan';

  @override
  String get paywallProcessing => 'Processing...';

  @override
  String get paywallChooseOfferButton => 'Choose a plan';

  @override
  String paywallContinueWithPrice(Object price) {
    return 'Continue with $price';
  }

  @override
  String get paywallStoreNotice =>
      'Subscription payment and management via Apple / Google.';

  @override
  String get paywallImportantInfoTitle => 'Important information';

  @override
  String get paywallImportantInfoBody =>
      '• The subscription renews automatically according to store rules.\n• You can manage or cancel your subscription from your Apple / Google account.\n• Restore allows you to reactivate an existing purchase on the same store account.\n• Premium family creation and management depend on your active subscription.\n• Native family sharing also depends on App Store or Google Play rules.';

  @override
  String paywallPartialUnavailable(Object error) {
    return 'Monetization partially unavailable: $error';
  }

  @override
  String get paywallHeroPremiumActiveTitle => 'Premium active';

  @override
  String get paywallHeroUpgradeTitle => 'Upgrade to Premium';

  @override
  String get paywallHeroPremiumActiveSubtitle =>
      'All premium features are already unlocked.';

  @override
  String get paywallHeroUpgradeSubtitle =>
      'Unlock Excel export, smart advice, premium family management and an ad-free experience.';

  @override
  String get paywallFeatureExcelTitle => 'Full Excel export';

  @override
  String get paywallFeatureExcelSubtitle =>
      'Detailed exports to manage and archive your budget.';

  @override
  String get paywallFeatureAdviceTitle => 'Smart advice';

  @override
  String get paywallFeatureAdviceSubtitle =>
      'Recommendations, alerts and advanced analysis.';

  @override
  String get paywallFeatureFamilyTitle => 'Premium family management';

  @override
  String get paywallFeatureFamilySubtitle =>
      'Create a family, transfer ownership and manage the shared structure.';

  @override
  String get paywallFeatureNoAdsTitle => 'No ads';

  @override
  String get paywallFeatureNoAdsSubtitle =>
      'A smoother experience for premium users.';

  @override
  String get paywallFeatureFutureTitle => 'Future features included';

  @override
  String get paywallFeatureFutureSubtitle =>
      'Upcoming premium improvements will be unlocked.';

  @override
  String get paywallPremiumAlreadyActive =>
      'Your premium subscription is already active.';

  @override
  String get paywallNoOfferTitle => 'No offer available';

  @override
  String get paywallNoOfferMessage =>
      'Check your RevenueCat, App Store Connect or Google Play Console configuration.';

  @override
  String get budgetSectionAddButton => 'Add';

  @override
  String get budgetSectionEmpty => 'No category yet. Add a line.';

  @override
  String get budgetSectionAmountLabel => 'Amount';

  @override
  String budgetSectionTotalLabel(Object amount) {
    return 'Total: $amount';
  }

  @override
  String get expenseSectionAddCategoryButton => 'Category';

  @override
  String get expenseSectionEmpty => 'No expense category. Add a category.';

  @override
  String get expenseSectionAddSubCategoryTooltip => 'Add subcategory';

  @override
  String get expenseSectionRenameCategoryTooltip => 'Rename category';

  @override
  String get expenseSectionDeleteCategoryTooltip => 'Delete category';

  @override
  String get expenseSectionNoSubCategory => 'No subcategory.';

  @override
  String get expenseSectionDeleteSubCategoryTooltip => 'Delete subcategory';

  @override
  String expenseSectionOperationsCount(Object count) {
    return 'Operations: $count';
  }

  @override
  String expenseSectionTotalLabel(Object amount) {
    return 'Total: $amount';
  }

  @override
  String get expenseSectionAddAmountButton => 'Amount';
}
