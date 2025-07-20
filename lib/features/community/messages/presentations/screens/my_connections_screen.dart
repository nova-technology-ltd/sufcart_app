import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/follows/components/my_connections_card_style.dart';
import 'package:sufcart_app/features/community/follows/services/follows_services.dart';
import 'package:sufcart_app/utilities/components/app_bar_back_arrow.dart';

import '../../../../../utilities/constants/app_colors.dart';
import '../../../../../utilities/themes/theme_provider.dart';
import '../../../../profile/model/user_model.dart';
import '../../../../profile/model/user_provider.dart';


class MyConnectionsScreen extends StatefulWidget {
  const MyConnectionsScreen({super.key});

  @override
  State<MyConnectionsScreen> createState() => _MyConnectionsScreenState();
}

class _MyConnectionsScreenState extends State<MyConnectionsScreen> {
  late Future<List<UserModel>> _futureConnections;
  final FollowsServices _followsServices = FollowsServices();

  @override
  void initState() {
    _futureConnections = _followsServices.getMyConnections(context);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final sender = Provider.of<UserProvider>(context).userModel;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'My Connections',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        surfaceTintColor: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        automaticallyImplyLeading: false,
        leadingWidth: 90,
        leading: AppBarBackArrow(onClick: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            FutureBuilder<List<UserModel>>(
              future: _futureConnections,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CupertinoActivityIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('No connections'));
                } else if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(child: Text('No connections'));
                }

                final connections = snapshot.data!;
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: connections.asMap().entries.map((entry) {
                      final user = entry.value;
                      return MyConnectionsCardStyle(user: user);
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
