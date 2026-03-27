import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _initialized = false;
  bool _saving = false;

  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;

  bool _contributionAlerts = true;
  bool _loanReminders = true;
  bool _groupUpdates = true;
  bool _securityAlerts = true;
  bool _promotionalAlerts = false;

  bool _quietHoursEnabled = true;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 7, minute: 0);

  NotificationFrequency _frequency = NotificationFrequency.instant;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final user = context.read<AuthProvider>().user;
    final settings = user?.notificationSettings;
    if (settings != null) {
      _applyStoredSettings(settings);
    }

    _initialized = true;
  }

  void _applyStoredSettings(Map<String, dynamic> settings) {
    final channels = _asMap(settings['channels']);
    final categories = _asMap(settings['categories']);
    final quietHours = _asMap(settings['quietHours']);

    _pushEnabled = channels['push'] as bool? ?? _pushEnabled;
    _emailEnabled = channels['email'] as bool? ?? _emailEnabled;
    _smsEnabled = channels['sms'] as bool? ?? _smsEnabled;

    _contributionAlerts =
        categories['contributionAlerts'] as bool? ?? _contributionAlerts;
    _loanReminders = categories['loanReminders'] as bool? ?? _loanReminders;
    _groupUpdates = categories['groupUpdates'] as bool? ?? _groupUpdates;
    _securityAlerts = categories['securityAlerts'] as bool? ?? _securityAlerts;
    _promotionalAlerts =
        categories['promotionalAlerts'] as bool? ?? _promotionalAlerts;

    _quietHoursEnabled = quietHours['enabled'] as bool? ?? _quietHoursEnabled;
    _quietStart = _parseTime(quietHours['start'] as String?) ?? _quietStart;
    _quietEnd = _parseTime(quietHours['end'] as String?) ?? _quietEnd;

    final frequencyValue = settings['frequency'] as String?;
    _frequency = NotificationFrequency.values.firstWhere(
      (f) => f.name == frequencyValue,
      orElse: () => _frequency,
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _quietStart : _quietEnd;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _quietStart = picked;
      } else {
        _quietEnd = picked;
      }
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _saving = true;
    });

    final payload = <String, dynamic>{
      'channels': {
        'push': _pushEnabled,
        'email': _emailEnabled,
        'sms': _smsEnabled,
      },
      'categories': {
        'contributionAlerts': _contributionAlerts,
        'loanReminders': _loanReminders,
        'groupUpdates': _groupUpdates,
        'securityAlerts': _securityAlerts,
        'promotionalAlerts': _promotionalAlerts,
      },
      'quietHours': {
        'enabled': _quietHoursEnabled,
        'start': _formatTime(_quietStart),
        'end': _formatTime(_quietEnd),
      },
      'frequency': _frequency.name,
    };

    final auth = context.read<AuthProvider>();
    final success = await auth.updateNotificationSettings(payload);

    if (!mounted) return;

    setState(() {
      _saving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Notification settings saved'
              : (auth.error ?? 'Could not save settings'),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Delivery Channels'),
            _buildCard(
              children: [
                _buildSwitchTile(
                  title: 'Push Notifications',
                  subtitle: 'Alerts on your phone and in app',
                  value: _pushEnabled,
                  onChanged: (value) => setState(() => _pushEnabled = value),
                ),
                _divider(),
                _buildSwitchTile(
                  title: 'Email Notifications',
                  subtitle: 'Receive updates by email',
                  value: _emailEnabled,
                  onChanged: (value) => setState(() => _emailEnabled = value),
                ),
                _divider(),
                _buildSwitchTile(
                  title: 'SMS Notifications',
                  subtitle: 'Critical updates by text message',
                  value: _smsEnabled,
                  onChanged: (value) => setState(() => _smsEnabled = value),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('What You Get Notified About'),
            _buildCard(
              children: [
                _buildSwitchTile(
                  title: 'Contribution Alerts',
                  subtitle: 'Due dates, received contributions, confirmations',
                  value: _contributionAlerts,
                  onChanged: (value) =>
                      setState(() => _contributionAlerts = value),
                ),
                _divider(),
                _buildSwitchTile(
                  title: 'Loan Reminders',
                  subtitle: 'Repayment schedules and missed reminders',
                  value: _loanReminders,
                  onChanged: (value) => setState(() => _loanReminders = value),
                ),
                _divider(),
                _buildSwitchTile(
                  title: 'Group Updates',
                  subtitle: 'New members, announcements, and changes',
                  value: _groupUpdates,
                  onChanged: (value) => setState(() => _groupUpdates = value),
                ),
                _divider(),
                _buildSwitchTile(
                  title: 'Security Alerts',
                  subtitle: 'Login activity and account protection notices',
                  value: _securityAlerts,
                  onChanged: (value) => setState(() => _securityAlerts = value),
                ),
                _divider(),
                _buildSwitchTile(
                  title: 'Promotions',
                  subtitle: 'Product news and optional offers',
                  value: _promotionalAlerts,
                  onChanged: (value) =>
                      setState(() => _promotionalAlerts = value),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Quiet Hours'),
            _buildCard(
              children: [
                _buildSwitchTile(
                  title: 'Enable Quiet Hours',
                  subtitle: 'Mute non-critical notifications overnight',
                  value: _quietHoursEnabled,
                  onChanged: (value) =>
                      setState(() => _quietHoursEnabled = value),
                ),
                if (_quietHoursEnabled) ...[
                  _divider(),
                  _buildTimeTile(
                    title: 'Start Time',
                    value: _quietStart.format(context),
                    onTap: () => _pickTime(isStart: true),
                  ),
                  _divider(),
                  _buildTimeTile(
                    title: 'End Time',
                    value: _quietEnd.format(context),
                    onTap: () => _pickTime(isStart: false),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Notification Frequency'),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<NotificationFrequency>(
                initialValue: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Send notifications',
                  border: OutlineInputBorder(),
                ),
                items: NotificationFrequency.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _frequency = value);
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Save Preferences',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
      indent: 14,
      endIndent: 14,
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry('$key', val));
    }
    return <String, dynamic>{};
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || !value.contains(':')) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

enum NotificationFrequency {
  instant('Instantly'),
  daily('Daily Digest'),
  weekly('Weekly Summary');

  const NotificationFrequency(this.label);
  final String label;
}
