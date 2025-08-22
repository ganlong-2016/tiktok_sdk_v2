import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ph_picker_view_controller/ph_picker_view_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_sdk_login_share/tiktok_sdk_login_share.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TikTokSDK.instance.setup(clientKey: 'your_client_key');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String loginResult = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTok SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MediaPickerPage(),
    );
  }
}

class MediaPickerPage extends StatefulWidget {
  const MediaPickerPage({super.key});

  @override
  State<MediaPickerPage> createState() => _MediaPickerPageState();
}

class _MediaPickerPageState extends State<MediaPickerPage> {
  List<String> _selectedMediaUri = [];
  final ImagePicker _picker = ImagePicker();
  final _phPickerViewControllerPlugin = PhPickerViewController();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedMediaUri.add(image.path);
          print('选择的图片 URI: $_selectedMediaUri');
        });
      }
    } catch (e) {
      print('选择图片时出错: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      if (Platform.isIOS) {
        var result = await _phPickerViewControllerPlugin.pick(
          filter: {
            'any': ['videos']
          },
          preferredAssetRepresentationMode:
              PHPickerAssetRepresentationMode.current,
          selection: PHPickerSelection.ordered,
          selectionLimit: 3,
          appendLiveVideos: true,
        );
        result?.forEach((element) {
          print('element: ${element.toString()}');
          _selectedMediaUri.add(element.id ?? '');
        });
      } else {
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(allowMultiple: true, type: FileType.video);

        if (result != null) {
          List<String> files =
              result.files.map((file) => file.identifier ?? '').toList();
          _selectedMediaUri.addAll(files);
        } else {
          // User canceled the picker
        }
      }

      print('选择的视频: $_selectedMediaUri');

      // final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      // if (video != null) {
      //   setState(() {
      //     _selectedMediaUri = video.path;
      //     print('选择的视频 URI: $_selectedMediaUri');
      //   });
      // }
    } catch (e) {
      print('选择视频时出错: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择媒体文件'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedMediaUri != null) ...[
              // if (_selectedMediaUri!.toLowerCase().endsWith('.mp4') ||
              //     _selectedMediaUri!.toLowerCase().endsWith('.mov'))
              //   const Text('已选择视频文件')
              // else
              //   Image.network(
              //     _selectedMediaUri!,
              //     height: 200,
              //     width: 200,
              //     fit: BoxFit.cover,
              //   ),
              const SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await TikTokSDK.instance.login(
                        permissions: {
                          TikTokPermissionType.userInfoBasic,
                          TikTokPermissionType.userInfoProfile,
                          TikTokPermissionType.userInfoStats,
                          // TikTokPermissionType.userSettingList,
                          // TikTokPermissionType.userSettingsUpdate,
                          // TikTokPermissionType.videoList,
                          TikTokPermissionType.videoPublish,
                          TikTokPermissionType.videoUpload,
                        },
                        redirectUri: 'your_redirect_uri',
                        browserAuthEnabled: false,
                      );
                    },
                    child: const Text('登录')),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('选择图片'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _pickVideo,
                  child: const Text('选择视频'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      if (_selectedMediaUri != null) {
                        await TikTokSDK.instance.share(
                            mediaUrls: _selectedMediaUri,
                            isSharingImage: false,
                            greenScreenEnabled: false,
                            redirectURI: 'your_redirect_uri');
                      }
                    },
                    child: const Text('发布')),
                ElevatedButton(onPressed: () {}, child: const Text('上传图片')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
