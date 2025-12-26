import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../utils/toast_message/toast_message.dart';

class ContactHelpController extends GetxController {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  
  String? attachedImagePath;
  bool isLoading = false;

  final ImagePicker _picker  = ImagePicker();

  void attachScreenshot() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        attachedImagePath = image.path;
        update();
        ToastMessage.success('Screenshot attached successfully');
      }
    } catch (e) {
      ToastMessage.error('Failed to attach screenshot');
    }
  }

  void removeAttachment() {
    attachedImagePath = null;
    update();
  }

  bool validateForm() {
    if (subjectController.text.trim().isEmpty) {
      ToastMessage.error('Please enter a subject');
      return false;
    }
    
    if (emailController.text.trim().isEmpty) {
      ToastMessage.error('Please enter your email address');
      return false;
    }
    
    if (!GetUtils.isEmail(emailController.text.trim())) {
      ToastMessage.error('Please enter a valid email address');
      return false;
    }
    
    if (messageController.text.trim().isEmpty) {
      ToastMessage.error('Please describe your issue');
      return false;
    }
    
    return true;
  }

  void sendMessage() async {
    if (!validateForm()) return;
    
    isLoading = true;
    update();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    isLoading = false;
    update();
    
    // Clear form after successful submission
    subjectController.clear();
    emailController.clear();
    messageController.clear();
    attachedImagePath = null;
    
    ToastMessage.success('Your message has been sent. We\'ll get back to you soon!');
  }

  @override
  void onClose() {
    subjectController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.onClose();
  }
}