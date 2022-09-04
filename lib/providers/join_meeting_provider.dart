import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;
import 'package:videosdk_flutter_example/screens/join_screen.dart';
import 'package:videosdk_flutter_example/utils/toast.dart';

class JoinMeetingProvider with ChangeNotifier {
  late Uri validateMeetingUrl;
  late http.Response validateMeetingResponse;
  String token = "";
  String meetingID = "";

  Future<void> onJoinMeetingButtonPressed(
      String _meetingID, String _token) async {
    token = _token;
    meetingID = _meetingID;
    if (_meetingID.isEmpty) {
      toastMsg("Please, Enter Valid Meeting ID");
      return;
    }

    final String? _VIDEOSDK_API_ENDPOINT = dotenv.env['VIDEOSDK_API_ENDPOINT'];

    validateMeetingUrl =
        Uri.parse('$_VIDEOSDK_API_ENDPOINT/meetings/$_meetingID');
    validateMeetingResponse = await http.post(validateMeetingUrl, headers: {
      "Authorization": _token,
    });
    notifyListeners();
  }
}
