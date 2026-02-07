import 'package:get/get.dart';

/// AI Talk Blob Controller - Manages blob breathing animation
class AiTalkBlobController extends GetxController {
  final RxBool isAnimating = false.obs;
  final RxDouble blobScale = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    _startBlobAnimation();
  }

  void _startBlobAnimation() {
    isAnimating.value = true;
    _animateBlob();
  }

  Future<void> _animateBlob() async {
    while (isAnimating.value) {
      blobScale.value = 1.1;
      await Future.delayed(const Duration(milliseconds: 1500));

      blobScale.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 1500));
    }
  }

  void stopAnimation() {
    isAnimating.value = false;
    blobScale.value = 1.0;
  }

  @override
  void onClose() {
    stopAnimation();
    super.onClose();
  }
}
