import 'dart:convert';

import '../../community/follows/model/follow_model.dart';
import '../../community/messages/data/model/messages_model.dart';
import '../../settings/model/user_settings_model.dart';

class UserModel {
  final String id;
  final String userID;
  final String firstName;
  final String lastName;
  final String otherNames;
  final String userName;
  final String image;
  final String phoneNumber;
  final String gender;
  final String dob;
  final String email;
  final String password;
  final int accountPIN;
  final String token;
  final bool isVendor;
  final bool isEmailVerified;
  final List<dynamic> connectionRequest;
  final List<dynamic> connections;
  final List<dynamic> myInvites;
  final List<dynamic> blockedConnections;
  final List<dynamic> securityQuestions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserSettingsModel userSettings;
  final List<dynamic> interests;
  final bool isProfileComplete;
  final bool extraSecurity;
  final String inviteCode;
  final List<FollowModel> followers;
  final List<FollowModel> following;
  final MessagesModel? lastMessage;
  final String? status; // e.g., 'online', 'offline', 'away'

  UserModel({
    required this.id,
    required this.userID,
    required this.firstName,
    required this.lastName,
    required this.otherNames,
    required this.userName,
    required this.image,
    required this.phoneNumber,
    required this.gender,
    required this.dob,
    required this.email,
    required this.password,
    required this.accountPIN,
    required this.token,
    required this.isVendor,
    required this.isEmailVerified,
    required this.connectionRequest,
    required this.connections,
    required this.myInvites,
    required this.blockedConnections,
    required this.securityQuestions,
    required this.createdAt,
    required this.updatedAt,
    required this.userSettings,
    required this.interests,
    required this.isProfileComplete,
    required this.extraSecurity,
    required this.inviteCode,
    required this.followers,
    required this.following,
    this.lastMessage,
    this.status,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    print('Parsing user: $map'); // Log the raw map

    // Handle lastMessage
    MessagesModel? lastMessage;
    if (map['lastMessage'] != null && map['lastMessage'] is Map) {
      try {
        lastMessage = MessagesModel.fromMap(Map<String, dynamic>.from(map['lastMessage']));
      } catch (e) {
        print('Error parsing lastMessage: $e, value: ${map['lastMessage']}');
        lastMessage = null;
      }
    } else if (map['lastMessage'] != null) {
      print('Invalid lastMessage type: ${map['lastMessage'].runtimeType}, value: ${map['lastMessage']}');
      lastMessage = null;
    }

    // Handle userSettings
    UserSettingsModel userSettings;
    if (map['userSettings'] != null && map['userSettings'] is Map) {
      try {
        userSettings = UserSettingsModel.fromMap(map['userSettings']);
      } catch (e) {
        print('Error parsing userSettings: $e, value: ${map['userSettings']}');
        userSettings = UserSettingsModel.fromMap({}); // Fallback to default
      }
    } else {
      print('userSettings is null or invalid: ${map['userSettings']}');
      userSettings = UserSettingsModel.fromMap({}); // Fallback to default
    }

    // Handle followers and following
    List<FollowModel> followers = [];
    if (map['followers'] != null && map['followers'] is List) {
      try {
        followers = (map['followers'] as List<dynamic>)
            .map((follower) => FollowModel.fromMap(follower as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error parsing followers: $e, value: ${map['followers']}');
        followers = [];
      }
    }

    List<FollowModel> following = [];
    if (map['following'] != null && map['following'] is List) {
      try {
        following = (map['following'] as List<dynamic>)
            .map((following) => FollowModel.fromMap(following as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error parsing following: $e, value: ${map['following']}');
        following = [];
      }
    }

    return UserModel(
      id: map['_id']?.toString() ?? '',
      userID: map['userID']?.toString() ?? '',
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      otherNames: map['otherNames']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      phoneNumber: map['phoneNumber']?.toString() ?? '',
      gender: map['gender']?.toString() ?? '',
      dob: map['dob']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      accountPIN: map['accountPIN'] is int ? map['accountPIN'] : 0,
      token: map['token']?.toString() ?? '',
      inviteCode: map['inviteCode']?.toString() ?? '',
      isVendor: map['isVendor'] is bool ? map['isVendor'] : false,
      isEmailVerified: map['isEmailVerified'] is bool ? map['isEmailVerified'] : false,
      connectionRequest: map['connectionRequest'] is List ? map['connectionRequest'] : [],
      connections: map['connections'] is List ? map['connections'] : [],
      myInvites: map['myInvites'] is List ? map['myInvites'] : [],
      blockedConnections: map['blockedConnections'] is List ? map['blockedConnections'] : [],
      securityQuestions: map['securityQuestions'] is List ? map['securityQuestions'] : [],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
      userSettings: userSettings,
      interests: map['interests'] is List ? map['interests'] : [],
      isProfileComplete: map['isProfileComplete'] is bool ? map['isProfileComplete'] : false,
      extraSecurity: map['extraSecurity'] is bool ? map['extraSecurity'] : false,
      followers: followers,
      following: following,
      lastMessage: lastMessage,
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userID': userID,
      'firstName': firstName,
      'lastName': lastName,
      'otherNames': otherNames,
      'userName': userName,
      'image': image,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dob': dob,
      'email': email,
      'password': password,
      'accountPIN': accountPIN,
      'token': token,
      'inviteCode': inviteCode,
      'isVendor': isVendor,
      'isEmailVerified': isEmailVerified,
      'connectionRequest': connectionRequest,
      'connections': connections,
      'myInvites': myInvites,
      'blockedConnections': blockedConnections,
      'securityQuestions': securityQuestions,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userSettings': userSettings.toMap(),
      'interests': interests,
      'isProfileComplete': isProfileComplete,
      'extraSecurity': extraSecurity,
      'followers': followers.map((follower) => follower.toMap()).toList(),
      'following': following.map((following) => following.toMap()).toList(),
      'lastMessage': lastMessage?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  UserModel copyWith({
    String? id,
    String? userID,
    String? firstName,
    String? lastName,
    String? otherNames,
    String? userName,
    String? image,
    String? phoneNumber,
    String? gender,
    String? dob,
    String? email,
    String? password,
    int? accountPIN,
    String? token,
    String? inviteCode,
    bool? isVendor,
    bool? isEmailVerified,
    // List<CartItem>? cart,
    List<dynamic>? connectionRequest,
    List<dynamic>? connections,
    List<dynamic>? myInvites,
    List<dynamic>? blockedConnections,
    List<dynamic>? securityQuestions,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserSettingsModel? userSettings,
    // UserWalletModel? userWallet,
    List<dynamic>? interests,
    bool? isProfileComplete,
    bool? extraSecurity,
    List<FollowModel>? followers,
    List<FollowModel>? following,
    MessagesModel? lastMessage,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      userID: userID ?? this.userID,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      otherNames: otherNames ?? this.otherNames,
      userName: userName ?? this.userName,
      image: image ?? this.image,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      email: email ?? this.email,
      password: password ?? this.password,
      accountPIN: accountPIN ?? this.accountPIN,
      token: token ?? this.token,
      inviteCode: inviteCode ?? this.inviteCode,
      isVendor: isVendor ?? this.isVendor,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      // cart: cart ?? this.cart,
      connectionRequest: connectionRequest ?? this.connectionRequest,
      connections: connections ?? this.connections,
      myInvites: myInvites ?? this.myInvites,
      blockedConnections: blockedConnections ?? this.blockedConnections,
      securityQuestions: securityQuestions ?? this.securityQuestions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userSettings: userSettings ?? this.userSettings,
      interests: interests ?? this.interests,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      extraSecurity: extraSecurity ?? this.extraSecurity,
      // userWallet: userWallet ?? this.userWallet,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      lastMessage: lastMessage ?? this.lastMessage,
      status: status ?? this.status,
    );
  }
}
