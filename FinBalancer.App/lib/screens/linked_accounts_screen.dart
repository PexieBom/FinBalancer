import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/account_link.dart';
import '../providers/linked_account_provider.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notifications_icon.dart';

/// Ekran za upravljanje povezanim računima: pozivanje po emailu, lista veza, prihvaćanje/opozivanje.
class LinkedAccountsScreen extends StatefulWidget {
  const LinkedAccountsScreen({super.key});

  @override
  State<LinkedAccountsScreen> createState() => _LinkedAccountsScreenState();
}

class _LinkedAccountsScreenState extends State<LinkedAccountsScreen> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<LinkedAccountProvider>();
      final notifications = await provider.loadLinks();
      context.read<NotificationsProvider>().loadUnreadCount();
      if (!mounted) return;
      for (final n in notifications) {
        final msg = n.accepted
            ? _notificationAccepted(n.otherName)
            : _notificationDeclined(n.otherName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
        );
        await Future.delayed(const Duration(milliseconds: 400));
      }
      if (notifications.isNotEmpty && mounted) {
        await provider.acknowledgeLinkNotifications(
          notifications.map((n) => n.linkId).toList(),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          _title(context),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [NotificationsIcon()],
      ),
      body: Consumer<LinkedAccountProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.links.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInviteSection(context, provider),
                const SizedBox(height: 24),
                _buildSectionTitle(context, _linksTitle(context)),
                const SizedBox(height: 8),
                if (provider.error != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      provider.error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
                if (provider.links.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        _noLinks(context),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ...provider.links.map((link) => _buildLinkTile(context, provider, link)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInviteSection(BuildContext context, LinkedAccountProvider provider) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark ? Colors.black54 : AppTheme.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _inviteTitle(context),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _inviteSubtitle(context),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: _emailLabel(context),
              border: const OutlineInputBorder(),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: provider.isLoading
                ? null
                : () async {
                    final email = _emailController.text.trim();
                    if (email.isEmpty) return;
                    final errorCode = await provider.inviteByEmail(email);
                    if (!mounted) return;
                    if (errorCode == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_inviteSent(context))),
                      );
                      _emailController.clear();
                    } else {
                      final msg = _errorMessageForCode(context, errorCode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg), backgroundColor: theme.colorScheme.error),
                      );
                    }
                  },
            icon: const Icon(Icons.person_add),
            label: Text(_inviteButton(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(BuildContext context, LinkedAccountProvider provider, AccountLinkItem link) {
    final theme = Theme.of(context);
    final statusText = _statusText(context, link.status);
    final roleText = link.isCurrentUserHost ? _youInvited(context) : _youInvitedBy(context);
    final canReinvite = link.status == AccountLinkStatus.revoked && link.isCurrentUserHost && (link.otherEmail ?? '').isNotEmpty;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(link.otherDisplayName),
        subtitle: Text('${link.otherEmail ?? ''} · $roleText · $statusText'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canReinvite)
              TextButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final email = link.otherEmail!.trim();
                        final errorCode = await provider.inviteByEmail(email);
                        if (!mounted) return;
                        if (errorCode == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_inviteSent(context))),
                          );
                        } else {
                          final msg = _errorMessageForCode(context, errorCode);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg), backgroundColor: theme.colorScheme.error),
                          );
                        }
                      },
                child: Text(_reinvite(context)),
              ),
            if (link.status == AccountLinkStatus.pending && !link.isCurrentUserHost)
              TextButton(
                onPressed: () async {
                  final ok = await provider.acceptInvite(link.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? _accepted(context) : _failed(context))),
                    );
                  }
                },
                child: Text(_accept(context)),
              )
            else if (link.status != AccountLinkStatus.revoked)
              IconButton(
                icon: const Icon(Icons.link_off),
                onPressed: () async {
                  final ok = await provider.revokeLink(link.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? _revoked(context) : _failed(context))),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  String _title(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'hr': return 'Povezani računi';
      case 'de': return 'Verbundene Konten';
      default: return 'Linked accounts';
    }
  }

  String _inviteTitle(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'hr': return 'Pozovi korisnika';
      case 'de': return 'Benutzer einladen';
      default: return 'Invite user';
    }
  }

  String _inviteSubtitle(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'hr': return 'Unesi email osobe koja ima FinBalancer. Ona će moći pregledavati tvoje podatke.';
      case 'de': return 'E-Mail eingeben. Die Person kann deine Daten einsehen.';
      default: return 'Enter email of someone who has FinBalancer. They will be able to view your data.';
    }
  }

  String _emailLabel(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'hr': return 'Email';
      default: return 'Email';
    }
  }

  String _inviteButton(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'hr': return 'Pošalji pozivnicu';
      case 'de': return 'Einladung senden';
      default: return 'Send invite';
    }
  }

  String _inviteSent(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'hr': return 'Pozivnica poslana.';
      default: return 'Invite sent.';
    }
  }

  String _linksTitle(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'hr': return 'Tvoje veze';
      case 'de': return 'Deine Verbindungen';
      default: return 'Your links';
    }
  }

  String _noLinks(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'hr': return 'Nema povezanih računa. Pošalji pozivnicu po emailu.';
      default: return 'No linked accounts. Send an invite by email.';
    }
  }

  String _statusText(BuildContext context, AccountLinkStatus status) {
    switch (status) {
      case AccountLinkStatus.pending:
        return Localizations.localeOf(context).languageCode == 'hr' ? 'Na čekanju' : 'Pending';
      case AccountLinkStatus.accepted:
        return Localizations.localeOf(context).languageCode == 'hr' ? 'Prihvaćeno' : 'Accepted';
      case AccountLinkStatus.revoked:
        return Localizations.localeOf(context).languageCode == 'hr' ? 'Opozvano' : 'Revoked';
    }
  }

  String _youInvited(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'hr' ? 'Ti si pozvao/la' : 'You invited';
  }

  String _youInvitedBy(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'hr' ? 'Pozvan/a si' : 'You were invited';
  }

  String _accept(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'hr' ? 'Prihvati' : 'Accept';
  }

  String _accepted(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'hr' ? 'Pozivnica prihvaćena.' : 'Invite accepted.';
  }

  String _revoked(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'hr' ? 'Veza opozvana.' : 'Link revoked.';
  }

  String _failed(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'hr' ? 'Greška.' : 'Failed.';
  }

  String _errorMessageForCode(BuildContext context, String code) {
    switch (code) {
      case 'GuestNotFound':
        return Localizations.localeOf(context).languageCode == 'hr'
            ? 'Korisnik s tim emailom nije pronađen.'
            : 'User with that email not found.';
      case 'AlreadyLinked':
        return Localizations.localeOf(context).languageCode == 'hr'
            ? 'Račun je već povezan.'
            : 'Account already linked.';
      case 'AlreadyPending':
        return Localizations.localeOf(context).languageCode == 'hr'
            ? 'Pozivnica je već poslana.'
            : 'Invite already sent.';
      case 'RevokedPreviously':
        return Localizations.localeOf(context).languageCode == 'hr'
            ? 'API trenutno ne dopušta ponovno pozivanje. Pokušaj kasnije.'
            : 'API does not allow re-invite yet. Try again later.';
      case 'CannotInviteSelf':
        return Localizations.localeOf(context).languageCode == 'hr'
            ? 'Ne možeš pozvati sam sebe.'
            : 'You cannot invite yourself.';
      default:
        return code;
    }
  }

  String _reinvite(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'hr' ? 'Ponovno pozovi' : 'Re-invite';
  }

  String _notificationAccepted(String name) {
    return Localizations.localeOf(context).languageCode == 'hr'
        ? '$name je prihvatio/la tvoju pozivnicu.'
        : '$name accepted your invite.';
  }

  String _notificationDeclined(String name) {
    return Localizations.localeOf(context).languageCode == 'hr'
        ? '$name je odbio/la tvoju pozivnicu.'
        : '$name declined your invite.';
  }
}
