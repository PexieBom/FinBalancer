/// Status veze host–guest.
enum AccountLinkStatus {
  pending,
  accepted,
  revoked;

  static AccountLinkStatus fromJson(dynamic value) {
    if (value == null) return AccountLinkStatus.pending;
    if (value is int) {
      switch (value) {
        case 1: return AccountLinkStatus.accepted;
        case 2: return AccountLinkStatus.revoked;
        default: return AccountLinkStatus.pending;
      }
    }
    final s = value.toString().toLowerCase();
    switch (s) {
      case 'pending': return AccountLinkStatus.pending;
      case 'accepted': return AccountLinkStatus.accepted;
      case 'revoked': return AccountLinkStatus.revoked;
      default: return AccountLinkStatus.pending;
    }
  }
}

/// Jedna veza (kao host ili guest) za listu.
class AccountLinkItem {
  final String id;
  final String hostUserId;
  final String guestUserId;
  final AccountLinkStatus status;
  final DateTime invitedAt;
  final DateTime? respondedAt;
  final bool isCurrentUserHost;
  final String otherUserId;
  final String otherDisplayName;
  final String? otherEmail;

  AccountLinkItem({
    required this.id,
    required this.hostUserId,
    required this.guestUserId,
    required this.status,
    required this.invitedAt,
    this.respondedAt,
    required this.isCurrentUserHost,
    required this.otherUserId,
    required this.otherDisplayName,
    this.otherEmail,
  });

  factory AccountLinkItem.fromJson(Map<String, dynamic> json) {
    return AccountLinkItem(
      id: json['id'] as String,
      hostUserId: json['hostUserId'] as String,
      guestUserId: json['guestUserId'] as String,
      status: AccountLinkStatus.fromJson(json['status']),
      invitedAt: DateTime.parse(json['invitedAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
      isCurrentUserHost: json['isCurrentUserHost'] as bool? ?? false,
      otherUserId: json['otherUserId'] as String,
      otherDisplayName: json['otherDisplayName'] as String? ?? '?',
      otherEmail: json['otherEmail'] as String?,
    );
  }
}

/// Host čije podatke mogu pregledavati (kao guest).
class LinkedHost {
  final String hostUserId;
  final String displayName;
  final String? email;
  final DateTime linkedAt;

  LinkedHost({
    required this.hostUserId,
    required this.displayName,
    this.email,
    required this.linkedAt,
  });

  factory LinkedHost.fromJson(Map<String, dynamic> json) {
    return LinkedHost(
      hostUserId: json['hostUserId'] as String,
      displayName: json['displayName'] as String? ?? '?',
      email: json['email'] as String?,
      linkedAt: DateTime.parse(json['linkedAt'] as String),
    );
  }
}
