import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    const authUrl = RouteSettings(name: '/auth');
    const successUrl = RouteSettings(name: '/');

    return auth.currentUser == null
        ? (route != authUrl.name ? authUrl : null)
        : (route == authUrl.name ? successUrl : null);
  }
}
