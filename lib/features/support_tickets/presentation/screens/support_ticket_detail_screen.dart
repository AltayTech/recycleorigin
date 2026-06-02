import 'package:flutter/material.dart';
import 'package:recycleorigin/core/network/api_client.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/support_tickets/data/support_ticket_models.dart';
import 'package:recycleorigin/features/support_tickets/data/support_ticket_repository.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Conversation view for a single ticket (read + reply if open).
class SupportTicketDetailScreen extends StatefulWidget {
  const SupportTicketDetailScreen({super.key});

  static const routeName = '/supportTicketDetail';

  @override
  State<SupportTicketDetailScreen> createState() =>
      _SupportTicketDetailScreenState();
}

class _SupportTicketDetailScreenState extends State<SupportTicketDetailScreen> {
  final SupportTicketRepository _repo = SupportTicketRepository(ApiClient());
  String? _ticketId;
  SupportTicket? _ticket;
  List<SupportTicketMessage> _messages = <SupportTicketMessage>[];
  final _reply = TextEditingController();
  bool _loading = true;
  String? _error;
  bool _sending = false;
  bool _startedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ticketId ??= ModalRoute.of(context)?.settings.arguments as String?;
    if (!_startedLoad && _ticketId != null) {
      _startedLoad = true;
      _load();
    }
  }

  Future<void> _load() async {
    final id = _ticketId;
    if (id == null) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final t = await _repo.getTicket(id);
    final m = await _repo.listMessages(id);
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      if (t case Success(:final value)) {
        _ticket = value;
      } else if (t case Failure(:final message)) {
        _error = message;
      }
      if (m case Success(:final value)) {
        _messages = value.items;
      }
    });
  }

  bool get _canReply {
    final s = _ticket?.status ?? '';
    return s != 'closed';
  }

  Future<void> _send() async {
    final text = _reply.text.trim();
    final id = _ticketId;
    if (text.isEmpty || id == null) {
      return;
    }
    setState(() => _sending = true);
    final r = await _repo.postMessage(id, text);
    if (!mounted) {
      return;
    }
    setState(() => _sending = false);
    switch (r) {
      case Success(:final value):
        _reply.clear();
        setState(() => _messages = <SupportTicketMessage>[..._messages, value]);
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.messageReplyAppBarTitle,
          style: TextStyle(color: context.appColors.scaffoldBackground),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : () => _load(),
            icon: Icon(Icons.refresh, color: AppTheme.appBarIconColor),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    if (_ticket != null) _HeaderCard(ticket: _ticket!),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          return _Bubble(message: _messages[i]);
                        },
                      ),
                    ),
                    if (_canReply)
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _reply,
                                  minLines: 1,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    hintText: l10n.messageReplyHint,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: _sending ? null : _send,
                                icon: _sending
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(Icons.send),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Material(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ticket.subject,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${ticket.ticketNumber} · ${ticket.status}',
                style: theme.textTheme.bodySmall?.copyWith(color: context.appColors.subtitleColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final SupportTicketMessage message;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.isFromUser;
    final align = fromUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = fromUser
        ? AppTheme.primary.withValues(alpha: 0.15)
        : context.appColors.subtitleColor.withValues(alpha: 0.12);
    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.appColors.subtitleColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final local = t.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
