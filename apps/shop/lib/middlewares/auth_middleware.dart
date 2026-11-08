import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    const authRoute = '/auth';
    const successUrl = '/';

    return auth.currentUser == null && route != authRoute
        ? const RouteSettings(name: authRoute)
        : auth.currentUser == null && route == authRoute
            ? null
            : auth.currentUser != null && route == authRoute
                ? const RouteSettings(name: successUrl)
                : null;
  }
}
