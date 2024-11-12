import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'media_provider.dart';
import 'shared_files_provider.dart';

class MediaShareScreen extends StatefulWidget {
  @override
  _MediaShareScreenState createState() => _MediaShareScreenState();
}

class _MediaShareScreenState extends State<MediaShareScreen> {
  VideoPlayerController? _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider = Provider.of<MediaProvider>(context);
    final sharedFilesProvider =
        Provider.of<SharedFilesProvider>(context, listen: false);
    final selectedFile = mediaProvider.selectedFile;
    final fileBytes = mediaProvider.fileBytes;

    return Scaffold(
      appBar: AppBar(
        title: Text('Media Share'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            selectedFile != null
                ? selectedFile.extension == 'mp4'
                    ? _videoPlayerController != null &&
                            _videoPlayerController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio:
                                _videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController!),
                          )
                        : Center(child: CircularProgressIndicator())
                    : kIsWeb
                        ? fileBytes != null
                            ? Image.memory(fileBytes, height: 200)
                            : Text('Error loading file')
                        : selectedFile.path != null
                            ? Image.file(File(selectedFile.path!), height: 200)
                            : Text('Error loading file')
                : Text(
                    'Select an image or video to preview!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await mediaProvider.pickMedia(context);

                // Check if a file was selected and if it's within the size limit
                if (mediaProvider.selectedFile != null &&
                    mediaProvider.selectedFile!.size <= 5 * 1024 * 1024) {
                  final selectedFile = mediaProvider.selectedFile;

                  // Add to shared files if within size limits
                  sharedFilesProvider.addSharedFile(selectedFile!.path!);

                  // Initialize video player if the selected file is a video and not on the web
                  if (!kIsWeb && selectedFile.extension == 'mp4') {
                    try {
                      if (_videoPlayerController == null ||
                          _videoPlayerController!.dataSource !=
                              selectedFile.path) {
                        _videoPlayerController =
                            VideoPlayerController.file(File(selectedFile.path!))
                              ..initialize().then((_) {
                                setState(() {});
                                _videoPlayerController!.play();
                              }).catchError((e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error initializing video: $e')),
                                );
                              });
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error loading video: $e')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'File is too large. Please select a file smaller than 5 MB.')),
                  );
                }
              },
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
            selectedFile != null
                ? ElevatedButton.icon(
                    onPressed: () async {
                      await mediaProvider.shareMedia(context);
                    },
                    icon: Icon(Icons.share),
                    label: Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
