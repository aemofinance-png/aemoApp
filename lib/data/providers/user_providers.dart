import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../providers/service_providers.dart';

final userByIdProvider =
    FutureProvider.family<UserModel?, String>((ref, userId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUser(userId);
});
