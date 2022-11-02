import '../../widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import '../../helpers/technician_helper.dart';
import '../../models/technician.dart';
import '../../models/user.dart';
import '../../values/app_routes.dart';
import '../../values/static_values.dart';
import '../../values/string_en.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/technician_list_tile_widget.dart';

class TechnicianListForCustomerScreen extends StatelessWidget {
  const TechnicianListForCustomerScreen({this.fromTabScreen,Key? key}) : super(key: key);
  final bool? fromTabScreen;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:fromTabScreen == true ?null: const AppBarWidget(title: 'Technicians'),
      body: StreamBuilder<List<Technician>>(
        stream: TechnicianHelper().getAllTechnicianStream(),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Text(appTitleSomethingWentWrong);
          } else if (snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularLoaderWidget();
            }
            final technicianList = snapshot.data;

            return ListView.builder(
              itemCount: technicianList!.length,
              itemBuilder: (context, index) => TechnicianListTileWidget(
                technicianDetails: technicianList[index],
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
                      'id': technicianList[index].id,
                      'userRole': appRoleTechnician,
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
