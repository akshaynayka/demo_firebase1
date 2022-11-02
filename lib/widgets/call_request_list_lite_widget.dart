import 'package:flutter/material.dart';
import '../helpers/call_requests_helper.dart';
import '../models/call_request.dart';
import '../widgets/circular_loader_widget.dart';

class CallRequestListTileWidget extends StatefulWidget {
  const CallRequestListTileWidget({
    required this.callRequestData,
    required this.userRole,
    this.onTap,
    this.onLongPress,
    required this.ctx,
    Key? key,
  }) : super(key: key);
  final void Function()? onTap;
  final CallRequest callRequestData;
  final void Function()? onLongPress;
  final BuildContext ctx;
  final String? userRole;

  @override
  State<CallRequestListTileWidget> createState() =>
      _CallRequestListTileWidgetState();
}

class _CallRequestListTileWidgetState extends State<CallRequestListTileWidget> {
  // var _isLoading = true;
  // bool _isInit = true;

  @override
  Widget build(BuildContext context) {
    // return ListTile(
    //   leading: const CircleAvatar(
    //     child: Text('A'),
    //   ),
    //   subtitle: Text(widget.callRequestData.status ?? 'null'),
    // );

    return
        // _isLoading
        //     ? const CircularLoaderWidget()
        //     :

        FutureBuilder<Map<String, dynamic>>(
            future: CallRequestsHelper()
                .getCallRequestCombineData(widget.callRequestData),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularLoaderWidget();
              } else {
                // Customer(id: id, userId: userId, address: address, email: email, fullName: fullName, latitude: latitude, longitude: longitude, mobile: mobile)
                // return Text('data');
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      snapshot.data!['customer'].fullName
                          .substring(0, 1)
                          .toUpperCase(),
                    ),
                  ),
                  title: Text(snapshot.data!['customer'].fullName),
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                );
              }
            });
  }
}
