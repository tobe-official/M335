import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:WalkeRoo/pages/profile_page/profile_page.dart';
import 'package:WalkeRoo/models/user_model.dart';
import 'package:WalkeRoo/enums/user_motivation_enum.dart';
import 'package:WalkeRoo/data_fetching/user_service.dart';
import 'package:mocktail/mocktail.dart';

class MockUserService extends Mock implements UserService {}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('ProfilePage snapshot with filled user', (tester) async {
    final user = UserModel(
      username: 'raphael',
      email: 'raphael@example.com',
      name: 'Raphael',
      age: DateTime(2008, 1, 1),
      friends: const ['friend1', 'friend2', 'friend3'],
      userMotivation: UserMotivation.hiking,
      aboutMe: 'Walking every day to stay sharp.',
      creationTime: DateTime(2024, 1, 1),
      totalSteps: 12345,
    );

    final mockService = MockUserService();

    final widgetUnderTest = MaterialApp(home: ProfilePage(initialUser: user, userService: mockService));

    await tester.pumpWidgetBuilder(widgetUnderTest, surfaceSize: const Size(430, 900));

    await screenMatchesGolden(tester, 'profile_page_snapshot');
  });
}
