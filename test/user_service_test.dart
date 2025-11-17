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
      aboutMe: 'Original about',
      creationTime: DateTime(2024, 1, 1),
      totalSteps: 0,
    );

    when(() => mockService.updateUserData(any())).thenAnswer((_) async {});
    when(() => mockService.logout()).thenAnswer((_) async {});
  });

  testWidgets('only name is changed, all other fields stay the same in update payload', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfilePage(userService: mockService, initialUser: baseUser)));
    await tester.pumpAndSettle();

    final nameField = find.byType(TextField).first;
    await tester.enterText(nameField, 'New Name');
    await tester.pump();

    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    final captured = verify(() => mockService.updateUserData(captureAny())).captured.single as Map<String, dynamic>;

    expect(captured['name'], 'New Name');
    expect(captured['aboutMe'], baseUser.aboutMe);
    expect(captured['age'], baseUser.age);
    expect(captured['userMotivation'], (baseUser.userMotivation ?? UserMotivation.other).name);
    expect(captured.keys.toSet(), {'name', 'aboutMe', 'age', 'userMotivation'});
  });

  testWidgets('initial profile data is rendered correctly', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfilePage(userService: mockService, initialUser: baseUser)));
    await tester.pumpAndSettle();

    expect(find.text('@raphael'), findsOneWidget);
    expect(find.text('Raphael'), findsOneWidget);
    expect(find.text('Original about'), findsOneWidget);
    expect(find.textContaining('WalkeRooner since'), findsOneWidget);
  });

  testWidgets('changing aboutMe only updates aboutMe field', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfilePage(userService: mockService, initialUser: baseUser)));
    await tester.pumpAndSettle();

    final aboutField = find.byWidgetPredicate((w) => w is TextField && w.maxLines == 5);

    await tester.enterText(aboutField, 'New about text');
    await tester.pump();

    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    final captured = verify(() => mockService.updateUserData(captureAny())).captured.single as Map<String, dynamic>;

    expect(captured['aboutMe'], 'New about text');
    expect(captured['name'], baseUser.name);
    expect(captured['age'], baseUser.age);
    expect(captured['userMotivation'], (baseUser.userMotivation ?? UserMotivation.other).name);
  });

  testWidgets('empty name is saved as empty and other fields unchanged', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfilePage(userService: mockService, initialUser: baseUser)));
    await tester.pumpAndSettle();

    final nameField = find.byType(TextField).first;
    await tester.enterText(nameField, '');
    await tester.pump();

    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    final captured = verify(() => mockService.updateUserData(captureAny())).captured.single as Map<String, dynamic>;

    expect(captured['name'], '');
    expect(captured['aboutMe'], baseUser.aboutMe);
    expect(captured['age'], baseUser.age);
    expect(captured['userMotivation'], (baseUser.userMotivation ?? UserMotivation.other).name);
  });

  testWidgets('logout calls userService.logout once', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfilePage(userService: mockService, initialUser: baseUser)));
    await tester.pumpAndSettle();

    final logoutButton = find.byIcon(Icons.logout);
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    verify(() => mockService.logout()).called(1);
  });
}
