import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:WalkeRoo/data_fetching/user_service.dart';
import 'package:WalkeRoo/global_widgets/custom_navigation_bar.dart';
import 'package:WalkeRoo/models/user_model.dart';
import 'package:WalkeRoo/singletons/active_user_singleton.dart';
import 'package:WalkeRoo/enums/user_motivation_enum.dart';
import 'package:WalkeRoo/storage/local_user_storage.dart';
import 'package:WalkeRoo/pages/auth/auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, UserService? userService, UserModel? initialUser})
    : _userService = userService,
      _initialUser = initialUser;

  final UserService? _userService;
  final UserModel? _initialUser;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const double fieldHeight = 56;

  late UserModel _user;
  late TextEditingController _nameC;
  late TextEditingController _aboutC;
  late DateTime _birthDate;
  UserMotivation? _motivation;
  late final UserService _userService;

  @override
  void initState() {
    super.initState();

    _userService = widget._userService ?? UserService();
    _user = widget._initialUser ?? ActiveUserSingleton().activeUser!;

    _nameC = TextEditingController(text: _user.name);
    _aboutC = TextEditingController(text: _user.aboutMe);
    _birthDate = _user.age;
    _motivation = _user.userMotivation;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _aboutC.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  InputDecoration _pillDec() => const InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none),
  );

  Widget _card(Widget child) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: child,
  );

  Future<void> _save() async {
    final updated = UserModel(
      username: _user.username,
      email: _user.email,
      name: _nameC.text.trim(),
      aboutMe: _aboutC.text.trim(),
      friends: _user.friends,
      age: _birthDate,
      creationTime: _user.creationTime,
      userMotivation: _motivation ?? UserMotivation.other,
      totalSteps: _user.totalSteps,
    );

    await _userService.updateUserData({
      'name': updated.name,
      'aboutMe': updated.aboutMe,
      'age': updated.age,
      'userMotivation': (updated.userMotivation ?? UserMotivation.other).name,
    });

    ActiveUserSingleton().activeUser = updated;
    _user = updated;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  Future<void> _logout() async {
    ActiveUserSingleton().clearUser();
    await _userService.logout();
    await LocalUserStorage.deleteUser();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthPage()), (route) => false);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final minDate = DateTime(1900, 1, 1);
    final maxDate = DateTime(now.year - 18, now.month, now.day);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.45,
            minChildSize: 0.3,
            maxChildSize: 0.7,
            builder:
                (c, scrollController) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      const Text('Select birth date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: _birthDate.isAfter(maxDate) ? maxDate : _birthDate,
                          minimumDate: minDate,
                          maximumDate: maxDate,
                          onDateTimeChanged: (d) => setState(() => _birthDate = d),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> _showMotivationPicker() async {
    final picked = await showModalBottomSheet<UserMotivation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (c, scrollController) => SafeArea(
                  top: false,
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    itemCount: UserMotivation.values.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final m = UserMotivation.values[i];
                      final selected = _motivation == m;
                      return ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        title: Text(m.model.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                        subtitle: Text(m.model.description),
                        trailing: selected ? const Icon(Icons.check, color: Color(0xFF123456)) : null,
                        onTap: () => Navigator.of(context).pop(m),
                      );
                    },
                  ),
                ),
          ),
    );

    if (picked != null) {
      setState(() => _motivation = picked);
    }
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Text(
            '@${_user.username}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
        ),
        Positioned(
          right: 0,
          child: IconButton.filled(
            onPressed: _logout,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFDADADA),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.logout, size: 25),
          ),
        ),
      ],
    ),
  );

  Widget _nameField() => _card(
    SizedBox(
      height: fieldHeight,
      child: TextField(controller: _nameC, textAlign: TextAlign.center, decoration: _pillDec()),
    ),
  );

  Widget _ageFriendsRow() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: const [
          Expanded(flex: 7, child: Text('Age', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          SizedBox(width: 24),
          Expanded(flex: 6, child: Text('Friends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 7,
            child: GestureDetector(
              onTap: _pickBirthDate,
              child: AbsorbPointer(
                child: _card(
                  SizedBox(
                    height: fieldHeight,
                    child: TextField(
                      controller: TextEditingController(text: _fmtDate(_birthDate)),
                      decoration: _pillDec(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 6,
            child: Container(
              height: fieldHeight + 12,
              alignment: Alignment.centerLeft,
              child: Text('${_user.friends.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _motivationSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Motivation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      InkWell(
        onTap: _showMotivationPicker,
        borderRadius: BorderRadius.circular(16),
        child: _card(
          SizedBox(
            height: fieldHeight,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _motivation?.model.description ?? 'Select...',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _aboutSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Me', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      _card(TextField(controller: _aboutC, maxLines: 5, decoration: _pillDec())),
    ],
  );

  Widget _sinceText() => Text(
    'WalkeRooner since ${_fmtDate(_user.creationTime)}',
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 16, color: Colors.black54),
  );

  Widget _saveButton() => SizedBox(
    height: 56,
    child: ElevatedButton(
      onPressed: _save,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF123456),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 18)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavigationBar(initialIndexOfScreen: 4),
      backgroundColor: const Color(0xFFDADADA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              _nameField(),
              const SizedBox(height: 22),
              _ageFriendsRow(),
              const SizedBox(height: 24),
              _motivationSection(),
              const SizedBox(height: 24),
              _aboutSection(),
              const SizedBox(height: 20),
              _sinceText(),
              const SizedBox(height: 22),
              _saveButton(),
            ],
          ),
        ),
      ),
    );
  }
}
