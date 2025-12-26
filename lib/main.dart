import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/app_route/route_path.dart';
import 'core/dependency/dependency.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetX controllers
  Dependency.init();

  // runApp(
  //   DevicePreview(
  //     enabled: true, // <-- TURN ON DEVICE PREVIEW
  //     builder: (context) => const MyApp(),
  //   ),
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),    
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      builder: (context, child) {
        return GetMaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: _lightTheme,
          routeInformationParser: RoutePath.router.routeInformationParser,
          routerDelegate: RoutePath.router.routerDelegate,
          routeInformationProvider: RoutePath.router.routeInformationProvider,

          // REQUIRED BY DevicePreview - Chain both builders
          builder: (context, widget) {
            // First apply DevicePreview's builder
            widget = DevicePreview.appBuilder(context, widget);
            // Then apply ScreenUtil's builder if needed
            return widget;
          },
          locale: DevicePreview.locale(context),
        );
      },
    );
  }

  ThemeData get _lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: GoogleFonts.poppinsTextTheme(), // Default font: Poppins
    // Alternatively use: GoogleFonts.interTextTheme() for Inter as default
  );
}
