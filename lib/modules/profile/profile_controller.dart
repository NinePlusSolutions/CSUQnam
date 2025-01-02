import 'package:get/get.dart';
import 'package:flutter_getx_boilerplate/api/api_provider.dart';
import 'package:flutter_getx_boilerplate/models/profile/profile_response.dart';

class ProfileController extends GetxController {
  final _apiProvider = Get.find<ApiProvider>();
  final Rx<ProfileResponse?> profile = Rx<ProfileResponse?>(null);
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      final response = await _apiProvider.getProfile();
      if (response.data != null) {
        profile.value = response.data;
      }
    } catch (e) {
      print('Error fetching profile: $e');
    } finally {
      isLoading(false);
    }
  }

  String get fullName => profile.value?.fullName ?? '';
  String get email => profile.value?.email ?? '';
  String get phoneNumber => profile.value?.phoneNumber ?? '';
  String get avatarUrl => profile.value?.avatarUrl ?? '';
}
