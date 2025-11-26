import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/patient_scaffold.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      _fullNameController.text = user.fullName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final success = await authProvider.updateProfile(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileUpdatedSuccessfully),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(authProvider.errorMessage ?? 'Failed to update profile'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _enableMfa(BuildContext context, AuthProvider authProvider) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.enableTwoFactorAuthentication),
        content: Text(l10n.enable2FAInstructions),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.continueButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Start MFA enrollment
    final result = await authProvider.enableMfa();
    
    if (result['success'] == true && mounted) {
      // Show dialog to enter verification code
      final codeController = TextEditingController();
      final verified = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.verifyEmailCode),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.enterVerificationCode),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: l10n.verificationCode,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.verify),
          ),
          ],
        ),
      );

      if (verified == true && codeController.text.isNotEmpty) {
        final success = await authProvider.verifyMfaEnrollment(
          factorId: result['factorId'],
          code: codeController.text,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.twoFactorEnabledSuccessfully),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.errorMessage ?? 'Failed to verify code',
              ),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to enable MFA'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _disableMfa(BuildContext context, AuthProvider authProvider) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.disableTwoFactorAuthentication),
        content: Text(l10n.disable2FAConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text(l10n.disable),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await authProvider.disableMfa();
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.twoFactorDisabledSuccessfully),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Failed to disable MFA',
            ),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.areYouSureLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      if (context.mounted) {
        context.go('/sign-in');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PatientScaffold(
      title: l10n.settings,
      currentRoute: '/patient/settings',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.accountDetails,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!_isEditing)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                              icon: const Icon(Icons.edit),
                              label: Text(l10n.edit),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = false;
                                      _loadUserData();
                                    });
                                  },
                                  child: Text(l10n.cancel),
                                ),
                                ElevatedButton(
                                  onPressed: _isSaving ? null : _saveProfile,
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : Text(l10n.save),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: l10n.fullName,
                          border: const OutlineInputBorder(),
                        ),
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: l10n.email,
                          border: const OutlineInputBorder(),
                        ),
                        enabled: _isEditing,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: l10n.phoneNumber,
                          border: const OutlineInputBorder(),
                        ),
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.usabilitySettings,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<SettingsProvider>(
                        builder: (context, settingsProvider, child) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text(l10n.darkMode),
                                trailing: Switch(
                                  value: settingsProvider.isDarkMode,
                                  onChanged: (value) {
                                    settingsProvider.setDarkMode(value);
                                  },
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(l10n.fontSize),
                                subtitle: Slider(
                                  value: settingsProvider.fontSize,
                                  min: 12,
                                  max: 24,
                                  divisions: 12,
                                  label: '${settingsProvider.fontSize.toInt()}',
                                  onChanged: (value) {
                                    settingsProvider.setFontSize(value);
                                  },
                                ),
                                trailing: Text(
                                  '${settingsProvider.fontSize.toInt()}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                title: Text(l10n.language),
                                subtitle:
                                    Text(settingsProvider.getLanguageName()),
                                trailing: DropdownButton<Locale>(
                                  value: settingsProvider.locale,
                                  items: [
                                    DropdownMenuItem(
                                      value: const Locale('en'),
                                      child: Text(l10n.english),
                                    ),
                                    DropdownMenuItem(
                                      value: const Locale('sw'),
                                      child: Text(l10n.swahili),
                                    ),
                                  ],
                                  onChanged: (Locale? newLocale) {
                                    if (newLocale != null) {
                                      settingsProvider.setLanguage(newLocale);
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.security,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text(l10n.twoFactorAuthentication),
                                subtitle: Text(
                                  authProvider.isMfaEnabled == true
                                      ? l10n.twoFactorEnabled
                                      : l10n.twoFactorDisabled,
                                ),
                                trailing: authProvider.isMfaLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Switch(
                                        value: authProvider.isMfaEnabled ?? false,
                                        onChanged: (value) async {
                                          if (value) {
                                            await _enableMfa(context, authProvider);
                                          } else {
                                            await _disableMfa(context, authProvider);
                                          }
                                        },
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.accountActions,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading:
                            const Icon(Icons.logout, color: AppTheme.errorRed),
                        title: Text(
                          l10n.logout,
                          style: const TextStyle(color: AppTheme.errorRed),
                        ),
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
