import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ncov2019_codewithandrea_web_client/services/firestore_database.dart';
import 'package:ncov2019_codewithandrea_web_client/services/firebase_auth_service.dart';

/// Used to create user-dependent objects that need to be accessible by all widgets.
/// This widgets should live above the [MaterialApp].
/// See [AuthWidget], a descendant widget that consumes the snapshot generated by this builder.
class AuthWidgetBuilder extends StatelessWidget {
  const AuthWidgetBuilder(
      {Key key, @required this.builder, @required this.databaseBuilder})
      : super(key: key);
  final Widget Function(BuildContext, AsyncSnapshot<User>) builder;
  final FirestoreDatabase Function(BuildContext context, String uid)
      databaseBuilder;

  @override
  Widget build(BuildContext context) {
    final authService =
        Provider.of<FirebaseAuthService>(context, listen: false);
    return StreamBuilder<User>(
      stream: authService.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        final User user = snapshot.data;
        if (user != null) {
          return MultiProvider(
            providers: [
              Provider<User>.value(value: user),
              Provider<FirestoreDatabase>(
                create: (context) => databaseBuilder(context, user.uid),
              ),
              // NOTE: Any other user-bound providers here can be added here
            ],
            child: builder(context, snapshot),
          );
        }
        return builder(context, snapshot);
      },
    );
  }
}
