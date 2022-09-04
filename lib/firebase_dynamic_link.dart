import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:videosdk_flutter_example/providers/auth_provider.dart';
import 'package:videosdk_flutter_example/providers/join_meeting_provider.dart';


class FirebaseDynamicLinkService {
  static Future<String> createDynamicLink(bool short, String meetingId) async {
    String _linkMessage;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://joinvc.page.link/join',
      link: Uri.parse(
          'https://joinvc.page.link/meetingId?id=${meetingId}'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.example',
        minimumVersion: 125,
      ),
    );
    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }

    _linkMessage = url.toString();
    return _linkMessage;
  }

  Future<void> onJoinMeetingButtonPressed(BuildContext context) async {
    await Provider.of<JoinMeetingProvider>(context, listen: false)
        .onJoinMeetingButtonPressed(_meetingID, _token);
   http.Response meetingResponse =  Provider.of<JoinMeetingProvider>(context, listen: false)
        .validateMeetingResponse;
    if (meetingResponse.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinScreen(
            meetingId: _meetingID,
            token: _token,
          ),
        ),
      );
    } else {
      toastMsg("Invalid Meeting ID");
    }
  }

   Future<void> initDynamicLink(BuildContext context) {
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
        final Uri deepLink = dynamicLink.link;
        var isMeeting = deepLink.pathSegments.contains('meetingId');
        if(isMeeting){
          String id =deepLink.queryParameters['id'].toString();
          if(deepLink != null){
            Provider.of<AuthProvider>(context).isLoggedIn ? await onJoinMeetingButtonPressed(context)  ; 
          }
        }
      }
    )
  }

