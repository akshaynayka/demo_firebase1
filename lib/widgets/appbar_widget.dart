import '../values/string_en.dart';
import 'package:flutter/material.dart';
import '../common_methods/common_methods.dart';
import '../values/colors.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? automaticallyImplyLeading;
  final bool resetData;
  final bool logout;
  // final bool accountAction;

  const AppBarWidget({
    this.title,
    this.automaticallyImplyLeading = true,
    this.resetData = false,
    this.logout = false,
    // this.accountAction = false,
    Key? key,
    // required this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final appBartitle = dotenv.get('APP_TITLE');
    const String appBartitle = appTitle;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            appColorPrimary,
            appColorSecondGradient,
          ],
          // e75c00
          // ea8100
        ),
      ),
      child: AppBar(
          title: Text(title != null ? title! : appBartitle),
          titleTextStyle: const TextStyle(
            // fontSize: 25.0,
            color: appColorWhite,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(
            color: appColorWhite, //change your color here
          ),
          automaticallyImplyLeading: automaticallyImplyLeading!,
          // backgroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.transparent,
          foregroundColor: appColorBlack,
          elevation: 0.0,
          actions: [
            if (resetData)
              Container(
                // height: 30.0,
                // width: 30.0,
                decoration: const BoxDecoration(
                  color: appColorWhite,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.restart_alt_outlined),
                  color: Theme.of(context).primaryColor,
                  onPressed: () async {
                    await showResetDataDialog(context);
                  },
                ),
              ),
            const SizedBox(
              width: 15.0,
            ),
            Container(
              // height: 30.0,
              // width: 30.0,
              decoration: const BoxDecoration(
                color: appColorWhite,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.power_settings_new_outlined,
                ),
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  await showLogoutAppDialog(context);
                },
              ),
            ),
            const SizedBox(
              width: 20.0,
            )
          ]),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
