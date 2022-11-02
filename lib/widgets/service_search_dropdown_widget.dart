
import 'package:flutter/material.dart';
import '../helpers/service_helper.dart';
import '../models/service.dart';
import '../values/string_en.dart';

typedef ServiceCallback = void Function(dynamic val);

class ServiceSearchDropdownWidget extends StatefulWidget {
  final ServiceCallback callback;
  final List<Service?>? serviceList;
  const ServiceSearchDropdownWidget({
    Key? key,
    required this.callback,
    required this.serviceList,
  }) : super(key: key);
  @override
  ServiceSearchDropdownWidgetState createState() =>
      ServiceSearchDropdownWidgetState();
}

class ServiceSearchDropdownWidgetState
    extends State<ServiceSearchDropdownWidget> {
  bool _isInit = true;
  List<Service> _serviceList = [];
  List<Service?> _selectedServiceList = [];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _serviceList = await ServiceHelper().gellAllServiceList();
    }
    setState(() {
      _isInit = false;
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.serviceList != null) {
      _selectedServiceList = widget.serviceList!;
    }

    // final temp = _selectedServiceList.firstWhere(
    //     (data) => data!.id == _serviceList[0].id!,
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
        widget.callback(_selectedServiceList);
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
                  itemCount: _serviceList.length,
                  itemBuilder: (BuildContext context, int index) =>
                      CheckboxListTile(
                    title: Text(_serviceList[index].name!),
                    value: _selectedServiceList
                                .firstWhere(
                                    (data) =>
                                        data!.id == _serviceList[index].id!,
                                    orElse: () => Service(
                                          id: null,
                                          name: null,
                                          description: null,
                                          etimatedDuration: null,
                                          status: null,
                                        ))
                                ?.id !=
                            null
                        ? true
                        : false,
                    // value: false,
                    // value: _selectedServiceList.firstWhere(
                    //     (data) => data.id == _serviceList[index].id!,
                    //     orElse: () => null), // value:
                    //     _selectedServiceList.contains(_serviceList[index].id),
                    onChanged: (bool? value) {
                      if (value!) {
                        setState(() {
                          _selectedServiceList.add(Service(
                            id: _serviceList[index].id!,
                            name: _serviceList[index].name,
                            description: null,
                            etimatedDuration: null,
                            status: null,
                            createdAt: null,
                            createdBy: null,
                            updatedAt: null,
                            updatedBy: null,
                            deletedAt: null,
                            deletedBy: null,
                          ));
                        });
                      } else {
                        setState(() {
                          _selectedServiceList.removeWhere(
                              (data) => data?.id == _serviceList[index].id);
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
                widget.callback(_selectedServiceList);
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }
}
