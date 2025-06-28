import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ysyw/config/router/route_names.dart';
import 'package:ysyw/services/fcm_service.dart';
import 'package:ysyw/services/local_storage_service.dart';

import '../../bloc/auth/authentication_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String token = "";
  String userId = "";
  @override
  void initState() {
    super.initState();
    // Fetch the token from local storage or any other source

    context.read<AuthenticationBloc>().add(GetUserProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (BuildContext context, AuthenticationState state) {
              if (state is AuthenticationLoading) {
                return const Text('Loading...');
              } else if (state is ProfileLoaded) {
                return Text('Welcome, ${state.user.name}');
              } else if (state is AuthenticationError) {
                return Text('Error: ${state.message}');
              }
              return const Text('Home Page');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthenticationBloc>().add(LogoutEvent());
              },
            ),
          ],
        ),
        body: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (BuildContext context, AuthenticationState state) {
            if (state is LogoutSuccess) {
              context.goNamed(RouteNames.onboarding);
            }
          },
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (BuildContext context, AuthenticationState state) {
            if (state is AuthenticationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              userId = state.user.id;
              // Remove or update the following line if 'token' does not exist on User
              // token = state.user.token;
              FcmService().saveToken(userId);
              return Center(
                child: Text('Welcome, ${state.user.name}!\nUser ID: '),
              );
            } else if (state is AuthenticationError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            // Always return a widget
            return const SizedBox.shrink();
          }),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          onTap: (index) {
            // Handle navigation based on index
            if (index == 0) {
              // Navigate to home
              // context.go('/home');
            } else if (index == 1) {
              // Navigate to settings
              // context.go('/settings');
            }
          },
        ));
  }
}
