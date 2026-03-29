// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Budget familial';

  @override
  String get monthJanuary => 'Janvier';

  @override
  String get monthFebruary => 'Février';

  @override
  String get monthMarch => 'Mars';

  @override
  String get monthApril => 'Avril';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJune => 'Juin';

  @override
  String get monthJuly => 'Juillet';

  @override
  String get monthAugust => 'Août';

  @override
  String get monthSeptember => 'Septembre';

  @override
  String get monthOctober => 'Octobre';

  @override
  String get monthNovember => 'Novembre';

  @override
  String get monthDecember => 'Décembre';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonValidate => 'Valider';

  @override
  String get commonOptional => 'Optionnel';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonShare => 'Partager';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get signupTitle => 'Créer un compte';

  @override
  String get loginSubtitle =>
      'Connecte-toi pour accéder à ton budget familial.';

  @override
  String get signupSubtitle =>
      'Crée ton compte pour commencer à gérer ton budget familial.';

  @override
  String get loginPrimaryButton => 'Se connecter';

  @override
  String get signupPrimaryButton => 'Créer mon compte';

  @override
  String get loginSwitchToSignup => 'Créer un compte';

  @override
  String get loginSwitchToSignin => 'J’ai déjà un compte';

  @override
  String get loginFirebaseSecure => 'Connexion sécurisée avec Firebase';

  @override
  String get loginEmailLabel => 'Adresse e-mail';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginSending => 'Envoi...';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginProcessing => 'Traitement...';

  @override
  String get loginEnterEmail => 'Entre ton adresse e-mail';

  @override
  String get loginInvalidEmail => 'Adresse e-mail invalide';

  @override
  String get loginEnterPassword => 'Entre ton mot de passe';

  @override
  String get loginPasswordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String loginAccountCreatedVerificationSent(Object email) {
    return 'Compte créé. Un e-mail de vérification a été envoyé à $email.';
  }

  @override
  String loginPasswordResetSent(Object email) {
    return 'Un e-mail de réinitialisation a été envoyé à $email.';
  }

  @override
  String get emailVerificationTitle => 'Vérifie ton adresse e-mail';

  @override
  String get emailVerificationSubtitle =>
      'La vérification est requise avant d’accéder à ton budget.';

  @override
  String get emailVerificationAddressLabel => 'Adresse concernée';

  @override
  String get emailVerificationAddressUnavailable =>
      'Adresse e-mail indisponible';

  @override
  String get emailVerificationInstruction =>
      'Un e-mail de vérification a été envoyé. Clique sur le lien reçu, puis reviens dans l’application.';

  @override
  String get emailVerificationSpamHint =>
      'Pense aussi à vérifier le dossier spam / indésirables.';

  @override
  String get emailVerificationNotVerifiedYet =>
      'L’adresse e-mail n’est pas encore vérifiée.';

  @override
  String get emailVerificationYourEmail => 'ton adresse e-mail';

  @override
  String get emailVerificationChecking => 'Vérification...';

  @override
  String get emailVerificationConfirmed => 'J’ai vérifié';

  @override
  String get emailVerificationSending => 'Envoi...';

  @override
  String get emailVerificationResend => 'Renvoyer l’e-mail';

  @override
  String get emailVerificationSigningOut => 'Déconnexion...';

  @override
  String get emailVerificationSignOut => 'Se déconnecter';

  @override
  String emailVerificationResent(Object email) {
    return 'Un nouvel e-mail de vérification a été envoyé à $email.';
  }

  @override
  String get welcomeHeroDescription =>
      'Gérez votre budget personnel ou familial, suivez vos dépenses, vos économies et visualisez vos résultats mois après mois.';

  @override
  String get welcomeTitle => 'Commencez simplement';

  @override
  String get welcomeSubtitle =>
      'Créez votre compte pour synchroniser votre budget, activer les fonctions famille et retrouver vos données sur plusieurs appareils.';

  @override
  String get welcomeFeatureBudgetTitle => 'Suivi budgétaire';

  @override
  String get welcomeFeatureBudgetDescription =>
      'Pilotez vos rentrées, dépenses, économies et solde mensuel.';

  @override
  String get welcomeFeatureAnalysisTitle => 'Analyse du budget';

  @override
  String get welcomeFeatureAnalysisDescription =>
      'Comparez les périodes et visualisez les tendances importantes.';

  @override
  String get welcomeFeatureFamilyTitle => 'Mode famille';

  @override
  String get welcomeFeatureFamilyDescription =>
      'Partagez un budget commun avec synchronisation cloud.';

  @override
  String get welcomePremiumTitle => 'Version gratuite et Premium';

  @override
  String get welcomePremiumDescription =>
      'Commencez gratuitement puis débloquez les analyses avancées, les conseils, l’export Excel et les fonctions famille avec Premium.';

  @override
  String get welcomePremiumButton => 'Voir les offres Premium';

  @override
  String get welcomeCreateAccount => 'Créer un compte';

  @override
  String get welcomeSignIn => 'Se connecter';

  @override
  String get dashboardIncome => 'Rentrées';

  @override
  String get dashboardExpenses => 'Dépenses';

  @override
  String get dashboardSavings => 'Économies';

  @override
  String get dashboardBalance => 'Solde';

  @override
  String get dashboardFamilyIdCopied => 'Identifiant famille copié.';

  @override
  String get dashboardFamilyShareSubject => 'Inviter dans le budget familial';

  @override
  String dashboardFamilyShareMessage(Object familyId) {
    return 'Rejoins mon budget familial avec cet identifiant : $familyId';
  }

  @override
  String dashboardFamilyShareError(Object error) {
    return 'Impossible de partager l’identifiant famille : $error';
  }

  @override
  String get dashboardTransferOwnershipTitle => 'Transférer la propriété';

  @override
  String get dashboardTransferOwnershipMessage =>
      'Choisis le membre qui deviendra propriétaire du budget familial.';

  @override
  String get dashboardMemberLabel => 'Membre';

  @override
  String get dashboardTransferOwnershipHint =>
      'Après le transfert, ce membre pourra gérer la famille.';

  @override
  String get dashboardTransferOwnershipAction => 'Transférer';

  @override
  String get dashboardDeleteFamilyTitle => 'Supprimer la famille';

  @override
  String get dashboardDeleteFamilyIntro =>
      'Tu es sur le point de supprimer définitivement la famille.';

  @override
  String get dashboardDeleteFamilyConsequences => 'Conséquences :';

  @override
  String get dashboardDeleteFamilyConsequenceMembers =>
      '• Tous les membres perdront l’accès au budget partagé.';

  @override
  String get dashboardDeleteFamilyConsequenceBudget =>
      '• Le budget familial partagé sera supprimé.';

  @override
  String get dashboardDeleteFamilyConsequencePersonal =>
      '• Les budgets personnels restent séparés.';

  @override
  String get dashboardDeleteFamilyIrreversible =>
      'Cette action est irréversible.';

  @override
  String get dashboardDeleteFamilyAction => 'Supprimer la famille';

  @override
  String get dashboardCreateFamilyTitle => 'Créer une famille';

  @override
  String get dashboardFamilyNameLabel => 'Nom de la famille';

  @override
  String get dashboardFamilyCreatedSharedActivated =>
      'Famille créée et budget partagé activé.';

  @override
  String get dashboardFamilyCreated => 'Famille créée avec succès.';

  @override
  String dashboardCreateFamilyError(Object error) {
    return 'Impossible de créer la famille : $error';
  }

  @override
  String get dashboardJoinFamilyTitle => 'Rejoindre une famille';

  @override
  String get dashboardFamilyIdLabel => 'Identifiant famille';

  @override
  String get dashboardFamilyIdExample => 'Exemple : ABC123XYZ';

  @override
  String get dashboardFamilyJoinedSuccess => 'Famille rejointe avec succès.';

  @override
  String dashboardJoinFamilyError(Object error) {
    return 'Impossible de rejoindre la famille : $error';
  }

  @override
  String get dashboardNoMemberAvailableTitle => 'Aucun membre disponible';

  @override
  String get dashboardNoMemberAvailableMessage =>
      'Aucun autre membre n’est disponible pour recevoir la propriété.';

  @override
  String get dashboardTransferOwnershipSuccess =>
      'Propriété transférée avec succès.';

  @override
  String dashboardTransferOwnershipError(Object error) {
    return 'Impossible de transférer la propriété : $error';
  }

  @override
  String get dashboardDeleteFamilySuccess => 'Famille supprimée.';

  @override
  String dashboardDeleteFamilyError(Object error) {
    return 'Impossible de supprimer la famille : $error';
  }

  @override
  String get dashboardLeaveFamilyTitle => 'Quitter la famille';

  @override
  String get dashboardLeaveFamilyChoiceIntro =>
      'Que veux-tu faire en quittant la famille ?';

  @override
  String get dashboardLeaveFamilyChoiceRestorePersonal =>
      'Restaurer mon budget personnel précédent.';

  @override
  String get dashboardLeaveFamilyChoiceCopyFamily =>
      'Copier le budget familial dans mon budget personnel.';

  @override
  String get dashboardLeaveFamilyRestoreAction => 'Restaurer mon budget';

  @override
  String get dashboardLeaveFamilyCopyAction => 'Copier le budget familial';

  @override
  String get dashboardLeaveFamilyCopiedSuccess =>
      'Tu as quitté la famille et copié le budget familial.';

  @override
  String get dashboardLeaveFamilyRestoredSuccess =>
      'Tu as quitté la famille et restauré ton budget personnel.';

  @override
  String dashboardLeaveFamilyError(Object error) {
    return 'Impossible de quitter la famille : $error';
  }

  @override
  String dashboardAddCategoryForSection(Object section) {
    return 'Ajouter une catégorie dans $section';
  }

  @override
  String get dashboardCategoryNameLabel => 'Nom de la catégorie';

  @override
  String get dashboardExistingCategoryTitle => 'Catégorie existante';

  @override
  String dashboardExistingCategoryInSection(Object section) {
    return 'Une catégorie avec ce nom existe déjà dans $section.';
  }

  @override
  String get dashboardRenameCategoryTitle => 'Renommer la catégorie';

  @override
  String get dashboardNewNameLabel => 'Nouveau nom';

  @override
  String get dashboardAnotherCategorySameName =>
      'Une autre catégorie porte déjà ce nom.';

  @override
  String get dashboardAddExpenseCategoryTitle =>
      'Ajouter une catégorie de dépense';

  @override
  String get dashboardExistingExpenseCategory =>
      'Cette catégorie de dépense existe déjà.';

  @override
  String dashboardAddExpenseSubCategoryFor(Object category) {
    return 'Ajouter une sous-catégorie dans $category';
  }

  @override
  String get dashboardSubCategoryNameLabel => 'Nom de la sous-catégorie';

  @override
  String get dashboardExistingSubCategoryTitle => 'Sous-catégorie existante';

  @override
  String dashboardExistingSubCategoryIn(Object category) {
    return 'Cette sous-catégorie existe déjà dans $category.';
  }

  @override
  String get dashboardRenameSubCategoryTitle => 'Renommer la sous-catégorie';

  @override
  String dashboardAnotherSubCategorySameNameIn(Object category) {
    return 'Une autre sous-catégorie porte déjà ce nom dans $category.';
  }

  @override
  String dashboardAddAmountFor(Object subCategory) {
    return 'Ajouter un montant pour $subCategory';
  }

  @override
  String get dashboardAmountLabel => 'Montant';

  @override
  String get dashboardInvalidAmountTitle => 'Montant invalide';

  @override
  String get dashboardInvalidAmountMessage =>
      'Entre un montant valide supérieur à 0.';

  @override
  String get dashboardRestoreSuccessPremium =>
      'Achats restaurés, Premium activé.';

  @override
  String get dashboardRestoreFinishedNoPremium =>
      'Restauration terminée, aucun achat Premium actif trouvé.';

  @override
  String dashboardRestoreError(Object error) {
    return 'Erreur lors de la restauration : $error';
  }

  @override
  String get dashboardPrivacyOpened => 'Options de confidentialité ouvertes.';

  @override
  String get dashboardPrivacyNotRequired =>
      'Aucune option de confidentialité requise pour le moment.';

  @override
  String dashboardPrivacyError(Object error) {
    return 'Impossible d’ouvrir les options de confidentialité : $error';
  }

  @override
  String get dashboardSignOutSuccess => 'Déconnexion réussie.';

  @override
  String dashboardSignOutError(Object error) {
    return 'Erreur lors de la déconnexion : $error';
  }

  @override
  String get dashboardSubscriptionTooltip => 'Voir les offres Premium';

  @override
  String get dashboardOptionsTooltip => 'Options';

  @override
  String get dashboardMenuPremium => 'Premium';

  @override
  String get dashboardRestoring => 'Restauration...';

  @override
  String get dashboardRestorePurchases => 'Restaurer les achats';

  @override
  String get dashboardOpening => 'Ouverture...';

  @override
  String get dashboardPrivacyRgpd => 'Confidentialité / RGPD';

  @override
  String get dashboardSigningOut => 'Déconnexion...';

  @override
  String get dashboardSignOut => 'Se déconnecter';

  @override
  String dashboardConnectedAs(Object email) {
    return 'Connecté en tant que $email';
  }

  @override
  String get dashboardFamilyModeActive => 'Mode famille actif';

  @override
  String get dashboardPersonalBudgetActive => 'Budget personnel actif';

  @override
  String get dashboardFamilySharedDescription =>
      'Le budget est actuellement partagé avec les membres de la famille.';

  @override
  String get dashboardPersonalBudgetDescription =>
      'Tu travailles actuellement sur ton budget personnel.';

  @override
  String dashboardFamilyName(Object name) {
    return 'Famille : $name';
  }

  @override
  String get dashboardFamilyIdTitle => 'Identifiant famille';

  @override
  String get dashboardProcessing => 'Traitement...';

  @override
  String get dashboardTransferOwnershipPremium =>
      'Premium requis pour transférer';

  @override
  String get dashboardDeleteFamilyPremium => 'Premium requis pour supprimer';

  @override
  String get dashboardCreateFamilyAction => 'Créer une famille';

  @override
  String get dashboardCreateFamilyPremium => 'Créer une famille (Premium)';

  @override
  String get dashboardJoinFamilyAction => 'Rejoindre';

  @override
  String get dashboardFamilyPremiumHint =>
      'La création et la gestion avancée de famille nécessitent Premium.';

  @override
  String get dashboardLeaveFamilyAction => 'Quitter la famille';

  @override
  String dashboardPremiumActiveLabel(Object plan) {
    return '$plan actif';
  }

  @override
  String get dashboardFreeVersionActive => 'Version gratuite active';

  @override
  String get dashboardSeeOffers => 'Voir les offres';

  @override
  String get dashboardTitle => 'Tableau de bord';

  @override
  String dashboardActivePeriod(Object month, Object year) {
    return 'Période active : $month $year';
  }

  @override
  String get dashboardYearLabel => 'Année';

  @override
  String get dashboardMonthLabel => 'Mois';

  @override
  String get dashboardAnalysisAction => 'Analyse';

  @override
  String get dashboardDetailAction => 'Voir le détail';

  @override
  String get dashboardManagePremium => 'Gérer Premium';

  @override
  String get dashboardSubscription => 'Abonnement';

  @override
  String get dashboardRestore => 'Restaurer';

  @override
  String get dashboardUnlockPremiumFeatures => 'Débloque les fonctions Premium';

  @override
  String get dashboardPremiumBenefitsActive =>
      'Export Excel, analyses intelligentes, famille premium et expérience sans publicité sont actifs.';

  @override
  String get dashboardPremiumBenefitsLocked =>
      'Débloque l’export Excel, les conseils intelligents, la famille premium et la suppression des publicités.';

  @override
  String get dashboardPremiumPillSmartAnalysis => 'Analyse smart';

  @override
  String get dashboardPremiumPillAdvice => 'Conseils';

  @override
  String get dashboardPremiumPillExcel => 'Export Excel';

  @override
  String get dashboardPremiumPillFamily => 'Famille';

  @override
  String get dashboardManageSubscription => 'Gérer l’abonnement';

  @override
  String get dashboardSeePremiumOffers => 'Voir les offres Premium';

  @override
  String get recapDetailOperationsTitle => 'Détail des opérations';

  @override
  String get recapTitle => 'Récapitulatif';

  @override
  String get recapOperations => 'Opérations';

  @override
  String get recapTotalExpenses => 'Total dépenses';

  @override
  String get recapEmptyTitle => 'Aucune dépense';

  @override
  String get recapEmptyMessage =>
      'Aucune opération n’a été enregistrée pour cette période.';

  @override
  String recapOperationsCount(Object count) {
    return '$count opération(s)';
  }

  @override
  String get recapDelete => 'Supprimer';

  @override
  String get paywallAnnualTitle => 'Premium annuel';

  @override
  String get paywallMonthlyTitle => 'Premium mensuel';

  @override
  String get paywallFamilyTitle => 'Premium famille';

  @override
  String get paywallAnnualSubtitle =>
      'Le meilleur tarif pour débloquer toutes les fonctions premium.';

  @override
  String get paywallMonthlySubtitle => 'Flexible, sans engagement long terme.';

  @override
  String get paywallFamilySubtitle =>
      'Pour créer et gérer un budget familial partagé en premium.';

  @override
  String get paywallDefaultPackageSubtitle =>
      'Débloque toutes les fonctionnalités premium.';

  @override
  String get paywallBadgeBestOffer => 'Meilleure offre';

  @override
  String get paywallBadgeFamily => 'Famille';

  @override
  String get paywallBadgeFlexible => 'Flexible';

  @override
  String get paywallPurchaseSuccess => 'Premium activé avec succès.';

  @override
  String get paywallPurchaseCanceled => 'Achat annulé.';

  @override
  String paywallPurchaseError(Object error) {
    return 'Impossible de finaliser l’achat : $error';
  }

  @override
  String get paywallRestoreSuccess => 'Achats restaurés avec succès.';

  @override
  String get paywallRestoreNoPurchaseFound =>
      'Aucun achat premium actif trouvé.';

  @override
  String paywallRestoreError(Object error) {
    return 'Erreur lors de la restauration : $error';
  }

  @override
  String get paywallRestoring => 'Restauration...';

  @override
  String get paywallRestore => 'Restaurer';

  @override
  String get paywallUnlockTitle => 'Débloque toutes les fonctions premium';

  @override
  String get paywallUnlockSubtitle =>
      'Export Excel, conseils intelligents, gestion famille premium, analyses avancées et expérience sans publicité.';

  @override
  String get paywallChooseOfferTitle => 'Choisis ton offre';

  @override
  String get paywallProcessing => 'Traitement...';

  @override
  String get paywallChooseOfferButton => 'Choisir une offre';

  @override
  String paywallContinueWithPrice(Object price) {
    return 'Continuer avec $price';
  }

  @override
  String get paywallStoreNotice =>
      'Paiement et gestion de l’abonnement via Apple / Google.';

  @override
  String get paywallImportantInfoTitle => 'Informations importantes';

  @override
  String get paywallImportantInfoBody =>
      '• L’abonnement est renouvelé automatiquement selon les règles du store.\n• Tu peux gérer ou annuler ton abonnement depuis ton compte Apple / Google.\n• La restauration permet de réactiver un achat existant sur le même compte store.\n• La création et la gestion de famille premium dépendent de ton abonnement actif.\n• Le partage famille natif dépend aussi des règles de l’App Store ou de Google Play.';

  @override
  String paywallPartialUnavailable(Object error) {
    return 'Monétisation partiellement indisponible : $error';
  }

  @override
  String get paywallHeroPremiumActiveTitle => 'Premium actif';

  @override
  String get paywallHeroUpgradeTitle => 'Passe en Premium';

  @override
  String get paywallHeroPremiumActiveSubtitle =>
      'Toutes les fonctionnalités premium sont déjà déverrouillées.';

  @override
  String get paywallHeroUpgradeSubtitle =>
      'Débloque l’export Excel, les conseils intelligents, la gestion famille premium et une expérience sans publicité.';

  @override
  String get paywallFeatureExcelTitle => 'Export Excel complet';

  @override
  String get paywallFeatureExcelSubtitle =>
      'Exports détaillés pour piloter et archiver ton budget.';

  @override
  String get paywallFeatureAdviceTitle => 'Conseils intelligents';

  @override
  String get paywallFeatureAdviceSubtitle =>
      'Recommandations, alertes et analyses avancées.';

  @override
  String get paywallFeatureFamilyTitle => 'Gestion famille premium';

  @override
  String get paywallFeatureFamilySubtitle =>
      'Créer une famille, transférer la propriété et gérer la structure partagée.';

  @override
  String get paywallFeatureNoAdsTitle => 'Sans publicité';

  @override
  String get paywallFeatureNoAdsSubtitle =>
      'Une expérience plus fluide pour les utilisateurs premium.';

  @override
  String get paywallFeatureFutureTitle => 'Fonctions futures incluses';

  @override
  String get paywallFeatureFutureSubtitle =>
      'Les prochaines améliorations premium seront débloquées.';

  @override
  String get paywallPremiumAlreadyActive =>
      'Ton abonnement premium est déjà actif.';

  @override
  String get paywallNoOfferTitle => 'Aucune offre disponible';

  @override
  String get paywallNoOfferMessage =>
      'Vérifie ta configuration RevenueCat, App Store Connect ou Google Play Console.';

  @override
  String get budgetSectionAddButton => 'Ajouter';

  @override
  String get budgetSectionEmpty =>
      'Aucune catégorie pour le moment. Ajoute une ligne.';

  @override
  String get budgetSectionAmountLabel => 'Montant';

  @override
  String budgetSectionTotalLabel(Object amount) {
    return 'Total : $amount';
  }

  @override
  String get expenseSectionAddCategoryButton => 'Catégorie';

  @override
  String get expenseSectionEmpty =>
      'Aucune catégorie de dépense. Ajoute une catégorie.';

  @override
  String get expenseSectionAddSubCategoryTooltip =>
      'Ajouter une sous-catégorie';

  @override
  String get expenseSectionRenameCategoryTooltip => 'Renommer la catégorie';

  @override
  String get expenseSectionDeleteCategoryTooltip => 'Supprimer la catégorie';

  @override
  String get expenseSectionNoSubCategory => 'Aucune sous-catégorie.';

  @override
  String get expenseSectionDeleteSubCategoryTooltip =>
      'Supprimer la sous-catégorie';

  @override
  String expenseSectionOperationsCount(Object count) {
    return 'Opérations : $count';
  }

  @override
  String expenseSectionTotalLabel(Object amount) {
    return 'Total : $amount';
  }

  @override
  String get expenseSectionAddAmountButton => 'Montant';
}
