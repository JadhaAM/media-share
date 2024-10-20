import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart'; // For video preview
import 'dart:io'; // For handling files
import 'dart:typed_data'; // For handling file bytes
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:image_picker/image_picker.dart'; // For XFile

class MediaShareScreen extends StatefulWidget {
  @override
  _MediaShareScreenState createState() => _MediaShareScreenState();
}

class _MediaShareScreenState extends State<MediaShareScreen> {
  PlatformFile? _selectedFile;
  Uint8List? _fileBytes;
  VideoPlayerController? _videoPlayerController; // Controller for video player

  Future<void> _pickMedia() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        _fileBytes = result.files.first.bytes;
      });

      // If it's a video file and we're not on the web, initialize the video player
      if (!kIsWeb && _selectedFile!.extension == 'mp4') {
        _videoPlayerController = VideoPlayerController.file(File(_selectedFile!.path!))
          ..initialize().then((_) {
            setState(() {}); // Ensure UI updates after initialization
            _videoPlayerController!.play();
          });
      }

      // Save the image or video to the gallery on mobile platforms
     
    }
  }

  void _shareMedia() {
    if (_selectedFile != null) {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sharing is not supported on Web for this file.')),
        );
      } else {
        XFile fileToShare = XFile(_selectedFile!.path!);
        Share.shareXFiles([fileToShare], text: 'Check out this media!');
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose(); // Dispose of the video player controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Media Share'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedFile != null
                ? _selectedFile!.extension == 'mp4'
                    ? _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController!),
                          )
                        : CircularProgressIndicator() // Show loader while the video is initializing
                    : kIsWeb
                        ? Image.memory(_fileBytes!, height: 200)
                        : Image.file(File(_selectedFile!.path!), height: 200)
                : Text(
                    'Select an image or video to preview!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickMedia,
              icon: Icon(Icons.file_upload),
              label: Text('Pick Media'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            _selectedFile != null
                ? ElevatedButton.icon(
                    onPressed: _shareMedia,
                    icon: Icon(Icons.share),
                    label: Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
