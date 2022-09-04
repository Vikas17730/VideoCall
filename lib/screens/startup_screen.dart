// ignore_for_file: non_constant_identifier_names, dead_code

import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:videosdk_flutter_example/providers/auth_provider.dart';
import 'package:videosdk_flutter_example/providers/join_meeting_provider.dart';

import '../constants/colors.dart';
import '../utils/spacer.dart';
import '../utils/toast.dart';
import 'join_screen.dart';
import 'meeting_screen.dart';

// Startup Screen
class StartupScreen extends StatefulWidget {
  StartupScreen({required this.user, Key? key}) : super(key: key);
  final String user;
  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  String _token = "";
  String _meetingID = "";

  final ButtonStyle _buttonStyle = TextButton.styleFrom(
    primary: Colors.white,
    backgroundColor: primaryColor,
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token =
          await Provider.of<AuthProvider>(context, listen: false).fetchToken();
      setState(() => _token = token);
      log(widget.user);
    });
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VideoSDK RTC"),
        actions: [
          if (widget.user.length != 0)
            CircleAvatar(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.user,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      backgroundColor: secondaryColor,
      body: SafeArea(
        child: _token.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    HorizontalSpacer(12),
                    Text("Initialization"),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: _buttonStyle,
                    onPressed: onCreateMeetingButtonPressed,
                    child: const Text("CREATE MEETING"),
                  ),
                  const VerticalSpacer(20),
                  const Text(
                    "OR",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const VerticalSpacer(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: TextField(
                      onChanged: (meetingID) => _meetingID = meetingID,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        fillColor: Theme.of(context).primaryColor,
                        labelText: "Enter Meeting ID",
                        hintText: "Meeting ID",
                        prefixIcon: const Icon(
                          Icons.keyboard,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const VerticalSpacer(20),
                  TextButton(
                    onPressed: onJoinMeetingButtonPressed,
                    style: _buttonStyle,
                    child: const Text("JOIN MEETING"),
                  )
                ],
              ),
      ),
    );
  }

  Future<void> onCreateMeetingButtonPressed() async {
    final String? _VIDEOSDK_API_ENDPOINT = dotenv.env['VIDEOSDK_API_ENDPOINT'];

    final Uri getMeetingIdUrl = Uri.parse('$_VIDEOSDK_API_ENDPOINT/meetings');
    final http.Response meetingIdResponse =
        await http.post(getMeetingIdUrl, headers: {
      "Authorization": _token,
    });

    _meetingID = json.decode(meetingIdResponse.body)['meetingId'];

    log("Meeting ID: $_meetingID");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingScreen(
          token: _token,
          meetingId: _meetingID,
          displayName: "VideoSDK User",
        ),
      ),
    );
  }

  Future<void> onJoinMeetingButtonPressed() async {
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
}
