import '../../common_methods/common_methods.dart';
import '../../values/api_end_points.dart';
import '../../values/colors.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/text_form_field_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  @override
  void initState() {
    _checkData();
    super.initState();
  }

  var _isLoading = false;
  // final TextEditingController _radiousController = TextEditingController();
  // final TextEditingController _tempController = TextEditingController();
  Future<void> _checkData() async {
    setState(() {
      _isLoading = true;
    });
    final configurationData = await FirebaseFirestore.instance
        .collection(apiConfigurations)
        .snapshots()
        .first;
    if (configurationData.docs.isNotEmpty) {
      final configurationSnapshot = await FirebaseFirestore.instance
          .collection(apiConfigurations)
          .snapshots()
          .first;
      final radiusDataInstance = configurationSnapshot.docs.first;
      final radiusData = radiusDataInstance.data();
      if (radiusData['radius'] == null || radiusData['radius'] == '') {
        final configInstance = FirebaseFirestore.instance
            .collection(apiConfigurations)
            .doc(radiusDataInstance.id);
        await configInstance.update({'radius': '500'});
      }
    } else {
      final configData =
          FirebaseFirestore.instance.collection(apiConfigurations).doc();
      await configData.set({'radius': '500'});
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _valueRowWidget({
    required Size deviceSize,
    required String label,
    required String dataKey,
    // required TextEditingController controller0,
    // required void Function()? onPressed,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(apiConfigurations)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(appTitleSomethingWentWrong);
          } else if (snapshot.hasData) {
            final configurationData = snapshot.data!.docs.first.data();

            // controller.text = configurationData[dataKey];
            // controller.selection = TextSelection.fromPosition(
            //     TextPosition(offset: controller.text.length));
            var keyValue = '';
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: appColorGreyDark,
                      ),
                    ),
                  ),
                  Flexible(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormFieldWidget(
                          // controller: controller,
                          initialValue: configurationData[dataKey],
                          onChanged: (value) {
                            // controller.text = value;
                            keyValue = value;
                          },
                          keyboardType: TextInputType.number,
                        ),
                      )),
                  Flexible(
                    flex: 2,
                    child: Container(
                      // color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          onPressed: () async {
                            if (keyValue != '') {
                              final radiusInstance = FirebaseFirestore.instance
                                  .collection(apiConfigurations);
                              final radiusSnapshot =
                                  await radiusInstance.snapshots().first;
                              await radiusInstance
                                  .doc(radiusSnapshot.docs.first.id)
                                  .update({dataKey: keyValue});

                              displaySnackbar(
                                  context: context,
                                  msg: '$label Value Updated');
                            }
                          },
                          icon: Icon(
                            Icons.save,
                            size: 35.0,
                            color: Theme.of(context).primaryColor,
                          )),
                    ),
                  )
                ],
              ),
            );
          } else {
            return const CircularLoaderWidget();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const AppBarWidget(title: 'Configurations'),
      body: _isLoading
          ? const CircularLoaderWidget()
          : Column(children: [
              const SizedBox(
                height: 50,
              ),
              _valueRowWidget(
                label: 'Radius :',
                dataKey: 'radius',
                deviceSize: deviceSize,
              ),
              // _valueRowWidget(
              //   label: 'Temp :',
              //   dataKey: 'temp',
              //   deviceSize: deviceSize,
              // ),
            ]),
    );
  }
}
