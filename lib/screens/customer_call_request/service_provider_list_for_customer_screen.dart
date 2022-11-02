import 'package:flutter/material.dart';
import '../../widgets/appbar_widget.dart';
import '../../helpers/service_provider_helper.dart';
import '../../models/service_provider.dart';
import '../../models/user.dart';
import '../../values/app_routes.dart';
import '../../values/static_values.dart';
import '../../values/string_en.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/service_provider_list_tile_widget.dart';

class ServiceProviderListForCustomerScreen extends StatelessWidget {
  const ServiceProviderListForCustomerScreen({this.fromTabScreen, Key? key})
      : super(key: key);
  final bool? fromTabScreen;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: fromTabScreen != true
          ? const AppBarWidget(
              title: appTitleServiceProviders,
            )
          : null,
      body: StreamBuilder<List<ServiceProvider>>(
        stream: ServiceProviderHelper().getAllServiceProviderStream(),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Text(appTitleSomethingWentWrong);
          } else if (snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularLoaderWidget();
            }
            final serviceProviderList = snapshot.data;

            return ListView.builder(
              itemCount: serviceProviderList!.length,
              itemBuilder: (context, index) => ServiceProviderListTileWidget(
                serviceProviderData: serviceProviderList[index],
                userData: User(
                  id: null,
                  email: null,
                  fullName: null,
                  mobile: null,
                  role: null,
                  authId: null,
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    appRouteAddEditCustomerCallRequestScreen,
                    arguments: {
                      'id': serviceProviderList[index].id,
                      'userRole': appRoleServiceProvider,
                    },
                  );
                },
              ),
            );
          } else {
            return const CircularLoaderWidget();
          }
        }),
      ),
    );
  }
}
