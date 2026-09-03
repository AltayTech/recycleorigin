import 'package:flutter/material.dart';
import 'package:recycleorigin/core/network/api_provider.dart';
import 'package:recycleorigin/core/theme/app_theme.dart';
import 'package:recycleorigin/core/theme/theme_context_extensions.dart';
import 'package:recycleorigin/core/utils/result.dart';
import 'package:recycleorigin/features/support_tickets/data/support_ticket_repository.dart';
import 'package:recycleorigin/l10n/l10n.dart';

/// Creates a new support ticket (subject, category, description).
class SupportTicketCreateScreen extends StatefulWidget {
  const SupportTicketCreateScreen({super.key});

  static const routeName = '/supportTicketCreate';

  @override
  State<SupportTicketCreateScreen> createState() =>
      _SupportTicketCreateScreenState();
}

class _SupportTicketCreateScreenState extends State<SupportTicketCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _body = TextEditingController();
  final _trip = TextEditingController();
  String _category = 'general';
  bool _saving = false;

  static const Map<String, String> _categories = <String, String>{
    'general': 'General',
    'payment': 'Payment',
    'technical': 'Technical',
    'account': 'Account',
    'trip_issue': 'Collection / trip',
    'other': 'Other',
  };

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    _trip.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);
    final repo = SupportTicketRepository(ApiProvider.client);
    final trip = _trip.text.trim();
    final r = await repo.createTicket(
      subject: _subject.text.trim(),
      category: _category,
      description: _body.text.trim(),
      relatedTripId: trip.isEmpty ? null : trip,
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    switch (r) {
      case Success():
        Navigator.of(context).pop();
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: context.appColors.danger,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.newMessageScreenTitle,
          style: const TextStyle(color: AppTheme.appBarIconColor),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: IconThemeData(color: AppTheme.appBarIconColor),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.composeMessageIntroParagraph),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subject,
              decoration: InputDecoration(
                labelText: l10n.composeMessageTitleLabel,
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.length < 10) {
                  return 'Title must be at least 10 characters';
                }
                if (s.length > 200) {
                  return 'Title too long';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'general'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _body,
              minLines: 6,
              maxLines: 12,
              decoration: InputDecoration(
                labelText: l10n.composeMessageBodyHint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.length < 30) {
                  return 'Please describe the issue (min 30 characters)';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _trip,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Related request ID (optional)',
                border: OutlineInputBorder(),
                helperText: 'Link this ticket to a collection request',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.appColors.subtitleColor,
                      ),
                    )
                  : Text(l10n.newMessageScreenTitle),
            ),
          ],
        ),
      ),
    );
  }
}
