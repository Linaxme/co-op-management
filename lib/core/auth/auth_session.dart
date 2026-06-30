import 'package:firebase_auth/firebase_auth.dart';



enum UserRole { none, admin, member }



class AuthSession {

  final User? user;

  final UserRole role;

  final String? memberUuid;

  final String? coopId;

  final String? coopCode;



  const AuthSession({

    required this.user,

    required this.role,

    this.memberUuid,

    this.coopId,

    this.coopCode,

  });



  static const unauthenticated =

      AuthSession(user: null, role: UserRole.none);



  bool get isAuthenticated => user != null && role != UserRole.none;

  bool get isAdmin => role == UserRole.admin;

  bool get isMember => role == UserRole.member;

}

