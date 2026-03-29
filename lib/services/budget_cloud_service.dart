import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/budget_models.dart';

class FamilyInfo {
  FamilyInfo({
    required this.familyId,
    required this.ownerUid,
    required this.members,
    this.name,
  });

  final String familyId;
  final String ownerUid;
  final List<String> members;
  final String? name;
}

class BudgetDocumentSnapshotData {
  const BudgetDocumentSnapshotData({
    required this.budget,
    required this.revision,
    required this.updatedBy,
    required this.updatedAt,
    required this.isFamilyBudget,
    required this.documentPath,
  });

  final AppBudgetData? budget;
  final int revision;
  final String? updatedBy;
  final DateTime? updatedAt;
  final bool isFamilyBudget;
  final String documentPath;
}

class BudgetSaveConflictException implements Exception {
  BudgetSaveConflictException({
    required this.expectedRevision,
    required this.actualRevision,
    this.message = 'Le budget a été modifié ailleurs avant cette sauvegarde.',
  });

  final int expectedRevision;
  final int actualRevision;
  final String message;

  @override
  String toString() {
    return 'BudgetSaveConflictException('
        'expectedRevision: $expectedRevision, '
        'actualRevision: $actualRevision, '
        'message: $message'
        ')';
  }
}

class BudgetCloudService {
  BudgetCloudService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _usersCollection = 'users';
  static const String _familiesCollection = 'families';
  static const String _privateCollection = 'private';

  static const String _budgetDocumentName = 'budget';
  static const String _updatedAtField = 'updatedAt';
  static const String _updatedByField = 'updatedBy';
  static const String _revisionField = 'revision';
  static const String _dataField = 'data';

  static const String _familyIdField = 'familyId';
  static const String _ownerUidField = 'ownerUid';
  static const String _membersField = 'members';
  static const String _createdAtField = 'createdAt';
  static const String _nameField = 'name';

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => currentUser != null;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection(_usersCollection).doc(uid);
  }

  DocumentReference<Map<String, dynamic>> _familyDoc(String familyId) {
    return _firestore.collection(_familiesCollection).doc(familyId);
  }

  DocumentReference<Map<String, dynamic>> _personalBudgetDoc(String uid) {
    return _userDoc(uid);
  }

  DocumentReference<Map<String, dynamic>> _familyBudgetDoc(String familyId) {
    return _familyDoc(familyId)
        .collection(_privateCollection)
        .doc(_budgetDocumentName);
  }

  String? _normalizeFamilyId(dynamic value) {
    if (value is! String) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String? _normalizeUid(dynamic value) {
    if (value is! String) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  List<String> _normalizeMembers(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> _normalizedMembersIncludingOwner({
    required dynamic membersValue,
    required dynamic ownerUidValue,
  }) {
    final members = _normalizeMembers(membersValue).toSet();

    if (ownerUidValue is String) {
      final ownerUid = ownerUidValue.trim();
      if (ownerUid.isNotEmpty) {
        members.add(ownerUid);
      }
    }

    return members.toList();
  }

  int _readRevisionFromPayload(Map<String, dynamic>? payload) {
    final rawRevision = payload?[_revisionField];
    if (rawRevision is int && rawRevision >= 0) {
      return rawRevision;
    }
    return 0;
  }

  DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  AppBudgetData? _decodeBudgetPayload(Map<String, dynamic>? payload) {
    if (payload == null) return null;

    final rawData = payload[_dataField];
    if (rawData is! Map<String, dynamic>) {
      return null;
    }

    try {
      return AppBudgetData.fromJson(rawData);
    } catch (_) {
      return null;
    }
  }

  BudgetDocumentSnapshotData _buildBudgetSnapshotData({
    required Map<String, dynamic>? payload,
    required bool isFamilyBudget,
    required String documentPath,
  }) {
    return BudgetDocumentSnapshotData(
      budget: _decodeBudgetPayload(payload),
      revision: _readRevisionFromPayload(payload),
      updatedBy: _normalizeUid(payload?[_updatedByField]),
      updatedAt: _readDateTime(payload?[_updatedAtField]),
      isFamilyBudget: isFamilyBudget,
      documentPath: documentPath,
    );
  }

  Future<String?> getCurrentFamilyId() async {
    final user = currentUser;
    if (user == null) return null;

    final snapshot = await _userDoc(user.uid).get();
    final data = snapshot.data();

    return _normalizeFamilyId(data?[_familyIdField]);
  }

  Future<FamilyInfo?> getCurrentFamilyInfo() async {
    final familyId = await getCurrentFamilyId();
    if (familyId == null) return null;

    final snapshot = await _familyDoc(familyId).get();
    if (!snapshot.exists) return null;

    final data = snapshot.data() ?? <String, dynamic>{};
    final ownerUid = data[_ownerUidField];
    if (ownerUid is! String || ownerUid.trim().isEmpty) {
      return null;
    }

    return FamilyInfo(
      familyId: familyId,
      ownerUid: ownerUid.trim(),
      members: _normalizedMembersIncludingOwner(
        membersValue: data[_membersField],
        ownerUidValue: ownerUid,
      ),
      name: data[_nameField] is String &&
              (data[_nameField] as String).trim().isNotEmpty
          ? (data[_nameField] as String).trim()
          : null,
    );
  }

  Future<void> transferFamilyOwnership(String newOwnerUid) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Aucun utilisateur connecté.');
    }

    final normalizedNewOwnerUid = newOwnerUid.trim();
    if (normalizedNewOwnerUid.isEmpty) {
      throw Exception('Nouveau propriétaire invalide.');
    }

    final familyId = await getCurrentFamilyId();
    if (familyId == null) {
      throw Exception('Aucune famille active.');
    }

    final familyRef = _familyDoc(familyId);

    await _firestore.runTransaction((transaction) async {
      final familySnapshot = await transaction.get(familyRef);

      if (!familySnapshot.exists) {
        throw Exception('Famille introuvable.');
      }

      final familyData = familySnapshot.data() ?? <String, dynamic>{};
      final ownerUid = familyData[_ownerUidField];
      final members = _normalizedMembersIncludingOwner(
        membersValue: familyData[_membersField],
        ownerUidValue: ownerUid,
      );

      if (ownerUid != user.uid) {
        throw Exception(
            'Seul le propriétaire actuel peut transférer la famille.');
      }

      if (normalizedNewOwnerUid == user.uid) {
        throw Exception('Choisis un autre membre comme nouveau propriétaire.');
      }

      if (!members.contains(normalizedNewOwnerUid)) {
        throw Exception(
            'Le nouveau propriétaire doit déjà être membre de la famille.');
      }

      transaction.set(
        familyRef,
        {
          _ownerUidField: normalizedNewOwnerUid,
          _membersField: FieldValue.arrayUnion([normalizedNewOwnerUid]),
          _updatedAtField: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<void> dissolveFamily() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Aucun utilisateur connecté.');
    }

    final familyId = await getCurrentFamilyId();
    if (familyId == null) {
      throw Exception('Aucune famille active.');
    }

    final familyRef = _familyDoc(familyId);
    final familyBudgetRef = _familyBudgetDoc(familyId);
    final currentUserRef = _userDoc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final familySnapshot = await transaction.get(familyRef);

      if (!familySnapshot.exists) {
        transaction.set(
          currentUserRef,
          {
            _familyIdField: FieldValue.delete(),
            _updatedAtField: FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        return;
      }

      final familyData = familySnapshot.data() ?? <String, dynamic>{};
      final ownerUid = familyData[_ownerUidField];

      if (ownerUid != user.uid) {
        throw Exception('Seul le propriétaire peut dissoudre la famille.');
      }

      final uniqueMembers = _normalizedMembersIncludingOwner(
        membersValue: familyData[_membersField],
        ownerUidValue: ownerUid,
      );

      for (final memberUid in uniqueMembers) {
        transaction.set(
          _userDoc(memberUid),
          {
            _familyIdField: FieldValue.delete(),
            _updatedAtField: FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      transaction.delete(familyBudgetRef);
      transaction.delete(familyRef);
    });
  }

  Future<void> createFamily({
    String? familyName,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Aucun utilisateur connecté.');
    }

    final normalizedFamilyName = familyName?.trim();
    final familyRef = _firestore.collection(_familiesCollection).doc();
    final userRef = _userDoc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentFamilyId =
          _normalizeFamilyId(userSnapshot.data()?[_familyIdField]);

      if (currentFamilyId != null) {
        return;
      }

      transaction.set(
        familyRef,
        {
          _ownerUidField: user.uid,
          _membersField: [user.uid],
          _createdAtField: FieldValue.serverTimestamp(),
          _updatedAtField: FieldValue.serverTimestamp(),
          if (normalizedFamilyName != null && normalizedFamilyName.isNotEmpty)
            _nameField: normalizedFamilyName,
        },
      );

      transaction.set(
        userRef,
        {
          _familyIdField: familyRef.id,
          _updatedAtField: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<void> joinFamily(String familyId) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Aucun utilisateur connecté.');
    }

    final normalizedFamilyId = familyId.trim();
    if (normalizedFamilyId.isEmpty) {
      throw Exception('Identifiant famille invalide.');
    }

    final familyRef = _familyDoc(normalizedFamilyId);
    final userRef = _userDoc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentFamilyId =
          _normalizeFamilyId(userSnapshot.data()?[_familyIdField]);

      if (currentFamilyId == normalizedFamilyId) {
        return;
      }

      if (currentFamilyId != null && currentFamilyId != normalizedFamilyId) {
        throw Exception(
          'Tu appartiens déjà à une autre famille. Quitte-la avant d’en rejoindre une nouvelle.',
        );
      }

      final familySnapshot = await transaction.get(familyRef);

      if (!familySnapshot.exists) {
        throw Exception('Famille introuvable.');
      }

      transaction.set(
        familyRef,
        {
          _membersField: FieldValue.arrayUnion([user.uid]),
          _updatedAtField: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      transaction.set(
        userRef,
        {
          _familyIdField: normalizedFamilyId,
          _updatedAtField: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<void> leaveFamily({
    bool copyFamilyBudgetToPersonal = false,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Aucun utilisateur connecté.');
    }

    final familyId = await getCurrentFamilyId();
    if (familyId == null) {
      return;
    }

    final familyRef = _familyDoc(familyId);
    final familyBudgetRef = _familyBudgetDoc(familyId);
    final personalBudgetRef = _personalBudgetDoc(user.uid);
    final userRef = _userDoc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentFamilyId =
          _normalizeFamilyId(userSnapshot.data()?[_familyIdField]);

      if (currentFamilyId == null) {
        return;
      }

      if (currentFamilyId != familyId) {
        throw Exception(
          'La famille active a changé. Réessaie l’opération.',
        );
      }

      final familySnapshot = await transaction.get(familyRef);

      if (!familySnapshot.exists) {
        transaction.set(
          personalBudgetRef,
          {
            _familyIdField: FieldValue.delete(),
            _updatedAtField: FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        return;
      }

      final familyData = familySnapshot.data() ?? <String, dynamic>{};
      final ownerUid = familyData[_ownerUidField];

      if (ownerUid == user.uid) {
        throw Exception(
          'Le propriétaire de la famille ne peut pas quitter sans transférer ou supprimer la famille.',
        );
      }

      Map<String, dynamic>? familyBudgetPayload;
      int? familyBudgetRevision;
      String? familyBudgetUpdatedBy;

      if (copyFamilyBudgetToPersonal) {
        final familyBudgetSnapshot = await transaction.get(familyBudgetRef);
        final familyBudgetData = familyBudgetSnapshot.data();

        final rawFamilyBudget = familyBudgetData?[_dataField];
        if (rawFamilyBudget is Map<String, dynamic>) {
          familyBudgetPayload = Map<String, dynamic>.from(rawFamilyBudget);
          familyBudgetRevision = _readRevisionFromPayload(familyBudgetData);
          familyBudgetUpdatedBy =
              _normalizeUid(familyBudgetData?[_updatedByField]);
        }
      }

      transaction.set(
        familyRef,
        {
          _membersField: FieldValue.arrayRemove([user.uid]),
          _updatedAtField: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      transaction.set(
        personalBudgetRef,
        {
          _familyIdField: FieldValue.delete(),
          _updatedAtField: FieldValue.serverTimestamp(),
          if (familyBudgetPayload != null) _dataField: familyBudgetPayload,
          if (familyBudgetRevision != null)
            _revisionField: familyBudgetRevision,
          if (familyBudgetUpdatedBy != null)
            _updatedByField: familyBudgetUpdatedBy,
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<DocumentReference<Map<String, dynamic>>> _resolveBudgetDoc() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Aucun utilisateur connecté.');
    }

    final familyId = await getCurrentFamilyId();
    if (familyId != null) {
      return _familyBudgetDoc(familyId);
    }

    return _personalBudgetDoc(user.uid);
  }

  Future<BudgetDocumentSnapshotData> _readBudgetSnapshotFromDoc({
    required DocumentReference<Map<String, dynamic>> docRef,
    required bool isFamilyBudget,
  }) async {
    final snapshot = await docRef.get();
    return _buildBudgetSnapshotData(
      payload: snapshot.data(),
      isFamilyBudget: isFamilyBudget,
      documentPath: docRef.path,
    );
  }

  Future<BudgetDocumentSnapshotData> loadBudgetSnapshot() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Aucun utilisateur connecté.');
    }

    final familyId = await getCurrentFamilyId();

    if (familyId != null) {
      final familySnapshot = await _readBudgetSnapshotFromDoc(
        docRef: _familyBudgetDoc(familyId),
        isFamilyBudget: true,
      );

      if (familySnapshot.budget != null) {
        return familySnapshot;
      }
    }

    return _readBudgetSnapshotFromDoc(
      docRef: _personalBudgetDoc(user.uid),
      isFamilyBudget: false,
    );
  }

  Future<AppBudgetData?> loadBudget() async {
    final snapshot = await loadBudgetSnapshot();
    return snapshot.budget;
  }

  Future<void> saveBudget(AppBudgetData appBudget) async {
    final user = currentUser;
    if (user == null) return;

    final targetDoc = await _resolveBudgetDoc();

    await _firestore.runTransaction((transaction) async {
      final currentSnapshot = await transaction.get(targetDoc);
      final currentData = currentSnapshot.data();
      final currentRevision = _readRevisionFromPayload(currentData);
      final nextRevision = currentRevision + 1;

      transaction.set(
        targetDoc,
        {
          _updatedAtField: FieldValue.serverTimestamp(),
          _updatedByField: user.uid,
          _revisionField: nextRevision,
          _dataField: appBudget.toJson(),
        },
        SetOptions(merge: true),
      );

      transaction.set(
        _userDoc(user.uid),
        {
          _updatedAtField: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<void> saveBudgetWithRevisionCheck(
    AppBudgetData appBudget, {
    required int expectedRevision,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Aucun utilisateur connecté.');
    }

    final targetDoc = await _resolveBudgetDoc();

    await _firestore.runTransaction((transaction) async {
      final currentSnapshot = await transaction.get(targetDoc);
      final currentData = currentSnapshot.data();
      final actualRevision = _readRevisionFromPayload(currentData);

      if (actualRevision != expectedRevision) {
        throw BudgetSaveConflictException(
          expectedRevision: expectedRevision,
          actualRevision: actualRevision,
        );
      }

      final nextRevision = actualRevision + 1;

      transaction.set(
        targetDoc,
        {
          _updatedAtField: FieldValue.serverTimestamp(),
          _updatedByField: user.uid,
          _revisionField: nextRevision,
          _dataField: appBudget.toJson(),
        },
        SetOptions(merge: true),
      );

      transaction.set(
        _userDoc(user.uid),
        {
          _updatedAtField: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Stream<BudgetDocumentSnapshotData> watchBudgetSnapshot() {
    final user = currentUser;
    if (user == null) {
      return const Stream<BudgetDocumentSnapshotData>.empty();
    }

    final controller = StreamController<BudgetDocumentSnapshotData>();
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? userSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? budgetSub;

    Future<void> bindBudgetStream(String? familyId) async {
      await budgetSub?.cancel();

      final bool isFamilyBudget = familyId != null;
      final DocumentReference<Map<String, dynamic>> targetDoc = isFamilyBudget
          ? _familyBudgetDoc(familyId)
          : _personalBudgetDoc(user.uid);

      budgetSub = targetDoc.snapshots().listen(
        (snapshot) async {
          if (isFamilyBudget) {
            final familySnapshot = _buildBudgetSnapshotData(
              payload: snapshot.data(),
              isFamilyBudget: true,
              documentPath: targetDoc.path,
            );

            if (familySnapshot.budget != null) {
              controller.add(familySnapshot);
              return;
            }

            try {
              final personalSnapshot = await _readBudgetSnapshotFromDoc(
                docRef: _personalBudgetDoc(user.uid),
                isFamilyBudget: false,
              );
              controller.add(personalSnapshot);
            } catch (e, st) {
              controller.addError(e, st);
            }
            return;
          }

          controller.add(
            _buildBudgetSnapshotData(
              payload: snapshot.data(),
              isFamilyBudget: false,
              documentPath: targetDoc.path,
            ),
          );
        },
        onError: controller.addError,
      );
    }

    userSub = _userDoc(user.uid).snapshots().listen(
      (userSnapshot) async {
        final familyId =
            _normalizeFamilyId(userSnapshot.data()?[_familyIdField]);
        try {
          await bindBudgetStream(familyId);
        } catch (e, st) {
          controller.addError(e, st);
        }
      },
      onError: controller.addError,
    );

    controller.onCancel = () async {
      await budgetSub?.cancel();
      await userSub?.cancel();
    };

    return controller.stream;
  }

  Stream<AppBudgetData?> watchBudget() {
    return watchBudgetSnapshot().map((snapshot) => snapshot.budget);
  }
}
