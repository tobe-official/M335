import 'package:WalkeRoo/models/user_motivation_enum_model.dart';

enum UserMotivation { running, gym, cycling, hiking, yoga, swimming, walking, dancing, climbing, other }

extension UserMotivationX on UserMotivation {
  UserMotivationEnumModel get model {
    switch (this) {
      case UserMotivation.running:
        return UserMotivationEnumModel(title: 'Running', description: 'Going for a run in nature or through the city.');
      case UserMotivation.gym:
        return UserMotivationEnumModel(title: 'Gym', description: 'Training strength and endurance indoors.');
      case UserMotivation.cycling:
        return UserMotivationEnumModel(title: 'Cycling', description: 'Exploring roads and trails on your bike.');
      case UserMotivation.hiking:
        return UserMotivationEnumModel(
          title: 'Hiking',
          description: 'Enjoying long walks in the mountains or forests.',
        );
      case UserMotivation.yoga:
        return UserMotivationEnumModel(title: 'Yoga', description: 'Improving balance, flexibility, and inner peace.');
      case UserMotivation.swimming:
        return UserMotivationEnumModel(title: 'Swimming', description: 'Building endurance and strength in the water.');
      case UserMotivation.walking:
        return UserMotivationEnumModel(title: 'Walking', description: 'Staying active with casual or brisk walks.');
      case UserMotivation.dancing:
        return UserMotivationEnumModel(
          title: 'Dancing',
          description: 'Expressing yourself and staying fit through movement.',
        );
      case UserMotivation.climbing:
        return UserMotivationEnumModel(
          title: 'Climbing',
          description: 'Challenging your strength and focus on walls or rocks.',
        );
      case UserMotivation.other:
        return UserMotivationEnumModel(
          title: 'Other',
          description: 'Any other kind of physical activity or motivation.',
        );
    }
  }
}
