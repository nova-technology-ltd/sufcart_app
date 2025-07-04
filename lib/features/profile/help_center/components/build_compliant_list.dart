import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/complaint_view_screen.dart';
import '../services/help_center_services.dart';
import 'complaint_custom_card.dart';
import 'delete_complaint_bottom_sheet.dart';

class BuildCompliantList extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> future;
  final String emptyMessage;
  final Future<void> Function(BuildContext) refreshScreen;

  const BuildCompliantList(
      {super.key,
      required this.future,
      required this.emptyMessage,
      required this.refreshScreen});

  @override
  State<BuildCompliantList> createState() => _BuildCompliantListState();
}

class _BuildCompliantListState extends State<BuildCompliantList> {
  final HelpCenterServices helpCenterServices = HelpCenterServices();
  bool isLoading = false;

  Future<void> deleteUserCompliant(
      BuildContext context, String complaintID) async {
    try {
      setState(() {
        isLoading = true;
      });
      int statusCode =
          await helpCenterServices.deleteUserComplaint(context, complaintID);
      if (statusCode == 200 || statusCode == 201) {
        if (context.mounted) {
          Navigator.pop(context);
        }
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          widget.refreshScreen(context);
        }
      } else {
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          widget.refreshScreen(context);
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> showDeleteBottomSheet(
      BuildContext context, final Map<String, dynamic> complaints) async {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return DeleteComplaintBottomSheet(
            complaints: complaints,
            onClick: () async {
              await deleteUserCompliant(context, complaints['complaintID']);
            },
            isLoading: isLoading,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: widget.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(child: Text(widget.emptyMessage));
          }
          List<Map<String, dynamic>> complaints =
              snapshot.data!.reversed.toList();
          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              return ComplaintCustomCard(
                complaints: complaints[index],
                onLongPress: () =>
                    showDeleteBottomSheet(context, complaints[index]),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ComplaintViewScreen(complaints: complaints[index]))).then((_) {
                    if (context.mounted) {
                      widget.refreshScreen(context);
                    }
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
