import 'package:flutter/material.dart';
import 'package:task_managing_application/repositories/application_repository.dart';
import 'package:task_managing_application/states/states.dart';
import 'package:task_managing_application/widgets/custom_hea_bar/custom_header_bar.dart';
import 'package:task_managing_application/widgets/widgets.dart'
    show CustomNavigationBar;

class BaseScreen extends StatefulWidget {
  const BaseScreen({
    super.key,
    required this.child,
    this.hideAppBar = true,
    this.hideNavigationBar = false,
  });

  final Widget child;
  final bool hideAppBar;
  final bool hideNavigationBar;

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.resumed) {
  //     context.read<ApplicationRepository>().updateUserActivity(true);
  //   }
  //   if (state == AppLifecycleState.paused ||
  //       state == AppLifecycleState.inactive) {
  //     context.read<ApplicationRepository>().updateUserActivity(false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            if (!widget.hideAppBar)
              const SliverPersistentHeader(
                pinned: true,
                delegate: CustomHeaderBar(
                  // atHomePage: false,
                  // onPressed: (context) {

                  // },
                  upperChild: Text('Hello Liana'),
                  bottomChild: Text('Today is Sunday'),
                ),
              ),
            SliverToBoxAdapter(
              child: widget.child,
            ),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar:
          !widget.hideNavigationBar ? const CustomNavigationBar() : null,
    );
  }
}
