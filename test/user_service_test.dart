import 'package:WalkeRoo/pages/profile_page/profile_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:WalkeRoo/models/user_model.dart';
import 'package:WalkeRoo/enums/user_motivation_enum.dart';
import 'package:WalkeRoo/data_fetching/user_service.dart';

class MockUserService extends Mock implements UserService {}

void main() {
  late MockUserService mockService;
  late UserModel baseUser;

  setUp(() {
    mockService = MockUserService();

    baseUser = UserModel(
      username: 'raphael',
      email: 'r@example.com',
      name: 'Raphael',
      age: DateTime(2000, 1, 1),
      friends: const [],
      userMotivation: UserMotivation.other,
      aboutMe: '',
      creationTime: DateTime(2024, 1, 1),
      totalSteps: 0,
    );

    when(() => mockService.updateUserData(any())).thenAnswer((_) async {});
    when(() => mockService.logout()).thenAnswer((_) async {});
  });

  testWidgets('test changes name and save changes', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfilePage(userService: mockService, initialUser: baseUser)));

    final nameField = find.byType(TextField).first;
    await tester.enterText(nameField, 'New Name');
    await tester.tap(find.text('Save'));
    await tester.pump();

    final captured = verify(() => mockService.updateUserData(captureAny())).captured.single as Map<String, dynamic>;
    expect(captured['name'], 'New Name');
  });
}
