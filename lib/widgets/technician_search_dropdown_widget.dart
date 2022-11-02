import 'package:demo_firebase1/models/user.dart';
import 'package:demo_firebase1/values/static_values.dart';
import 'package:flutter/material.dart';
import '../helpers/technician_helper.dart';
import '../models/technician.dart';
import '../values/string_en.dart';

typedef ServiceCallback = void Function(dynamic val);

class TechnicianSearchDropdownWidget extends StatefulWidget {
  final ServiceCallback callback;
  final List<Technician?>? technicianList;
  final String? serviceProviderId;
  final User userData;
  const TechnicianSearchDropdownWidget({
    Key? key,
    required this.callback,
    required this.technicianList,
    required this.serviceProviderId,
    required this.userData,
  }) : super(key: key);
  @override
  TechnicianSearchDropdownWidgetState createState() =>
      TechnicianSearchDropdownWidgetState();
}

class TechnicianSearchDropdownWidgetState
    extends State<TechnicianSearchDropdownWidget> {
  bool _isInit = true;
  List<Technician> _technicianList = [];
  List<Technician?> _selectedTechnicianList = [];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      if (widget.userData.role == appRoleAdmin) {
        _technicianList = await TechnicianHelper().getAllTechnicianList();
      } else {
        _technicianList = await TechnicianHelper()
            .getMyTechnicianList(serviceProviderId: widget.serviceProviderId!);
      }
    }
    setState(() {
      _isInit = false;
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.technicianList != null) {
      _selectedTechnicianList = widget.technicianList!;
    }

    // final temp = _selectedTechnicianList.firstWhere(
    //     (data) => data!.id == _technicianList[0].id!,
    //     orElse: () => Service(
    //           id: null,
    //           name: null,
    //           description: null,
    //           etimatedDuration: null,
    //           status: null,
    //         ));

    final h = MediaQuery.of(context).size.height * 0.01;
    return WillPopScope(
      onWillPop: () async {
        // Provider.of<Services>(context, listen: false).resetsearchServices();
        widget.callback(_selectedTechnicianList);
        return true;
      },
      child: SizedBox(
        height: h * 80,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.design_services_rounded),
                suffixIcon: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                hintText: 'Search ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onChanged: (value) {
                // if (value.length > 2) {
                //   Provider.of<Services>(context, listen: false)
                //       .searchServices(value, '1')
                //       .then((value) {
                //     setState(() {
                //       services = customerData.searchServicesList;
                //     });
                //   });
                // } else {
                //   Provider.of<Services>(context, listen: false)
                //       .resetsearchServices();
                //   setState(() {
                //     services = customerData.services;
                //   });

                // }
              },
            ),
            SizedBox(
              height: h * 63,
              child: Scrollbar(
                interactive: true,
                // hoverThickness: 20,

                thickness: 5,
                radius: Radius.circular(h),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.all(8),
                  itemCount: _technicianList.length,
                  itemBuilder: (BuildContext context, int index) =>
                      CheckboxListTile(
                    title: Text(_technicianList[index].fullName!),
                    value: _selectedTechnicianList
                                .firstWhere(
                                    (data) =>
                                        data!.id == _technicianList[index].id!,
                                    orElse: () => Technician(
                                          id: null,
                                          userId: null,
                                          address: null,
                                          email: null,
                                          fullName: null,
                                          latitude: null,
                                          longitude: null,
                                          mobile: null,
                                        ))
                                ?.id !=
                            null
                        ? true
                        : false,
                    // value: false,
                    // value: _selectedTechnicianList.firstWhere(
                    //     (data) => data.id == _technicianList[index].id!,
                    //     orElse: () => null), // value:
                    //     _selectedTechnicianList.contains(_technicianList[index].id),
                    onChanged: (bool? value) {
                      if (value!) {
                        setState(() {
                          _selectedTechnicianList.add(Technician(
                            id: _technicianList[index].id!,
                            fullName: _technicianList[index].fullName,
                            userId: null,
                            address: null,
                            email: null,
                            latitude: null,
                            longitude: null,
                            mobile: null,
                          ));
                        });
                      } else {
                        setState(() {
                          _selectedTechnicianList.removeWhere(
                              (data) => data?.id == _technicianList[index].id);
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            ElevatedButton(
              child: const Text(appTitleAdd),
              onPressed: () async {
                // Provider.of<Services>(context, listen: false)
                //     .resetsearchServices();
                widget.callback(_selectedTechnicianList);
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }
}
