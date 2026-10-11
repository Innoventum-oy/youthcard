import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:youth_card/l10n/app_localizations.dart';
import 'package:youth_card/src/providers/user_provider.dart';
import 'package:youth_card/src/util/local_storage.dart';
import 'package:youth_card/src/util/shared_preference.dart';
import 'package:youth_card/src/views/settings/environment.dart';
import 'package:youth_card/src/views/webpagetextcontent.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((package) {
      if (mounted) setState(() => _version = '${package.appName} ${package.version} (${package.buildNumber})');
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final signedIn = context.watch<UserProvider>().user.token != null;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(strings.youthcardSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(context, strings.settingsCommon, [
            _tile(Icons.cloud_outlined, strings.environment, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => EnvironmentScreen(wrap: true)));
            }),
          ]),
          if (signedIn) _section(context, strings.settingsAccount, [
            _tile(Icons.phone_outlined, strings.contactInformation, () => Navigator.pushNamed(context, '/contactmethods')),
            _tile(Icons.person_outline, strings.userInformation, () => Navigator.pushNamed(context, '/userform')),
            _tile(Icons.logout, strings.logout, () async {
              await UserPreferences().removeUser();
              if (!context.mounted) return;
              context.read<UserProvider>().clearUser();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            }),
          ]),
          _section(context, strings.settingsMisc, [
            _tile(Icons.description_outlined, strings.termsOfService, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentPageView('privacy-policy')));
            }),
            _tile(Icons.cleaning_services_outlined, strings.clearCache, () async {
              await getFileStorage().clear();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.clearCache)));
            }),
            _tile(Icons.auto_awesome_outlined, strings.showWelcomeScreen,
                () => Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false)),
          ]),
          const SizedBox(height: 20),
          Center(child: Text(_version, style: TextStyle(color: colors.onSurfaceVariant))),
          const SizedBox(height: 20),
          Row(children: [
            Image.asset('images/erasmusplus.png', height: 36),
            const SizedBox(width: 12),
            Expanded(child: Text(strings.erasmusDisclaimer, style: Theme.of(context).textTheme.bodySmall)),
          ]),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> tiles) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Card(clipBehavior: Clip.antiAlias, child: Column(children: tiles)),
      ]),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
