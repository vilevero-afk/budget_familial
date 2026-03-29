import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../models/budget_models.dart';
import '../monetization/ads_service.dart';
import '../monetization/budget_familial_monetization_scope.dart';
import '../monetization/paywall_screen.dart';
import '../monetization/premium_banner_ad.dart';
import '../services/auth_service.dart';
import '../services/budget_cloud_service.dart';
import '../widgets/budget_expense_section_card.dart';
import '../widgets/budget_section_card.dart';
import 'analysis_screen.dart';
import 'recap_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.onLocaleChanged,
    required this.currentLocale,
  });

  final Future<void> Function(Locale? locale) onLocaleChanged;
  final Locale? currentLocale;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const String _storageKey = 'budget_familial_app_data_v1';

  final List<String> _months = const [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];

  final List<int> _years = List.generate(11, (index) => 2023 + index);

  final AdsService _adsService = AdsService();
  final AuthService _authService = AuthService();
  final BudgetCloudService _budgetCloudService = BudgetCloudService();

  late String _selectedMonth;
  late int _selectedYear;
  late AppBudgetData _appBudget;

  final Set<String> _expandedExpenseCategoryIds = {};

  StreamSubscription<BudgetDocumentSnapshotData>? _cloudBudgetSubscription;

  bool _incomeSectionExpanded = true;
  bool _expenseSectionExpanded = true;
  bool _savingSectionExpanded = true;
  bool _isLoading = true;
  bool _isRestoringPurchases = false;
  bool _isOpeningPrivacyOptions = false;
  bool _isSigningOut = false;
  bool _isFamilyActionLoading = false;
  bool _isResolvingBudgetConflict = false;

  String? _familyId;
  String? _familyOwnerUid;
  String? _familyName;
  List<String> _familyMemberUids = const [];

  int _currentBudgetRevision = 0;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  String get _selectedLanguageCode {
    return widget.currentLocale?.languageCode ??
        Localizations.localeOf(context).languageCode;
  }

  @override
  void initState() {
    super.initState();
    _selectedMonth = _months[0];
    _selectedYear = DateTime.now().year;
    _appBudget = _createInitialData();
    _loadData();
  }

  @override
  void dispose() {
    _cloudBudgetSubscription?.cancel();
    super.dispose();
  }

  String get _currentPeriodKey => '$_selectedYear-$_selectedMonth';

  PeriodBudgetData get _currentPeriod {
    return _appBudget.getOrCreatePeriod(_currentPeriodKey);
  }

  bool get _isCurrentUserFamilyOwner {
    final currentUid = _authService.currentUser?.uid;
    if (currentUid == null) return false;
    return _familyId != null && _familyOwnerUid == currentUid;
  }

  List<String> get _transferCandidates {
    final currentUid = _authService.currentUser?.uid;
    return _familyMemberUids.where((uid) => uid != currentUid).toList();
  }

  bool get _isPremium {
    return BudgetFamilialMonetizationScope.of(context).isPremium;
  }

  bool get _canCreateFamily => _isPremium;

  bool get _canManageFamily {
    return _familyId != null && _isCurrentUserFamilyOwner && _isPremium;
  }

  AppBudgetData _createInitialData() {
    return AppBudgetData(
      incomeTemplate: BudgetSectionTemplate(
        title: 'Rentrées',
        color: const Color(0xFF16A34A),
      ),
      expenseTemplate: ExpenseSectionTemplate(
        title: 'Dépenses',
        color: const Color(0xFFEF4444),
      ),
      savingTemplate: BudgetSectionTemplate(
        title: 'Économies',
        color: const Color(0xFF2563EB),
      ),
    );
  }

  Future<void> _changeLanguage(String? value) async {
    if (value == null) return;

    switch (value) {
      case 'fr':
        await widget.onLocaleChanged(const Locale('fr'));
        break;
      case 'en':
        await widget.onLocaleChanged(const Locale('en'));
        break;
      case 'nl':
        await widget.onLocaleChanged(const Locale('nl'));
        break;
    }

    if (!mounted) return;
    setState(() {});
  }

  String _localizedMonthLabel(String month) {
    switch (month) {
      case 'Janvier':
        return l10n.monthJanuary;
      case 'Février':
        return l10n.monthFebruary;
      case 'Mars':
        return l10n.monthMarch;
      case 'Avril':
        return l10n.monthApril;
      case 'Mai':
        return l10n.monthMay;
      case 'Juin':
        return l10n.monthJune;
      case 'Juillet':
        return l10n.monthJuly;
      case 'Août':
        return l10n.monthAugust;
      case 'Septembre':
        return l10n.monthSeptember;
      case 'Octobre':
        return l10n.monthOctober;
      case 'Novembre':
        return l10n.monthNovember;
      case 'Décembre':
        return l10n.monthDecember;
      default:
        return month;
    }
  }

  String _localizedSectionTitle(BudgetSectionTemplate section) {
    if (identical(section, _appBudget.incomeTemplate)) {
      return l10n.dashboardIncome;
    }
    if (identical(section, _appBudget.savingTemplate)) {
      return l10n.dashboardSavings;
    }

    switch (section.title.trim().toLowerCase()) {
      case 'rentrées':
        return l10n.dashboardIncome;
      case 'économies':
        return l10n.dashboardSavings;
      default:
        return section.title;
    }
  }

  Future<AppBudgetData?> _loadLocalBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return AppBudgetData.fromJson(decoded);
    } catch (e) {
      debugPrint('Local budget decode error: $e');
      return null;
    }
  }

  Future<void> _saveLocalBudget(AppBudgetData budget) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(budget.toJson());
    await prefs.setString(_storageKey, raw);
  }

  void _applyBudgetSnapshotToState(
    BudgetDocumentSnapshotData snapshot, {
    bool updateBudget = true,
  }) {
    if (updateBudget && snapshot.budget != null) {
      _appBudget = snapshot.budget!;
      _appBudget.getOrCreatePeriod(_currentPeriodKey);
    }

    _currentBudgetRevision = snapshot.revision;
  }

  void _startCloudBudgetSync() {
    _cloudBudgetSubscription?.cancel();

    if (!_budgetCloudService.isSignedIn) {
      return;
    }

    _cloudBudgetSubscription = _budgetCloudService.watchBudgetSnapshot().listen(
      (snapshot) {
        if (!mounted || snapshot.budget == null) return;

        setState(() {
          _applyBudgetSnapshotToState(snapshot);
        });

        unawaited(_saveLocalBudget(snapshot.budget!));
      },
      onError: (error) {
        debugPrint('Cloud budget watch error: $error');
      },
    );
  }

  Future<void> _loadData() async {
    AppBudgetData? localBudget;
    BudgetDocumentSnapshotData? cloudBudgetSnapshot;
    String? familyId;
    FamilyInfo? familyInfo;

    try {
      localBudget = await _loadLocalBudget();
    } catch (e) {
      debugPrint('Local budget load error: $e');
    }

    try {
      if (_budgetCloudService.isSignedIn) {
        familyId = await _budgetCloudService.getCurrentFamilyId();
        cloudBudgetSnapshot = await _budgetCloudService.loadBudgetSnapshot();
        familyInfo = await _budgetCloudService.getCurrentFamilyInfo();
      }
    } catch (e) {
      debugPrint('Cloud budget load error: $e');
    }

    if (!mounted) return;

    final resolvedBudget =
        cloudBudgetSnapshot?.budget ?? localBudget ?? _createInitialData();

    setState(() {
      _familyId = familyId;
      _familyOwnerUid = familyInfo?.ownerUid;
      _familyName = familyInfo?.name;
      _familyMemberUids = familyInfo?.members ?? const [];
      _appBudget = resolvedBudget;
      _appBudget.getOrCreatePeriod(_currentPeriodKey);

      if (cloudBudgetSnapshot != null) {
        _applyBudgetSnapshotToState(
          cloudBudgetSnapshot,
          updateBudget: false,
        );
      } else {
        _currentBudgetRevision = 0;
      }

      _isLoading = false;
    });

    if (cloudBudgetSnapshot?.budget == null && localBudget != null) {
      try {
        await _budgetCloudService.saveBudgetWithRevisionCheck(
          localBudget,
          expectedRevision: cloudBudgetSnapshot?.revision ?? 0,
        );

        if (mounted) {
          setState(() {
            _currentBudgetRevision = (cloudBudgetSnapshot?.revision ?? 0) + 1;
          });
        }
      } catch (e) {
        debugPrint('Initial cloud sync error: $e');
      }
    }

    _startCloudBudgetSync();
  }

  Future<void> _handleBudgetSaveConflict(
    BudgetSaveConflictException conflict,
  ) async {
    if (_isResolvingBudgetConflict) return;

    _isResolvingBudgetConflict = true;

    try {
      final latestSnapshot = await _budgetCloudService.loadBudgetSnapshot();

      if (!mounted) return;

      setState(() {
        _applyBudgetSnapshotToState(latestSnapshot);
      });

      if (latestSnapshot.budget != null) {
        await _saveLocalBudget(latestSnapshot.budget!);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le budget a été modifié sur un autre appareil ou par un autre membre. Votre dernière modification n’a pas été enregistrée et la version la plus récente a été rechargée.',
          ),
          backgroundColor: Color(0xFFDC2626),
        ),
      );

      debugPrint(
        'Budget save conflict: expected=${conflict.expectedRevision}, actual=${conflict.actualRevision}',
      );
    } catch (e) {
      debugPrint('Budget conflict reload error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Un conflit de sauvegarde a été détecté, mais le rechargement du budget a échoué.',
          ),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    } finally {
      _isResolvingBudgetConflict = false;
    }
  }

  Future<void> _saveData() async {
    await _saveLocalBudget(_appBudget);

    try {
      await _budgetCloudService.saveBudgetWithRevisionCheck(
        _appBudget,
        expectedRevision: _currentBudgetRevision,
      );

      if (!mounted) return;

      setState(() {
        _currentBudgetRevision += 1;
      });
    } on BudgetSaveConflictException catch (e) {
      await _handleBudgetSaveConflict(e);
    } catch (e) {
      debugPrint('Cloud budget save error: $e');
    }
  }

  void _applyAndSave(VoidCallback callback) {
    setState(callback);
    unawaited(_saveData());
  }

  Future<void> _copyFamilyId() async {
    final familyId = _familyId;
    if (familyId == null || familyId.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: familyId));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.dashboardFamilyIdCopied),
        backgroundColor: const Color(0xFF475467),
      ),
    );
  }

  Future<void> _shareFamilyId() async {
    final familyId = _familyId;
    if (familyId == null || familyId.isEmpty) return;

    try {
      await Share.share(
        l10n.dashboardFamilyShareMessage(familyId),
        subject: l10n.dashboardFamilyShareSubject,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardFamilyShareError(e.toString())),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  bool _isExpenseCategoryExpanded(ExpenseCategoryTemplate category) {
    return _expandedExpenseCategoryIds.contains(category.id);
  }

  void _toggleExpenseCategory(ExpenseCategoryTemplate category) {
    setState(() {
      if (_expandedExpenseCategoryIds.contains(category.id)) {
        _expandedExpenseCategoryIds.remove(category.id);
      } else {
        _expandedExpenseCategoryIds.add(category.id);
      }
    });
  }

  void _changeMonth(String? month) {
    if (month == null) return;
    setState(() {
      _selectedMonth = month;
      _appBudget.getOrCreatePeriod(_currentPeriodKey);
    });
  }

  void _changeYear(int? year) {
    if (year == null) return;
    setState(() {
      _selectedYear = year;
      _appBudget.getOrCreatePeriod(_currentPeriodKey);
    });
  }

  Future<void> _showInfoDialog(String title, String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonOk),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showTextInputDialog({
    required String title,
    required String label,
    String initialValue = '',
    String? helperText,
  }) async {
    final controller = TextEditingController(text: initialValue);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: label,
              helperText: helperText,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(l10n.commonValidate),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showTransferOwnershipDialog(List<String> memberUids) {
    String? selectedUid = memberUids.isNotEmpty ? memberUids.first : null;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(l10n.dashboardTransferOwnershipTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.dashboardTransferOwnershipMessage),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedUid,
                    items: memberUids
                        .map(
                          (uid) => DropdownMenuItem<String>(
                            value: uid,
                            child: Text(uid),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setLocalState(() {
                        selectedUid = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: l10n.dashboardMemberLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.dashboardTransferOwnershipHint,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      height: 1.35,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: selectedUid == null
                      ? null
                      : () => Navigator.pop(context, selectedUid),
                  child: Text(l10n.dashboardTransferOwnershipAction),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _showDissolveFamilyDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.dashboardDeleteFamilyTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.dashboardDeleteFamilyIntro),
              const SizedBox(height: 14),
              Text(
                l10n.dashboardDeleteFamilyConsequences,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(l10n.dashboardDeleteFamilyConsequenceMembers),
              const SizedBox(height: 6),
              Text(l10n.dashboardDeleteFamilyConsequenceBudget),
              const SizedBox(height: 6),
              Text(l10n.dashboardDeleteFamilyConsequencePersonal),
              const SizedBox(height: 14),
              Text(
                l10n.dashboardDeleteFamilyIrreversible,
                style: const TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.dashboardDeleteFamilyAction),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createFamily() async {
    if (!_canCreateFamily) {
      await _openPremiumScreen();
      return;
    }

    if (_isFamilyActionLoading) return;

    final familyName = await _showTextInputDialog(
      title: l10n.dashboardCreateFamilyTitle,
      label: l10n.dashboardFamilyNameLabel,
      helperText: l10n.commonOptional,
    );

    if (familyName == null) return;

    setState(() {
      _isFamilyActionLoading = true;
    });

    try {
      await _budgetCloudService.createFamily(
        familyName: familyName.trim().isEmpty ? null : familyName.trim(),
      );

      await _budgetCloudService.saveBudget(_appBudget);
      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _familyId != null
                ? l10n.dashboardFamilyCreatedSharedActivated
                : l10n.dashboardFamilyCreated,
          ),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardCreateFamilyError(e.toString())),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFamilyActionLoading = false;
        });
      }
    }
  }

  Future<void> _joinFamily() async {
    if (_isFamilyActionLoading) return;

    final familyId = await _showTextInputDialog(
      title: l10n.dashboardJoinFamilyTitle,
      label: l10n.dashboardFamilyIdLabel,
      helperText: l10n.dashboardFamilyIdExample,
    );

    if (familyId == null || familyId.isEmpty) return;

    final normalizedFamilyId = familyId.trim();

    setState(() {
      _isFamilyActionLoading = true;
    });

    try {
      await _budgetCloudService.joinFamily(normalizedFamilyId);

      if (!mounted) return;

      setState(() {
        _familyId = normalizedFamilyId;
      });

      _startCloudBudgetSync();
      unawaited(_loadData());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardFamilyJoinedSuccess),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardJoinFamilyError(e.toString())),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFamilyActionLoading = false;
        });
      }
    }
  }

  Future<void> _transferFamilyOwnership() async {
    if (!_canManageFamily) {
      await _openPremiumScreen();
      return;
    }

    if (_isFamilyActionLoading) return;

    final candidates = _transferCandidates;

    if (candidates.isEmpty) {
      await _showInfoDialog(
        l10n.dashboardNoMemberAvailableTitle,
        l10n.dashboardNoMemberAvailableMessage,
      );
      return;
    }

    final selectedUid = await _showTransferOwnershipDialog(candidates);
    if (selectedUid == null || selectedUid.isEmpty) return;

    setState(() {
      _isFamilyActionLoading = true;
    });

    try {
      await _budgetCloudService.transferFamilyOwnership(selectedUid);
      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardTransferOwnershipSuccess),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardTransferOwnershipError(e.toString())),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFamilyActionLoading = false;
        });
      }
    }
  }

  Future<void> _dissolveFamily() async {
    if (!_canManageFamily) {
      await _openPremiumScreen();
      return;
    }

    if (_isFamilyActionLoading) return;

    final confirmed = await _showDissolveFamilyDialog();
    if (confirmed != true) return;

    setState(() {
      _isFamilyActionLoading = true;
    });

    try {
      await _budgetCloudService.dissolveFamily();
      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardDeleteFamilySuccess),
          backgroundColor: const Color(0xFF475467),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardDeleteFamilyError(e.toString())),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFamilyActionLoading = false;
        });
      }
    }
  }

  Future<_LeaveFamilyChoice?> _showLeaveFamilyChoiceDialog() {
    return showDialog<_LeaveFamilyChoice>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.dashboardLeaveFamilyTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.dashboardLeaveFamilyChoiceIntro),
              const SizedBox(height: 16),
              Text(l10n.dashboardLeaveFamilyChoiceRestorePersonal),
              const SizedBox(height: 10),
              Text(l10n.dashboardLeaveFamilyChoiceCopyFamily),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonCancel),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(
                context,
                _LeaveFamilyChoice.restorePersonalBudget,
              ),
              child: Text(l10n.dashboardLeaveFamilyRestoreAction),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                _LeaveFamilyChoice.copyFamilyBudget,
              ),
              child: Text(l10n.dashboardLeaveFamilyCopyAction),
            ),
          ],
        );
      },
    );
  }

  Future<void> _leaveFamily() async {
    if (_isFamilyActionLoading) return;

    final choice = await _showLeaveFamilyChoiceDialog();
    if (choice == null) return;

    setState(() {
      _isFamilyActionLoading = true;
    });

    try {
      await _budgetCloudService.leaveFamily(
        copyFamilyBudgetToPersonal:
            choice == _LeaveFamilyChoice.copyFamilyBudget,
      );
      await _loadData();

      if (!mounted) return;

      final message = choice == _LeaveFamilyChoice.copyFamilyBudget
          ? l10n.dashboardLeaveFamilyCopiedSuccess
          : l10n.dashboardLeaveFamilyRestoredSuccess;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF475467),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardLeaveFamilyError(e.toString())),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFamilyActionLoading = false;
        });
      }
    }
  }

  void _openRecapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecapScreen(
          monthLabel: _selectedMonth,
          year: _selectedYear,
          rows: _appBudget.getExpenseRowsForPeriod(_currentPeriodKey),
          totalExpenses: _appBudget.expenseTotalForPeriod(_currentPeriodKey),
          onDeleteEntry: _deleteExpenseEntry,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _openAnalysisScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisScreen(
          appBudget: _appBudget,
          initialMonth: _selectedMonth,
          initialYear: _selectedYear,
          months: _months,
          years: _years,
        ),
      ),
    );
  }

  Future<void> _openPremiumScreen() async {
    final monetization = BudgetFamilialMonetizationScope.of(context);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaywallScreen(controller: monetization),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _restorePurchases() async {
    if (_isRestoringPurchases) return;

    final monetization = BudgetFamilialMonetizationScope.of(context);

    setState(() {
      _isRestoringPurchases = true;
    });

    try {
      await monetization.restorePurchases();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            monetization.isPremium
                ? l10n.dashboardRestoreSuccessPremium
                : l10n.dashboardRestoreFinishedNoPremium,
          ),
          backgroundColor: monetization.isPremium
              ? const Color(0xFF16A34A)
              : const Color(0xFF475467),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardRestoreError(e.toString())),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRestoringPurchases = false;
        });
      }
    }
  }

  Future<void> _openPrivacyOptions() async {
    if (_isOpeningPrivacyOptions) return;

    final monetization = BudgetFamilialMonetizationScope.of(context);

    setState(() {
      _isOpeningPrivacyOptions = true;
    });

    try {
      await monetization.openPrivacyOptions();

      if (!mounted) return;

      final message = monetization.privacyOptionsRequired
          ? l10n.dashboardPrivacyOpened
          : l10n.dashboardPrivacyNotRequired;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF475467),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardPrivacyError(e.toString())),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningPrivacyOptions = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    setState(() {
      _isSigningOut = true;
    });

    try {
      await _authService.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardSignOutSuccess),
          backgroundColor: const Color(0xFF475467),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardSignOutError(e.toString())),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    }
  }

  Future<void> _handleTopMenuAction(_DashboardMenuAction action) async {
    switch (action) {
      case _DashboardMenuAction.family:
        await _openFamilySheet();
        break;
      case _DashboardMenuAction.account:
        await _openAccountSheet();
        break;
      case _DashboardMenuAction.premium:
        await _openPremiumSheet();
        break;
      case _DashboardMenuAction.restorePurchases:
        await _restorePurchases();
        break;
      case _DashboardMenuAction.privacyOptions:
        await _openPrivacyOptions();
        break;
      case _DashboardMenuAction.signOut:
        await _signOut();
        break;
    }
  }

  Future<void> _openAccountSheet() async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final currentUserEmail = _authService.currentUser?.email;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dashboardOptionsTooltip,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (currentUserEmail != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_circle_outlined,
                            color: Color(0xFF475467),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.dashboardConnectedAs(currentUserEmail),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475467),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Langue',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildLanguageDropdown(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _isRestoringPurchases ? null : _restorePurchases,
                      icon: const Icon(Icons.restore_rounded),
                      label: Text(
                        _isRestoringPurchases
                            ? l10n.dashboardRestoring
                            : l10n.dashboardRestorePurchases,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _isOpeningPrivacyOptions ? null : _openPrivacyOptions,
                      icon: const Icon(Icons.privacy_tip_outlined),
                      label: Text(
                        _isOpeningPrivacyOptions
                            ? l10n.dashboardOpening
                            : l10n.dashboardPrivacyRgpd,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSigningOut ? null : _signOut,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(
                        _isSigningOut
                            ? l10n.dashboardSigningOut
                            : l10n.dashboardSignOut,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openPremiumSheet() async {
    if (!mounted) return;

    final monetization = BudgetFamilialMonetizationScope.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final isPremium = monetization.isPremium;
        final premiumLabel = monetization.premiumPlanLabel;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dashboardSubscription,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? const Color(0xFFFFFBEB)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isPremium
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isPremium
                                  ? Icons.workspace_premium_rounded
                                  : Icons.lock_open_rounded,
                              color: isPremium
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF475467),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isPremium
                                    ? l10n.dashboardPremiumActiveLabel(
                                        premiumLabel,
                                      )
                                    : l10n.dashboardFreeVersionActive,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isPremium
                                      ? const Color(0xFF92400E)
                                      : const Color(0xFF475467),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isPremium
                              ? l10n.dashboardPremiumBenefitsActive
                              : l10n.dashboardPremiumBenefitsLocked,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FeatureChip(
                        label: l10n.dashboardPremiumPillSmartAnalysis,
                      ),
                      _FeatureChip(
                        label: l10n.dashboardPremiumPillAdvice,
                      ),
                      _FeatureChip(
                        label: l10n.dashboardPremiumPillExcel,
                      ),
                      _FeatureChip(
                        label: l10n.dashboardPremiumPillFamily,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _openPremiumScreen,
                      icon: Icon(
                        isPremium
                            ? Icons.settings_outlined
                            : Icons.workspace_premium_rounded,
                      ),
                      label: Text(
                        isPremium
                            ? l10n.dashboardManageSubscription
                            : l10n.dashboardSeePremiumOffers,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _isRestoringPurchases ? null : _restorePurchases,
                      icon: const Icon(Icons.restore_rounded),
                      label: Text(
                        _isRestoringPurchases
                            ? l10n.dashboardRestoring
                            : l10n.dashboardRestorePurchases,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openFamilySheet() async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dashboardFamilyModeActive,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _familyId != null
                          ? const Color(0xFFF5F3FF)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _familyId != null
                            ? const Color(0xFFC4B5FD)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _familyId != null
                                  ? Icons.groups_rounded
                                  : Icons.person_outline_rounded,
                              color: _familyId != null
                                  ? const Color(0xFF6D28D9)
                                  : const Color(0xFF475467),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _familyId != null
                                    ? l10n.dashboardFamilyModeActive
                                    : l10n.dashboardPersonalBudgetActive,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _familyId != null
                                      ? const Color(0xFF5B21B6)
                                      : const Color(0xFF475467),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _familyId != null
                              ? l10n.dashboardFamilySharedDescription
                              : l10n.dashboardPersonalBudgetDescription,
                          style: const TextStyle(
                            color: Color(0xFF475467),
                            height: 1.35,
                          ),
                        ),
                        if (_familyName != null && _familyName!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.dashboardFamilyName(_familyName!),
                            style: const TextStyle(
                              color: Color(0xFF5B21B6),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (_familyId != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE9D5FF),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.dashboardFamilyIdTitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SelectableText(
                                  _familyId!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    letterSpacing: 0.3,
                                    color: Color(0xFF4C1D95),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _copyFamilyId,
                                  icon: const Icon(Icons.copy_rounded),
                                  label: Text(l10n.commonCopy),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _shareFamilyId,
                                  icon: const Icon(Icons.share_rounded),
                                  label: Text(l10n.commonShare),
                                ),
                              ),
                            ],
                          ),
                          if (_isCurrentUserFamilyOwner) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _isFamilyActionLoading
                                    ? null
                                    : _transferFamilyOwnership,
                                icon: const Icon(Icons.swap_horiz_rounded),
                                label: Text(
                                  _isFamilyActionLoading
                                      ? l10n.dashboardProcessing
                                      : _isPremium
                                          ? l10n
                                              .dashboardTransferOwnershipAction
                                          : l10n
                                              .dashboardTransferOwnershipPremium,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _isFamilyActionLoading
                                    ? null
                                    : _dissolveFamily,
                                icon: const Icon(Icons.delete_forever_rounded),
                                label: Text(
                                  _isFamilyActionLoading
                                      ? l10n.dashboardProcessing
                                      : _isPremium
                                          ? l10n.dashboardDeleteFamilyAction
                                          : l10n.dashboardDeleteFamilyPremium,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                        ] else ...[
                          const SizedBox(height: 12),
                        ],
                        if (_familyId == null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isFamilyActionLoading
                                      ? null
                                      : _createFamily,
                                  icon: const Icon(Icons.group_add_rounded),
                                  label: Text(
                                    _isFamilyActionLoading
                                        ? l10n.dashboardProcessing
                                        : _isPremium
                                            ? l10n.dashboardCreateFamilyAction
                                            : l10n.dashboardCreateFamilyPremium,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _isFamilyActionLoading
                                      ? null
                                      : _joinFamily,
                                  icon: const Icon(Icons.login_rounded),
                                  label: Text(l10n.dashboardJoinFamilyAction),
                                ),
                              ),
                            ],
                          ),
                          if (!_isPremium) ...[
                            const SizedBox(height: 8),
                            Text(
                              l10n.dashboardFamilyPremiumHint,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ] else
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed:
                                  _isFamilyActionLoading ? null : _leaveFamily,
                              icon: const Icon(Icons.exit_to_app_rounded),
                              label: Text(
                                _isFamilyActionLoading
                                    ? l10n.dashboardProcessing
                                    : l10n.dashboardLeaveFamilyAction,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() {});
  }

  Widget _buildLanguageDropdown() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9E0EE)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguageCode,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
          ),
          borderRadius: BorderRadius.circular(14),
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          items: const [
            DropdownMenuItem(
              value: 'fr',
              child: Text('FR'),
            ),
            DropdownMenuItem(
              value: 'en',
              child: Text('EN'),
            ),
            DropdownMenuItem(
              value: 'nl',
              child: Text('NL'),
            ),
          ],
          onChanged: _changeLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monetization = BudgetFamilialMonetizationScope.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final income = _appBudget.incomeTotalForPeriod(_currentPeriodKey);
    final expenses = _appBudget.expenseTotalForPeriod(_currentPeriodKey);
    final savings = _appBudget.savingTotalForPeriod(_currentPeriodKey);
    final balance = _appBudget.balanceForPeriod(_currentPeriodKey);

    return AnimatedBuilder(
      animation: monetization,
      builder: (context, _) {
        final isPremium = monetization.isPremium;
        final premiumLabel = monetization.premiumPlanLabel;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.appTitle,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Center(
                  child: _buildLanguageDropdown(),
                ),
              ),
              PopupMenuButton<_DashboardMenuAction>(
                tooltip: l10n.dashboardOptionsTooltip,
                onSelected: _handleTopMenuAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _DashboardMenuAction.family,
                    child: Row(
                      children: [
                        const Icon(Icons.groups_rounded),
                        const SizedBox(width: 10),
                        Text(l10n.dashboardFamilyModeActive),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _DashboardMenuAction.account,
                    child: Row(
                      children: [
                        const Icon(Icons.account_circle_outlined),
                        const SizedBox(width: 10),
                        Text(l10n.dashboardOptionsTooltip),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _DashboardMenuAction.premium,
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium_rounded),
                        const SizedBox(width: 10),
                        Text(l10n.dashboardMenuPremium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _DashboardMenuAction.restorePurchases,
                    enabled: !_isRestoringPurchases,
                    child: Row(
                      children: [
                        const Icon(Icons.restore_rounded),
                        const SizedBox(width: 10),
                        Text(
                          _isRestoringPurchases
                              ? l10n.dashboardRestoring
                              : l10n.dashboardRestorePurchases,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _DashboardMenuAction.privacyOptions,
                    enabled: !_isOpeningPrivacyOptions,
                    child: Row(
                      children: [
                        const Icon(Icons.privacy_tip_outlined),
                        const SizedBox(width: 10),
                        Text(
                          _isOpeningPrivacyOptions
                              ? l10n.dashboardOpening
                              : l10n.dashboardPrivacyRgpd,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _DashboardMenuAction.signOut,
                    enabled: !_isSigningOut,
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded),
                        const SizedBox(width: 10),
                        Text(
                          _isSigningOut
                              ? l10n.dashboardSigningOut
                              : l10n.dashboardSignOut,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: PremiumBannerAd(
              controller: monetization,
              adsService: _adsService,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHeroCard(
                    l10n: l10n,
                    selectedMonth: _selectedMonth,
                    selectedYear: _selectedYear,
                    months: _months,
                    years: _years,
                    onChangeMonth: _changeMonth,
                    onChangeYear: _changeYear,
                    selectedMonthLabel: _localizedMonthLabel(_selectedMonth),
                    income: income,
                    expenses: expenses,
                    savings: savings,
                    balance: balance,
                    isPremium: isPremium,
                    premiumLabel: premiumLabel,
                    hasFamily: _familyId != null,
                    familyName: _familyName,
                    onOpenAnalysis: _openAnalysisScreen,
                    onOpenRecap: _openRecapScreen,
                    onOpenFamily: _openFamilySheet,
                    onOpenAccount: _openAccountSheet,
                    onOpenPremium: _openPremiumSheet,
                    localizedMonthLabelBuilder: _localizedMonthLabel,
                  ),
                  const SizedBox(height: 18),
                  BudgetSectionCard(
                    section: _appBudget.incomeTemplate,
                    periodKey: _currentPeriodKey,
                    amountProvider: (column) =>
                        _currentPeriod.getIncomeAmount(column.id),
                    isExpanded: _incomeSectionExpanded,
                    onToggleExpanded: () {
                      setState(() {
                        _incomeSectionExpanded = !_incomeSectionExpanded;
                      });
                    },
                    onAddColumn: () =>
                        _showAddColumnDialog(_appBudget.incomeTemplate),
                    onRenameColumn: (column) => _showRenameColumnDialog(
                      _appBudget.incomeTemplate,
                      column,
                    ),
                    onAmountChanged: _updateIncomeAmount,
                    onDeleteColumn: _deleteIncomeColumn,
                  ),
                  BudgetExpenseSectionCard(
                    section: _appBudget.expenseTemplate,
                    sectionExpanded: _expenseSectionExpanded,
                    onToggleSection: () {
                      setState(() {
                        _expenseSectionExpanded = !_expenseSectionExpanded;
                      });
                    },
                    categoryTotalProvider: (category) =>
                        _appBudget.expenseCategoryTotalForPeriod(
                      _currentPeriodKey,
                      category,
                    ),
                    subCategoryTotalProvider: (subCategory) =>
                        _currentPeriod.getExpenseSubCategoryTotal(
                      subCategory.id,
                    ),
                    subCategoryEntryCountProvider: (subCategory) =>
                        _currentPeriod.getExpenseSubCategoryEntryCount(
                      subCategory.id,
                    ),
                    isCategoryExpanded: _isExpenseCategoryExpanded,
                    onToggleCategory: _toggleExpenseCategory,
                    onAddCategory: _showAddExpenseCategoryDialog,
                    onRenameCategory: _showRenameExpenseCategoryDialog,
                    onDeleteCategory: _deleteExpenseCategory,
                    onAddSubCategory: _showAddExpenseSubCategoryDialog,
                    onRenameSubCategory: _showRenameExpenseSubCategoryDialog,
                    onDeleteSubCategory: _deleteExpenseSubCategory,
                    onAddEntry: _showAddEntryDialog,
                  ),
                  BudgetSectionCard(
                    section: _appBudget.savingTemplate,
                    periodKey: _currentPeriodKey,
                    amountProvider: (column) =>
                        _currentPeriod.getSavingAmount(column.id),
                    isExpanded: _savingSectionExpanded,
                    onToggleExpanded: () {
                      setState(() {
                        _savingSectionExpanded = !_savingSectionExpanded;
                      });
                    },
                    onAddColumn: () =>
                        _showAddColumnDialog(_appBudget.savingTemplate),
                    onRenameColumn: (column) => _showRenameColumnDialog(
                      _appBudget.savingTemplate,
                      column,
                    ),
                    onAmountChanged: _updateSavingAmount,
                    onDeleteColumn: _deleteSavingColumn,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddColumnDialog(BudgetSectionTemplate section) async {
    final localizedSectionTitle = _localizedSectionTitle(section);

    final result = await _showTextInputDialog(
      title: l10n.dashboardAddCategoryForSection(localizedSectionTitle),
      label: l10n.dashboardCategoryNameLabel,
    );

    if (result == null || result.isEmpty) return;

    final exists = section.columns.any(
      (item) => item.name.toLowerCase().trim() == result.toLowerCase().trim(),
    );

    if (exists) {
      await _showInfoDialog(
        l10n.dashboardExistingCategoryTitle,
        l10n.dashboardExistingCategoryInSection(localizedSectionTitle),
      );
      return;
    }

    _applyAndSave(() {
      section.columns.add(
        BudgetColumnTemplate(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: result,
        ),
      );
    });
  }

  Future<void> _showRenameColumnDialog(
    BudgetSectionTemplate section,
    BudgetColumnTemplate column,
  ) async {
    final result = await _showTextInputDialog(
      title: l10n.dashboardRenameCategoryTitle,
      label: l10n.dashboardNewNameLabel,
      initialValue: column.name,
    );

    if (result == null || result.isEmpty) return;

    final exists = section.columns.any(
      (item) =>
          item.id != column.id &&
          item.name.toLowerCase().trim() == result.toLowerCase().trim(),
    );

    if (exists) {
      await _showInfoDialog(
        l10n.dashboardExistingCategoryTitle,
        l10n.dashboardAnotherCategorySameName,
      );
      return;
    }

    _applyAndSave(() {
      column.name = result;
    });
  }

  void _updateIncomeAmount(BudgetColumnTemplate column, String value) {
    final normalized = value.replaceAll(',', '.').trim();
    final amount = double.tryParse(normalized) ?? 0;

    _applyAndSave(() {
      _currentPeriod.setIncomeAmount(column.id, amount);
    });
  }

  void _updateSavingAmount(BudgetColumnTemplate column, String value) {
    final normalized = value.replaceAll(',', '.').trim();
    final amount = double.tryParse(normalized) ?? 0;

    _applyAndSave(() {
      _currentPeriod.setSavingAmount(column.id, amount);
    });
  }

  void _deleteIncomeColumn(BudgetColumnTemplate column) {
    _applyAndSave(() {
      _appBudget.incomeTemplate.columns.removeWhere(
        (item) => item.id == column.id,
      );
      for (final period in _appBudget.periods.values) {
        period.incomeAmounts.remove(column.id);
      }
    });
  }

  void _deleteSavingColumn(BudgetColumnTemplate column) {
    _applyAndSave(() {
      _appBudget.savingTemplate.columns.removeWhere(
        (item) => item.id == column.id,
      );
      for (final period in _appBudget.periods.values) {
        period.savingAmounts.remove(column.id);
      }
    });
  }

  Future<void> _showAddExpenseCategoryDialog() async {
    final result = await _showTextInputDialog(
      title: l10n.dashboardAddExpenseCategoryTitle,
      label: l10n.dashboardCategoryNameLabel,
    );

    if (result == null || result.isEmpty) return;

    final exists = _appBudget.expenseTemplate.categories.any(
      (item) => item.name.toLowerCase().trim() == result.toLowerCase().trim(),
    );

    if (exists) {
      await _showInfoDialog(
        l10n.dashboardExistingCategoryTitle,
        l10n.dashboardExistingExpenseCategory,
      );
      return;
    }

    _applyAndSave(() {
      _appBudget.expenseTemplate.categories.add(
        ExpenseCategoryTemplate(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: result,
        ),
      );
    });
  }

  Future<void> _showRenameExpenseCategoryDialog(
    ExpenseCategoryTemplate category,
  ) async {
    final result = await _showTextInputDialog(
      title: l10n.dashboardRenameCategoryTitle,
      label: l10n.dashboardNewNameLabel,
      initialValue: category.name,
    );

    if (result == null || result.isEmpty) return;

    final exists = _appBudget.expenseTemplate.categories.any(
      (item) =>
          item.id != category.id &&
          item.name.toLowerCase().trim() == result.toLowerCase().trim(),
    );

    if (exists) {
      await _showInfoDialog(
        l10n.dashboardExistingCategoryTitle,
        l10n.dashboardAnotherCategorySameName,
      );
      return;
    }

    _applyAndSave(() {
      category.name = result;
    });
  }

  void _deleteExpenseCategory(ExpenseCategoryTemplate category) {
    final subCategoryIds = category.subCategories.map((e) => e.id).toList();

    _applyAndSave(() {
      _expandedExpenseCategoryIds.remove(category.id);

      _appBudget.expenseTemplate.categories.removeWhere(
        (item) => item.id == category.id,
      );

      for (final period in _appBudget.periods.values) {
        for (final subCategoryId in subCategoryIds) {
          period.expenseEntriesBySubCategoryId.remove(subCategoryId);
        }
      }
    });
  }

  Future<void> _showAddExpenseSubCategoryDialog(
    ExpenseCategoryTemplate category,
  ) async {
    final result = await _showTextInputDialog(
      title: l10n.dashboardAddExpenseSubCategoryFor(category.name),
      label: l10n.dashboardSubCategoryNameLabel,
    );

    if (result == null || result.isEmpty) return;

    final exists = category.subCategories.any(
      (item) => item.name.toLowerCase().trim() == result.toLowerCase().trim(),
    );

    if (exists) {
      await _showInfoDialog(
        l10n.dashboardExistingSubCategoryTitle,
        l10n.dashboardExistingSubCategoryIn(category.name),
      );
      return;
    }

    _applyAndSave(() {
      category.subCategories.add(
        ExpenseSubCategoryTemplate(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: result,
        ),
      );
      _expandedExpenseCategoryIds.add(category.id);
    });
  }

  Future<void> _showRenameExpenseSubCategoryDialog(
    ExpenseSubCategoryTemplate subCategory,
  ) async {
    final result = await _showTextInputDialog(
      title: l10n.dashboardRenameSubCategoryTitle,
      label: l10n.dashboardNewNameLabel,
      initialValue: subCategory.name,
    );

    if (result == null || result.isEmpty) return;

    ExpenseCategoryTemplate? parentCategory;

    for (final category in _appBudget.expenseTemplate.categories) {
      if (category.subCategories.any((item) => item.id == subCategory.id)) {
        parentCategory = category;
        break;
      }
    }

    if (parentCategory != null) {
      final exists = parentCategory.subCategories.any(
        (item) =>
            item.id != subCategory.id &&
            item.name.toLowerCase().trim() == result.toLowerCase().trim(),
      );

      if (exists) {
        await _showInfoDialog(
          l10n.dashboardExistingSubCategoryTitle,
          l10n.dashboardAnotherSubCategorySameNameIn(parentCategory.name),
        );
        return;
      }
    }

    _applyAndSave(() {
      subCategory.name = result;
    });
  }

  void _deleteExpenseSubCategory(
    ExpenseCategoryTemplate category,
    ExpenseSubCategoryTemplate subCategory,
  ) {
    _applyAndSave(() {
      category.subCategories.removeWhere((item) => item.id == subCategory.id);
      for (final period in _appBudget.periods.values) {
        period.expenseEntriesBySubCategoryId.remove(subCategory.id);
      }
    });
  }

  Future<void> _showAddEntryDialog(
      ExpenseSubCategoryTemplate subCategory) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.dashboardAddAmountFor(subCategory.name)),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.dashboardAmountLabel,
              border: const OutlineInputBorder(),
              prefixText: '€ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(l10n.commonAdd),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) return;

    final normalized = result.replaceAll(',', '.').trim();
    final amount = double.tryParse(normalized);

    if (amount == null || amount <= 0) {
      await _showInfoDialog(
        l10n.dashboardInvalidAmountTitle,
        l10n.dashboardInvalidAmountMessage,
      );
      return;
    }

    _applyAndSave(() {
      _currentPeriod.addExpenseEntry(
        subCategory.id,
        ExpenseEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          amount: amount,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  void _deleteExpenseEntry(ExpenseRowData row) {
    _applyAndSave(() {
      _currentPeriod.removeExpenseEntry(row.subCategoryId, row.entryId);
    });
  }
}

class _DashboardHeroCard extends StatelessWidget {
  const _DashboardHeroCard({
    required this.l10n,
    required this.selectedMonth,
    required this.selectedYear,
    required this.months,
    required this.years,
    required this.onChangeMonth,
    required this.onChangeYear,
    required this.selectedMonthLabel,
    required this.income,
    required this.expenses,
    required this.savings,
    required this.balance,
    required this.isPremium,
    required this.premiumLabel,
    required this.hasFamily,
    required this.familyName,
    required this.onOpenAnalysis,
    required this.onOpenRecap,
    required this.onOpenFamily,
    required this.onOpenAccount,
    required this.onOpenPremium,
    required this.localizedMonthLabelBuilder,
  });

  final AppLocalizations l10n;
  final String selectedMonth;
  final int selectedYear;
  final List<String> months;
  final List<int> years;
  final ValueChanged<String?> onChangeMonth;
  final ValueChanged<int?> onChangeYear;
  final String selectedMonthLabel;
  final double income;
  final double expenses;
  final double savings;
  final double balance;
  final bool isPremium;
  final String premiumLabel;
  final bool hasFamily;
  final String? familyName;
  final VoidCallback onOpenAnalysis;
  final VoidCallback onOpenRecap;
  final VoidCallback onOpenFamily;
  final VoidCallback onOpenAccount;
  final VoidCallback onOpenPremium;
  final String Function(String month) localizedMonthLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        final metricWidth =
            isCompact ? (constraints.maxWidth - 18 * 2 - 12) / 2 : 160.0;

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x334F46E5),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dashboardTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    l10n.dashboardActivePeriod(
                      selectedMonthLabel,
                      selectedYear.toString(),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (isCompact) ...[
                  _HeroFieldLabel(label: l10n.dashboardYearLabel),
                  const SizedBox(height: 6),
                  _HeroDropdownField<int>(
                    value: selectedYear,
                    items: years
                        .map(
                          (year) => DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: onChangeYear,
                  ),
                  const SizedBox(height: 12),
                  _HeroFieldLabel(label: l10n.dashboardMonthLabel),
                  const SizedBox(height: 6),
                  _HeroDropdownField<String>(
                    value: selectedMonth,
                    items: months
                        .map(
                          (month) => DropdownMenuItem<String>(
                            value: month,
                            child: Text(localizedMonthLabelBuilder(month)),
                          ),
                        )
                        .toList(),
                    onChanged: onChangeMonth,
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeroFieldLabel(label: l10n.dashboardYearLabel),
                            const SizedBox(height: 6),
                            _HeroDropdownField<int>(
                              value: selectedYear,
                              items: years
                                  .map(
                                    (year) => DropdownMenuItem<int>(
                                      value: year,
                                      child: Text(year.toString()),
                                    ),
                                  )
                                  .toList(),
                              onChanged: onChangeYear,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeroFieldLabel(label: l10n.dashboardMonthLabel),
                            const SizedBox(height: 6),
                            _HeroDropdownField<String>(
                              value: selectedMonth,
                              items: months
                                  .map(
                                    (month) => DropdownMenuItem<String>(
                                      value: month,
                                      child: Text(
                                          localizedMonthLabelBuilder(month)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: onChangeMonth,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroInfoChip(
                      icon: hasFamily
                          ? Icons.groups_rounded
                          : Icons.person_rounded,
                      label: hasFamily
                          ? (familyName != null && familyName!.isNotEmpty
                              ? familyName!
                              : l10n.dashboardFamilyModeActive)
                          : l10n.dashboardPersonalBudgetActive,
                    ),
                    _HeroInfoChip(
                      icon: isPremium
                          ? Icons.workspace_premium_rounded
                          : Icons.lock_open_rounded,
                      label: isPremium
                          ? l10n.dashboardPremiumActiveLabel(premiumLabel)
                          : l10n.dashboardFreeVersionActive,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _DashboardMetricCard(
                      width: metricWidth,
                      title: l10n.dashboardIncome,
                      value: income,
                      icon: Icons.south_west_rounded,
                      color: const Color(0xFF22C55E),
                    ),
                    _DashboardMetricCard(
                      width: metricWidth,
                      title: l10n.dashboardExpenses,
                      value: expenses,
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFFFB7185),
                    ),
                    _DashboardMetricCard(
                      width: metricWidth,
                      title: l10n.dashboardSavings,
                      value: savings,
                      icon: Icons.savings_rounded,
                      color: const Color(0xFF60A5FA),
                    ),
                    _DashboardMetricCard(
                      width: metricWidth,
                      title: l10n.dashboardBalance,
                      value: balance,
                      icon: Icons.account_balance_wallet_rounded,
                      color: balance >= 0
                          ? const Color(0xFF2DD4BF)
                          : const Color(0xFFF59E0B),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isCompact) ...[
                  _HeroPrimaryButton(
                    label: l10n.dashboardAnalysisAction,
                    icon: Icons.insights_rounded,
                    filled: true,
                    onPressed: onOpenAnalysis,
                  ),
                  const SizedBox(height: 10),
                  _HeroPrimaryButton(
                    label: l10n.dashboardDetailAction,
                    icon: Icons.receipt_long_rounded,
                    filled: false,
                    onPressed: onOpenRecap,
                  ),
                  const SizedBox(height: 10),
                  _HeroPrimaryButton(
                    label: l10n.dashboardFamilyModeActive,
                    icon: Icons.groups_rounded,
                    filled: false,
                    onPressed: onOpenFamily,
                  ),
                  const SizedBox(height: 10),
                  _HeroPrimaryButton(
                    label: l10n.dashboardOptionsTooltip,
                    icon: Icons.account_circle_outlined,
                    filled: false,
                    onPressed: onOpenAccount,
                  ),
                  const SizedBox(height: 10),
                  _HeroPrimaryButton(
                    label: isPremium
                        ? l10n.dashboardManagePremium
                        : l10n.dashboardSubscription,
                    icon: Icons.workspace_premium_rounded,
                    filled: false,
                    onPressed: onOpenPremium,
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _HeroPrimaryButton(
                          label: l10n.dashboardAnalysisAction,
                          icon: Icons.insights_rounded,
                          filled: true,
                          onPressed: onOpenAnalysis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HeroPrimaryButton(
                          label: l10n.dashboardDetailAction,
                          icon: Icons.receipt_long_rounded,
                          filled: false,
                          onPressed: onOpenRecap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 180,
                        child: _HeroPrimaryButton(
                          label: l10n.dashboardFamilyModeActive,
                          icon: Icons.groups_rounded,
                          filled: false,
                          onPressed: onOpenFamily,
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: _HeroPrimaryButton(
                          label: l10n.dashboardOptionsTooltip,
                          icon: Icons.account_circle_outlined,
                          filled: false,
                          onPressed: onOpenAccount,
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: _HeroPrimaryButton(
                          label: isPremium
                              ? l10n.dashboardManagePremium
                              : l10n.dashboardSubscription,
                          icon: Icons.workspace_premium_rounded,
                          filled: false,
                          onPressed: onOpenPremium,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroFieldLabel extends StatelessWidget {
  const _HeroFieldLabel({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _HeroDropdownField<T> extends StatelessWidget {
  const _HeroDropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      dropdownColor: Colors.white,
      items: items,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      style: const TextStyle(
        color: Color(0xFF111827),
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0x66FFFFFF),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _HeroPrimaryButton extends StatelessWidget {
  const _HeroPrimaryButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4338CA),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white54),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final double width;
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${value.toStringAsFixed(2)} €',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroInfoChip extends StatelessWidget {
  const _HeroInfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      side: const BorderSide(color: Color(0xFFE5E7EB)),
      backgroundColor: const Color(0xFFF8FAFC),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }
}

enum _DashboardMenuAction {
  family,
  account,
  premium,
  restorePurchases,
  privacyOptions,
  signOut,
}

enum _LeaveFamilyChoice {
  restorePersonalBudget,
  copyFamilyBudget,
}
