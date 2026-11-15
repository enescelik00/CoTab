import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/group.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import 'join_group_screen.dart';

// Lists the groups of the signed-in user.
class HomeScreen extends StatefulWidget {
  // Tests pass their own function that returns groups. Then the screen
  // uses it instead of SQLite and Firestore. In the app it is null.
  final Future<List<Group>> Function()? groupLoader;

  const HomeScreen({super.key, this.groupLoader});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Group> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThenRefresh();
  }

  // Shows the groups saved on the phone right away, then downloads the
  // latest data and shows the list again.
  Future<void> _loadThenRefresh() async {
    await _loadGroups();
    await _refreshGroups();
  }

  Future<void> _loadGroups() async {
    List<Group> groups;
    if (widget.groupLoader != null) {
      groups = await widget.groupLoader!();
    } else {
      groups = await GroupService.getMyGroups();
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _groups = groups;
      _isLoading = false;
    });
  }

  // Also used by pull-to-refresh.
  Future<void> _refreshGroups() async {
    if (widget.groupLoader == null) {
      await GroupService.refreshMyGroups();
    }
    await _loadGroups();
  }

  Future<void> _openCreateGroup() async {
    final Group? group = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    );
    if (group != null) {
      await _loadGroups();
    }
  }

  Future<void> _openJoinGroup() async {
    final Group? group = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinGroupScreen()),
    );
    if (group != null) {
      await _loadGroups();
    }
  }

  void _openGroup(Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupDetailScreen(group: group)),
    );
  }

  String _groupTypeText(AppLocalizations texts, String type) {
    if (type == 'trip') {
      return texts.groupTypeTrip;
    }
    return texts.groupTypeHome;
  }

  Widget _buildBody(AppLocalizations texts) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // A ListView is used in both cases, because pull-to-refresh only works
    // on a scrollable widget.
    if (_groups.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 120),
          Text(
            texts.homeWelcome,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(texts.homeNoGroups, textAlign: TextAlign.center),
        ],
      );
    }

    return ListView.builder(
      // Leaves room so the last group is not hidden behind the button.
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return ListTile(
          leading: Icon(group.type == 'trip' ? Icons.flight : Icons.home),
          title: Text(group.name),
          subtitle: Text(_groupTypeText(texts, group.type)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openGroup(group),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(texts.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: texts.joinGroupTitle,
            onPressed: _openJoinGroup,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: texts.signOutTooltip,
            // After signing out, the AuthGate shows the sign-in screen.
            onPressed: () => AuthService.signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGroups,
        child: _buildBody(texts),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateGroup,
        icon: const Icon(Icons.add),
        label: Text(texts.homeCreateGroup),
      ),
    );
  }
}
