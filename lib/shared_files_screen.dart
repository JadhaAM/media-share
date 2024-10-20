import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart'; // Import video player
import 'media_share_screen.dart';

class SharedFilesScreen extends StatefulWidget {
  final List<String> sharedFiles; // List of file paths shared by the user

  SharedFilesScreen({required this.sharedFiles});

  @override
  _SharedFilesScreenState createState() => _SharedFilesScreenState();
}

class _SharedFilesScreenState extends State<SharedFilesScreen> {
  List<VideoPlayerController> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize video controllers for each video file
    for (String filePath in widget.sharedFiles) {
      if (filePath.endsWith('.mp4')) {
        _videoControllers.add(VideoPlayerController.file(File(filePath))
          ..initialize().then((_) {
            setState(() {}); // Ensure UI updates after initialization
            _videoControllers.last.play(); // Play the video when initialized
          }));
      }
    }
  }

  @override
  void dispose() {
    // Dispose of video controllers
    for (VideoPlayerController controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shared Files'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            widget.sharedFiles.isNotEmpty
                ? Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: widget.sharedFiles.length,
                      itemBuilder: (context, index) {
                        String filePath = widget.sharedFiles[index];
                        if (filePath.endsWith('.mp4')) {
                          // Display video file
                          return _videoControllers[index].value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: _videoControllers[index]
                                      .value
                                      .aspectRatio,
                                  child: VideoPlayer(_videoControllers[index]),
                                )
                              : CircularProgressIndicator(); // Show loader while the video is initializing
                        } else {
                          // Display image file
                          return Image.file(File(filePath), fit: BoxFit.cover);
                        }
                      },
                    ),
                  )
                : Expanded(
                    child: Center(
                      child: Text(
                        'No files shared yet.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MediaShareScreen()),
                );
              },
              icon: Icon(Icons.send),
              label: Text('Send More'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
