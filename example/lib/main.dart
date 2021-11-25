// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:twitter_auth_nullsafety/twitter_auth_nullsafety.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TwitterAuth _twitterAuth2;
  String? errorMessage;
  String? username;
  String? userId;

  @override
  void initState() {
    super.initState();
    initializaPlugin();
  }

  void initializaPlugin() async {
    const options = AuthConfig(
      apiToken: 'txQkBHs3tRTyyBmXGrudfn0MU',
      apiTokenSecret: 'SwjP6KOZtZb7xawHG7vgVBaTRPHCF7M9Y7XABa0yGt7lAGrCIz',
      callbackUrl: 'https://example.com/oauth/callback',
    );
    _twitterAuth2 = await TwitterAuth.initialize(options);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('User Twitter ID: $userId'),
              //
              const SizedBox(height: 16),
              //
              Text('Twitter username: $username'),
              //
              const SizedBox(height: 16),
              //
              const Text('Check the logs for "AccessToken" & "Secret"'),
              //
              const SizedBox(height: 16),
              //
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _twitterAuth2.signOut();

                    // final result = await _twitterAuth2.login(requestEmail: true);
                    final result = await _twitterAuth2.login();

                    switch (result.status) {
                      case TwitterAuthStatus.loggedIn:
                        print('Session token => ${result.session?.token}');
                        print('Session secret => ${result.session?.secret}');
                        print('\n\nAuth Session ==>-->> ${result.session}');

                        setState(() {
                          username = result.session?.user.username;
                          userId = result.session?.user.userId;
                        });
                        break;
                      case TwitterAuthStatus.inProgress:
                        print('Login in progress, please wait!!');
                        break;
                      case TwitterAuthStatus.cancelled:
                        print('Auth cancelled by user');
                        break;
                      case TwitterAuthStatus.failed:
                        print(result);
                        break;
                    }
                  } on TwitterAuthException catch (e) {
                    print('Exception status ===> ${e.status}');
                    print('Message body ===> ${e.message}');

                    setState(() => errorMessage = e.message);
                  }
                },
                child: const Text('Continue with Twitter'),
              ),
              //
              if (userId != null)
                Column(
                  children: [
                    const SizedBox(height: 36),
                    //
                    const Text('Get the current user session'),
                    //
                    const SizedBox(height: 8),
                    //
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final result = await _twitterAuth2.currentSession;

                          setState(() {
                            username = '${result?.user.username} - (Session)';
                            userId = '${result?.user.userId} - (Session)';
                          });
                        } on TwitterAuthException catch (e) {
                          print('Exception status ===> ${e.status}');
                          print('Message body ===> ${e.message}');

                          setState(() => errorMessage = e.message);
                        }
                      },
                      child: const Text('Get Current Session'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
