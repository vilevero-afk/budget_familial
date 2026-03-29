import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../monetization/budget_familial_monetization_scope.dart';
import '../monetization/paywall_screen.dart';
import '../services/auth_service.dart';
import '../services/budget_cloud_service.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({
    super.key,
  });

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final AuthService _authService = AuthService();
  final BudgetCloudService _budgetCloudService = BudgetCloudService();

  bool _isLoading = true;
  bool _isFamilyActionLoading = false;

  String? _familyId;
  String? _familyOwnerUid;
  String? _familyName;
  List<String> _familyMemberUids = const [];

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool get _isPremium {
    return BudgetFamilialMonetizationScope.of(context).isPremium;
  }

  bool get _isCurrentUserFamilyOwner {
    final currentUid = _authService.currentUser?.uid;
    if (currentUid == null) return false;
    return _familyId != null && _familyOwnerUid == currentUid;
  }

  bool get _canCreateFamily => _isPremium;

  bool get _canManageFamily {
    return _familyId != null && _isCurrentUserFamilyOwner && _isPremium;
  }

  List<String> get _transferCandidates {
    final currentUid = _authService.currentUser?.uid;
    return _familyMemberUids.where((uid) => uid != currentUid).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadFamilyData();
  }

  Future<void> _loadFamilyData() async {
    String? familyId;
    FamilyInfo? familyInfo;

    try {
      if (_budgetCloudService.isSignedIn) {
        familyId = await _budgetCloudService.getCurrentFamilyId();
        familyInfo = await _budgetCloudService.getCurrentFamilyInfo();
      }
    } catch (e) {
      debugPrint('Family load error: $e');
    }

    if (!mounted) return;

    setState(() {
      _familyId = familyId;
      _familyOwnerUid = familyInfo?.ownerUid;
      _familyName = familyInfo?.name;
      _familyMemberUids = familyInfo?.members ?? const [];
      _isLoading = false;
    });
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
      await _loadFamilyData();

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
      await _loadFamilyData();

      if (!mounted) return;

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
      await _loadFamilyData();

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
      await _loadFamilyData();

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
      await _loadFamilyData();

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

  Widget _buildStatusCard() {
    final hasFamily = _familyId != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: hasFamily ? const Color(0xFFF5F3FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasFamily ? const Color(0xFFC4B5FD) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasFamily ? Icons.groups_rounded : Icons.person_outline_rounded,
                color: hasFamily
                    ? const Color(0xFF6D28D9)
                    : const Color(0xFF475467),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasFamily
                      ? l10n.dashboardFamilyModeActive
                      : l10n.dashboardPersonalBudgetActive,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: hasFamily
                        ? const Color(0xFF5B21B6)
                        : const Color(0xFF475467),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasFamily
                ? l10n.dashboardFamilySharedDescription
                : l10n.dashboardPersonalBudgetDescription,
            style: const TextStyle(
              color: Color(0xFF475467),
              height: 1.35,
            ),
          ),
          if (_familyName != null && _familyName!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              l10n.dashboardFamilyName(_familyName!),
              style: const TextStyle(
                color: Color(0xFF5B21B6),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFamilyIdCard() {
    if (_familyId == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9D5FF)),
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
          const SizedBox(height: 14),
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
        ],
      ),
    );
  }

  Widget _buildPremiumHintCard() {
    if (_isPremium) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFD97706),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Premium',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.dashboardFamilyPremiumHint,
            style: const TextStyle(
              color: Color(0xFF92400E),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _openPremiumScreen,
            icon: const Icon(Icons.workspace_premium_rounded),
            label: Text(l10n.dashboardSeeOffers),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    final hasFamily = _familyId != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasFamily
                ? l10n.dashboardFamilyModeActive
                : l10n.dashboardCreateFamilyTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          if (!hasFamily) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isFamilyActionLoading ? null : _createFamily,
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
                    onPressed: _isFamilyActionLoading ? null : _joinFamily,
                    icon: const Icon(Icons.login_rounded),
                    label: Text(l10n.dashboardJoinFamilyAction),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isFamilyActionLoading ? null : _leaveFamily,
                icon: const Icon(Icons.exit_to_app_rounded),
                label: Text(
                  _isFamilyActionLoading
                      ? l10n.dashboardProcessing
                      : l10n.dashboardLeaveFamilyAction,
                ),
              ),
            ),
            if (_isCurrentUserFamilyOwner) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                  _isFamilyActionLoading ? null : _transferFamilyOwnership,
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: Text(
                    _isFamilyActionLoading
                        ? l10n.dashboardProcessing
                        : _isPremium
                        ? l10n.dashboardTransferOwnershipAction
                        : l10n.dashboardTransferOwnershipPremium,
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
                  onPressed: _isFamilyActionLoading ? null : _dissolveFamily,
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
          ],
        ],
      ),
    );
  }

  Widget _buildMembersCard() {
    if (_familyId == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dashboardMemberLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          if (_familyMemberUids.isEmpty)
            const Text(
              '-',
              style: TextStyle(color: Color(0xFF6B7280)),
            )
          else
            ..._familyMemberUids.map(
                  (uid) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Icon(
                      uid == _familyOwnerUid
                          ? Icons.verified_user_outlined
                          : Icons.person_outline_rounded,
                      size: 18,
                      color: uid == _familyOwnerUid
                          ? const Color(0xFF6D28D9)
                          : const Color(0xFF475467),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        uid,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.dashboardFamilyModeActive,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadFamilyData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            if (currentUser?.email != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
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
                        l10n.dashboardConnectedAs(currentUser!.email!),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475467),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildStatusCard(),
            const SizedBox(height: 14),
            _buildPremiumHintCard(),
            if (!_isPremium) const SizedBox(height: 14),
            _buildFamilyIdCard(),
            if (_familyId != null) const SizedBox(height: 14),
            _buildMembersCard(),
            if (_familyId != null) const SizedBox(height: 14),
            _buildActionsCard(),
          ],
        ),
      ),
    );
  }
}

enum _LeaveFamilyChoice {
  restorePersonalBudget,
  copyFamilyBudget,
}