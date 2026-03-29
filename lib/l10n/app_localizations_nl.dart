// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Gezinsbudget';

  @override
  String get monthJanuary => 'Januari';

  @override
  String get monthFebruary => 'Februari';

  @override
  String get monthMarch => 'Maart';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'Mei';

  @override
  String get monthJune => 'Juni';

  @override
  String get monthJuly => 'Juli';

  @override
  String get monthAugust => 'Augustus';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'Oktober';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Annuleren';

  @override
  String get commonValidate => 'Bevestigen';

  @override
  String get commonOptional => 'Optioneel';

  @override
  String get commonAdd => 'Toevoegen';

  @override
  String get commonCopy => 'Kopiëren';

  @override
  String get commonShare => 'Delen';

  @override
  String get loginTitle => 'Aanmelden';

  @override
  String get signupTitle => 'Account aanmaken';

  @override
  String get loginSubtitle => 'Meld je aan om toegang te krijgen tot je gezinsbudget.';

  @override
  String get signupSubtitle => 'Maak je account aan om je gezinsbudget te beheren.';

  @override
  String get loginPrimaryButton => 'Aanmelden';

  @override
  String get signupPrimaryButton => 'Mijn account aanmaken';

  @override
  String get loginSwitchToSignup => 'Account aanmaken';

  @override
  String get loginSwitchToSignin => 'Ik heb al een account';

  @override
  String get loginFirebaseSecure => 'Veilige aanmelding met Firebase';

  @override
  String get loginEmailLabel => 'E-mailadres';

  @override
  String get loginPasswordLabel => 'Wachtwoord';

  @override
  String get loginSending => 'Verzenden...';

  @override
  String get loginForgotPassword => 'Wachtwoord vergeten?';

  @override
  String get loginProcessing => 'Bezig...';

  @override
  String get loginEnterEmail => 'Vul je e-mailadres in';

  @override
  String get loginInvalidEmail => 'Ongeldig e-mailadres';

  @override
  String get loginEnterPassword => 'Vul je wachtwoord in';

  @override
  String get loginPasswordMinLength => 'Het wachtwoord moet minstens 6 tekens bevatten';

  @override
  String loginAccountCreatedVerificationSent(Object email) {
    return 'Account aangemaakt. Er is een verificatie-e-mail verzonden naar $email.';
  }

  @override
  String loginPasswordResetSent(Object email) {
    return 'Er is een e-mail voor het resetten van het wachtwoord verzonden naar $email.';
  }

  @override
  String get emailVerificationTitle => 'Verifieer je e-mailadres';

  @override
  String get emailVerificationSubtitle => 'Verificatie is vereist voordat je toegang krijgt tot je budget.';

  @override
  String get emailVerificationAddressLabel => 'E-mailadres';

  @override
  String get emailVerificationAddressUnavailable => 'E-mailadres niet beschikbaar';

  @override
  String get emailVerificationInstruction => 'Er is een verificatie-e-mail verzonden. Klik op de ontvangen link en keer daarna terug naar de app.';

  @override
  String get emailVerificationSpamHint => 'Controleer ook je map spam / ongewenst.';

  @override
  String get emailVerificationNotVerifiedYet => 'Het e-mailadres is nog niet geverifieerd.';

  @override
  String get emailVerificationYourEmail => 'je e-mailadres';

  @override
  String get emailVerificationChecking => 'Controleren...';

  @override
  String get emailVerificationConfirmed => 'Ik heb geverifieerd';

  @override
  String get emailVerificationSending => 'Verzenden...';

  @override
  String get emailVerificationResend => 'E-mail opnieuw verzenden';

  @override
  String get emailVerificationSigningOut => 'Afmelden...';

  @override
  String get emailVerificationSignOut => 'Afmelden';

  @override
  String emailVerificationResent(Object email) {
    return 'Er is een nieuwe verificatie-e-mail verzonden naar $email.';
  }

  @override
  String get welcomeHeroDescription => 'Beheer je persoonlijke of gezinsbudget, volg je uitgaven en besparingen en bekijk je resultaten maand na maand.';

  @override
  String get welcomeTitle => 'Begin eenvoudig';

  @override
  String get welcomeSubtitle => 'Maak je account aan om je budget te synchroniseren, gezinsfuncties te activeren en je gegevens op meerdere apparaten terug te vinden.';

  @override
  String get welcomeFeatureBudgetTitle => 'Budgetopvolging';

  @override
  String get welcomeFeatureBudgetDescription => 'Beheer je inkomsten, uitgaven, besparingen en maandelijks saldo.';

  @override
  String get welcomeFeatureAnalysisTitle => 'Budgetanalyse';

  @override
  String get welcomeFeatureAnalysisDescription => 'Vergelijk periodes en bekijk belangrijke trends.';

  @override
  String get welcomeFeatureFamilyTitle => 'Gezinsmodus';

  @override
  String get welcomeFeatureFamilyDescription => 'Deel een gezamenlijk budget met cloudsynchronisatie.';

  @override
  String get welcomePremiumTitle => 'Gratis en Premium versie';

  @override
  String get welcomePremiumDescription => 'Begin gratis en ontgrendel geavanceerde analyses, advies, Excel-export en gezinsfuncties met Premium.';

  @override
  String get welcomePremiumButton => 'Bekijk Premium-aanbiedingen';

  @override
  String get welcomeCreateAccount => 'Account aanmaken';

  @override
  String get welcomeSignIn => 'Aanmelden';

  @override
  String get dashboardIncome => 'Inkomsten';

  @override
  String get dashboardExpenses => 'Uitgaven';

  @override
  String get dashboardSavings => 'Besparingen';

  @override
  String get dashboardBalance => 'Saldo';

  @override
  String get dashboardFamilyIdCopied => 'Gezins-ID gekopieerd.';

  @override
  String get dashboardFamilyShareSubject => 'Uitnodiging voor gezinsbudget';

  @override
  String dashboardFamilyShareMessage(Object familyId) {
    return 'Sluit je aan bij mijn gezinsbudget met deze ID: $familyId';
  }

  @override
  String dashboardFamilyShareError(Object error) {
    return 'Kan gezins-ID niet delen: $error';
  }

  @override
  String get dashboardTransferOwnershipTitle => 'Eigendom overdragen';

  @override
  String get dashboardTransferOwnershipMessage => 'Kies het lid dat eigenaar wordt van het gezinsbudget.';

  @override
  String get dashboardMemberLabel => 'Lid';

  @override
  String get dashboardTransferOwnershipHint => 'Na de overdracht kan dit lid het gezin beheren.';

  @override
  String get dashboardTransferOwnershipAction => 'Overdragen';

  @override
  String get dashboardDeleteFamilyTitle => 'Gezin verwijderen';

  @override
  String get dashboardDeleteFamilyIntro => 'Je staat op het punt het gezin definitief te verwijderen.';

  @override
  String get dashboardDeleteFamilyConsequences => 'Gevolgen:';

  @override
  String get dashboardDeleteFamilyConsequenceMembers => '• Alle leden verliezen toegang tot het gedeelde budget.';

  @override
  String get dashboardDeleteFamilyConsequenceBudget => '• Het gedeelde gezinsbudget wordt verwijderd.';

  @override
  String get dashboardDeleteFamilyConsequencePersonal => '• Persoonlijke budgetten blijven gescheiden.';

  @override
  String get dashboardDeleteFamilyIrreversible => 'Deze actie kan niet ongedaan worden gemaakt.';

  @override
  String get dashboardDeleteFamilyAction => 'Gezin verwijderen';

  @override
  String get dashboardCreateFamilyTitle => 'Gezin aanmaken';

  @override
  String get dashboardFamilyNameLabel => 'Gezinsnaam';

  @override
  String get dashboardFamilyCreatedSharedActivated => 'Gezin aangemaakt en gedeeld budget geactiveerd.';

  @override
  String get dashboardFamilyCreated => 'Gezin succesvol aangemaakt.';

  @override
  String dashboardCreateFamilyError(Object error) {
    return 'Kan gezin niet aanmaken: $error';
  }

  @override
  String get dashboardJoinFamilyTitle => 'Bij een gezin aansluiten';

  @override
  String get dashboardFamilyIdLabel => 'Gezins-ID';

  @override
  String get dashboardFamilyIdExample => 'Voorbeeld: ABC123XYZ';

  @override
  String get dashboardFamilyJoinedSuccess => 'Succesvol bij gezin aangesloten.';

  @override
  String dashboardJoinFamilyError(Object error) {
    return 'Kan niet bij gezin aansluiten: $error';
  }

  @override
  String get dashboardNoMemberAvailableTitle => 'Geen lid beschikbaar';

  @override
  String get dashboardNoMemberAvailableMessage => 'Er is geen ander lid beschikbaar om het eigendom te ontvangen.';

  @override
  String get dashboardTransferOwnershipSuccess => 'Eigendom succesvol overgedragen.';

  @override
  String dashboardTransferOwnershipError(Object error) {
    return 'Kan eigendom niet overdragen: $error';
  }

  @override
  String get dashboardDeleteFamilySuccess => 'Gezin verwijderd.';

  @override
  String dashboardDeleteFamilyError(Object error) {
    return 'Kan gezin niet verwijderen: $error';
  }

  @override
  String get dashboardLeaveFamilyTitle => 'Gezin verlaten';

  @override
  String get dashboardLeaveFamilyChoiceIntro => 'Wat wil je doen wanneer je het gezin verlaat?';

  @override
  String get dashboardLeaveFamilyChoiceRestorePersonal => 'Mijn vorige persoonlijke budget herstellen.';

  @override
  String get dashboardLeaveFamilyChoiceCopyFamily => 'Het gezinsbudget kopiëren naar mijn persoonlijke budget.';

  @override
  String get dashboardLeaveFamilyRestoreAction => 'Mijn budget herstellen';

  @override
  String get dashboardLeaveFamilyCopyAction => 'Gezinsbudget kopiëren';

  @override
  String get dashboardLeaveFamilyCopiedSuccess => 'Je hebt het gezin verlaten en het gezinsbudget gekopieerd.';

  @override
  String get dashboardLeaveFamilyRestoredSuccess => 'Je hebt het gezin verlaten en je persoonlijke budget hersteld.';

  @override
  String dashboardLeaveFamilyError(Object error) {
    return 'Kan gezin niet verlaten: $error';
  }

  @override
  String dashboardAddCategoryForSection(Object section) {
    return 'Categorie toevoegen in $section';
  }

  @override
  String get dashboardCategoryNameLabel => 'Categorienaam';

  @override
  String get dashboardExistingCategoryTitle => 'Bestaande categorie';

  @override
  String dashboardExistingCategoryInSection(Object section) {
    return 'Er bestaat al een categorie met deze naam in $section.';
  }

  @override
  String get dashboardRenameCategoryTitle => 'Categorie hernoemen';

  @override
  String get dashboardNewNameLabel => 'Nieuwe naam';

  @override
  String get dashboardAnotherCategorySameName => 'Een andere categorie heeft al deze naam.';

  @override
  String get dashboardAddExpenseCategoryTitle => 'Uitgavencategorie toevoegen';

  @override
  String get dashboardExistingExpenseCategory => 'Deze uitgavencategorie bestaat al.';

  @override
  String dashboardAddExpenseSubCategoryFor(Object category) {
    return 'Subcategorie toevoegen in $category';
  }

  @override
  String get dashboardSubCategoryNameLabel => 'Naam van de subcategorie';

  @override
  String get dashboardExistingSubCategoryTitle => 'Bestaande subcategorie';

  @override
  String dashboardExistingSubCategoryIn(Object category) {
    return 'Deze subcategorie bestaat al in $category.';
  }

  @override
  String get dashboardRenameSubCategoryTitle => 'Subcategorie hernoemen';

  @override
  String dashboardAnotherSubCategorySameNameIn(Object category) {
    return 'Een andere subcategorie heeft al deze naam in $category.';
  }

  @override
  String dashboardAddAmountFor(Object subCategory) {
    return 'Bedrag toevoegen voor $subCategory';
  }

  @override
  String get dashboardAmountLabel => 'Bedrag';

  @override
  String get dashboardInvalidAmountTitle => 'Ongeldig bedrag';

  @override
  String get dashboardInvalidAmountMessage => 'Voer een geldig bedrag groter dan 0 in.';

  @override
  String get dashboardRestoreSuccessPremium => 'Aankopen hersteld, Premium geactiveerd.';

  @override
  String get dashboardRestoreFinishedNoPremium => 'Herstel voltooid, geen actieve Premium-aankoop gevonden.';

  @override
  String dashboardRestoreError(Object error) {
    return 'Fout bij herstellen: $error';
  }

  @override
  String get dashboardPrivacyOpened => 'Privacy-opties geopend.';

  @override
  String get dashboardPrivacyNotRequired => 'Momenteel zijn er geen privacy-opties vereist.';

  @override
  String dashboardPrivacyError(Object error) {
    return 'Kan privacy-opties niet openen: $error';
  }

  @override
  String get dashboardSignOutSuccess => 'Succesvol afgemeld.';

  @override
  String dashboardSignOutError(Object error) {
    return 'Fout bij afmelden: $error';
  }

  @override
  String get dashboardSubscriptionTooltip => 'Premium-aanbiedingen bekijken';

  @override
  String get dashboardOptionsTooltip => 'Opties';

  @override
  String get dashboardMenuPremium => 'Premium';

  @override
  String get dashboardRestoring => 'Herstellen...';

  @override
  String get dashboardRestorePurchases => 'Aankopen herstellen';

  @override
  String get dashboardOpening => 'Openen...';

  @override
  String get dashboardPrivacyRgpd => 'Privacy / GDPR';

  @override
  String get dashboardSigningOut => 'Afmelden...';

  @override
  String get dashboardSignOut => 'Afmelden';

  @override
  String dashboardConnectedAs(Object email) {
    return 'Aangemeld als $email';
  }

  @override
  String get dashboardFamilyModeActive => 'Gezinsmodus actief';

  @override
  String get dashboardPersonalBudgetActive => 'Persoonlijk budget actief';

  @override
  String get dashboardFamilySharedDescription => 'Het budget wordt momenteel gedeeld met gezinsleden.';

  @override
  String get dashboardPersonalBudgetDescription => 'Je werkt momenteel aan je persoonlijke budget.';

  @override
  String dashboardFamilyName(Object name) {
    return 'Gezin: $name';
  }

  @override
  String get dashboardFamilyIdTitle => 'Gezins-ID';

  @override
  String get dashboardProcessing => 'Bezig...';

  @override
  String get dashboardTransferOwnershipPremium => 'Premium vereist om over te dragen';

  @override
  String get dashboardDeleteFamilyPremium => 'Premium vereist om te verwijderen';

  @override
  String get dashboardCreateFamilyAction => 'Gezin aanmaken';

  @override
  String get dashboardCreateFamilyPremium => 'Gezin aanmaken (Premium)';

  @override
  String get dashboardJoinFamilyAction => 'Aansluiten';

  @override
  String get dashboardFamilyPremiumHint => 'Gezin aanmaken en geavanceerd gezinsbeheer vereisen Premium.';

  @override
  String get dashboardLeaveFamilyAction => 'Gezin verlaten';

  @override
  String dashboardPremiumActiveLabel(Object plan) {
    return '$plan actief';
  }

  @override
  String get dashboardFreeVersionActive => 'Gratis versie actief';

  @override
  String get dashboardSeeOffers => 'Aanbiedingen bekijken';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String dashboardActivePeriod(Object month, Object year) {
    return 'Actieve periode: $month $year';
  }

  @override
  String get dashboardYearLabel => 'Jaar';

  @override
  String get dashboardMonthLabel => 'Maand';

  @override
  String get dashboardAnalysisAction => 'Analyse';

  @override
  String get dashboardDetailAction => 'Details bekijken';

  @override
  String get dashboardManagePremium => 'Premium beheren';

  @override
  String get dashboardSubscription => 'Abonnement';

  @override
  String get dashboardRestore => 'Herstellen';

  @override
  String get dashboardUnlockPremiumFeatures => 'Ontgrendel Premium-functies';

  @override
  String get dashboardPremiumBenefitsActive => 'Excel-export, slimme analyses, premium gezinsfuncties en advertentievrije ervaring zijn actief.';

  @override
  String get dashboardPremiumBenefitsLocked => 'Ontgrendel Excel-export, slimme tips, premium gezinsfuncties en verwijder advertenties.';

  @override
  String get dashboardPremiumPillSmartAnalysis => 'Slimme analyse';

  @override
  String get dashboardPremiumPillAdvice => 'Advies';

  @override
  String get dashboardPremiumPillExcel => 'Excel-export';

  @override
  String get dashboardPremiumPillFamily => 'Gezin';

  @override
  String get dashboardManageSubscription => 'Abonnement beheren';

  @override
  String get dashboardSeePremiumOffers => 'Premium-aanbiedingen bekijken';

  @override
  String get recapDetailOperationsTitle => 'Details van verrichtingen';

  @override
  String get recapTitle => 'Overzicht';

  @override
  String get recapOperations => 'Verrichtingen';

  @override
  String get recapTotalExpenses => 'Totale uitgaven';

  @override
  String get recapEmptyTitle => 'Geen uitgaven';

  @override
  String get recapEmptyMessage => 'Er zijn geen verrichtingen geregistreerd voor deze periode.';

  @override
  String recapOperationsCount(Object count) {
    return '$count verrichting(en)';
  }

  @override
  String get recapDelete => 'Verwijderen';

  @override
  String get paywallAnnualTitle => 'Jaarlijks Premium';

  @override
  String get paywallMonthlyTitle => 'Maandelijks Premium';

  @override
  String get paywallFamilyTitle => 'Gezins-Premium';

  @override
  String get paywallAnnualSubtitle => 'De beste prijs om alle premiumfuncties te ontgrendelen.';

  @override
  String get paywallMonthlySubtitle => 'Flexibel, zonder langdurige verplichting.';

  @override
  String get paywallFamilySubtitle => 'Om een gedeeld gezinsbudget in premium te maken en te beheren.';

  @override
  String get paywallDefaultPackageSubtitle => 'Ontgrendel alle premiumfuncties.';

  @override
  String get paywallBadgeBestOffer => 'Beste aanbod';

  @override
  String get paywallBadgeFamily => 'Gezin';

  @override
  String get paywallBadgeFlexible => 'Flexibel';

  @override
  String get paywallPurchaseSuccess => 'Premium succesvol geactiveerd.';

  @override
  String get paywallPurchaseCanceled => 'Aankoop geannuleerd.';

  @override
  String paywallPurchaseError(Object error) {
    return 'Kan aankoop niet voltooien: $error';
  }

  @override
  String get paywallRestoreSuccess => 'Aankopen succesvol hersteld.';

  @override
  String get paywallRestoreNoPurchaseFound => 'Geen actieve Premium-aankoop gevonden.';

  @override
  String paywallRestoreError(Object error) {
    return 'Fout bij herstellen van aankopen: $error';
  }

  @override
  String get paywallRestoring => 'Herstellen...';

  @override
  String get paywallRestore => 'Herstellen';

  @override
  String get paywallUnlockTitle => 'Ontgrendel alle premiumfuncties';

  @override
  String get paywallUnlockSubtitle => 'Excel-export, slimme tips, premium gezinsbeheer, geavanceerde analyses en een advertentievrije ervaring.';

  @override
  String get paywallChooseOfferTitle => 'Kies je aanbod';

  @override
  String get paywallProcessing => 'Bezig...';

  @override
  String get paywallChooseOfferButton => 'Kies een aanbod';

  @override
  String paywallContinueWithPrice(Object price) {
    return 'Doorgaan met $price';
  }

  @override
  String get paywallStoreNotice => 'Betaling en beheer van het abonnement via Apple / Google.';

  @override
  String get paywallImportantInfoTitle => 'Belangrijke informatie';

  @override
  String get paywallImportantInfoBody => '• Het abonnement wordt automatisch verlengd volgens de regels van de store.\n• Je kunt je abonnement beheren of annuleren via je Apple- / Google-account.\n• Met herstellen kun je een bestaande aankoop op hetzelfde store-account opnieuw activeren.\n• Premium gezinscreatie en -beheer zijn afhankelijk van je actieve abonnement.\n• Native gezinsdeling hangt ook af van de regels van de App Store of Google Play.';

  @override
  String paywallPartialUnavailable(Object error) {
    return 'Monetisatie gedeeltelijk niet beschikbaar: $error';
  }

  @override
  String get paywallHeroPremiumActiveTitle => 'Premium actief';

  @override
  String get paywallHeroUpgradeTitle => 'Ga naar Premium';

  @override
  String get paywallHeroPremiumActiveSubtitle => 'Alle premiumfuncties zijn al ontgrendeld.';

  @override
  String get paywallHeroUpgradeSubtitle => 'Ontgrendel Excel-export, slimme tips, premium gezinsbeheer en een advertentievrije ervaring.';

  @override
  String get paywallFeatureExcelTitle => 'Volledige Excel-export';

  @override
  String get paywallFeatureExcelSubtitle => 'Gedetailleerde exports om je budget te beheren en te archiveren.';

  @override
  String get paywallFeatureAdviceTitle => 'Slim advies';

  @override
  String get paywallFeatureAdviceSubtitle => 'Aanbevelingen, waarschuwingen en geavanceerde analyses.';

  @override
  String get paywallFeatureFamilyTitle => 'Premium gezinsbeheer';

  @override
  String get paywallFeatureFamilySubtitle => 'Maak een gezin aan, draag eigendom over en beheer de gedeelde structuur.';

  @override
  String get paywallFeatureNoAdsTitle => 'Geen advertenties';

  @override
  String get paywallFeatureNoAdsSubtitle => 'Een vloeiendere ervaring voor premiumgebruikers.';

  @override
  String get paywallFeatureFutureTitle => 'Toekomstige functies inbegrepen';

  @override
  String get paywallFeatureFutureSubtitle => 'Toekomstige premiumverbeteringen worden ontgrendeld.';

  @override
  String get paywallPremiumAlreadyActive => 'Je premiumabonnement is al actief.';

  @override
  String get paywallNoOfferTitle => 'Geen aanbod beschikbaar';

  @override
  String get paywallNoOfferMessage => 'Controleer je configuratie van RevenueCat, App Store Connect of Google Play Console.';

  @override
  String get budgetSectionAddButton => 'Toevoegen';

  @override
  String get budgetSectionEmpty => 'Nog geen categorie. Voeg een regel toe.';

  @override
  String get budgetSectionAmountLabel => 'Bedrag';

  @override
  String budgetSectionTotalLabel(Object amount) {
    return 'Totaal: $amount';
  }

  @override
  String get expenseSectionAddCategoryButton => 'Categorie';

  @override
  String get expenseSectionEmpty => 'Geen uitgavencategorie. Voeg een categorie toe.';

  @override
  String get expenseSectionAddSubCategoryTooltip => 'Subcategorie toevoegen';

  @override
  String get expenseSectionRenameCategoryTooltip => 'Categorie hernoemen';

  @override
  String get expenseSectionDeleteCategoryTooltip => 'Categorie verwijderen';

  @override
  String get expenseSectionNoSubCategory => 'Geen subcategorie.';

  @override
  String get expenseSectionDeleteSubCategoryTooltip => 'Subcategorie verwijderen';

  @override
  String expenseSectionOperationsCount(Object count) {
    return 'Verrichtingen: $count';
  }

  @override
  String expenseSectionTotalLabel(Object amount) {
    return 'Totaal: $amount';
  }

  @override
  String get expenseSectionAddAmountButton => 'Bedrag';
}
