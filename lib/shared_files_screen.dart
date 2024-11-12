import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'shared_files_provider.dart';
import 'media_share_screen.dart';

class SharedFilesScreen extends StatefulWidget {
  @override
  _SharedFilesScreenState createState() => _SharedFilesScreenState();
}

class _SharedFilesScreenState extends State<SharedFilesScreen> {
  final List<VideoPlayerController> _videoControllers = [];
  int? _playingIndex;  // Track the currently playing video index

  @override
  void initState() {
    super.initState();
    _initializeVideoControllers();
  }

  // Initialize controllers for video files
  void _initializeVideoControllers() {
    final sharedFilesProvider = Provider.of<SharedFilesProvider>(context, listen: false);
    final sharedFiles = sharedFilesProvider.sharedFiles;

    // Clear existing video controllers before adding new ones
    _videoControllers.clear();

    for (String filePath in sharedFiles) {
      if (filePath.endsWith('.mp4')) {
        final controller = VideoPlayerController.file(File(filePath));
        controller.initialize().then((_) {
          setState(() {}); // Update the UI after initialization
        });
        _videoControllers.add(controller);
      }
    }
  }

  @override
  void dispose() {
    // Dispose video controllers properly
    for (VideoPlayerController controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Method to handle video play/pause on tap
  void _togglePlayPause(int index) {
    final controller = _videoControllers[index];
    if (_playingIndex == index) {
      // Pause the video if it's already playing
      controller.pause();
      setState(() {
        _playingIndex = null;  // Reset the index to indicate no video is playing
      });
    } else {
      // Pause any currently playing video
      if (_playingIndex != null) {
        _videoControllers[_playingIndex!].pause();
      }
      // Play the selected video
      controller.play();
      setState(() {
        _playingIndex = index;  // Set the index of the currently playing video
      });
    }
  }

  // Clear all shared files and reset controllers
  void _clearAllFiles() {
    final sharedFilesProvider = Provider.of<SharedFilesProvider>(context, listen: false);
    
    // Clear shared files in the provider
    sharedFilesProvider.clearFiles();
    
    // Dispose of all video controllers and clear the list
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    _videoControllers.clear();
    
    setState(() {
      _playingIndex = null; // Reset any playing video index
    });
  }

  @override
  Widget build(BuildContext context) {
    final sharedFilesProvider = Provider.of<SharedFilesProvider>(context);
    final sharedFiles = sharedFilesProvider.sharedFiles;

    return Scaffold(
      appBar: AppBar(
        title: Text('Shared Files'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            sharedFiles.isNotEmpty
                ? Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: sharedFiles.length,
                      itemBuilder: (context, index) {
                        String filePath = sharedFiles[index];
                        if (filePath.endsWith('.mp4')) {
                          final controller = _videoControllers[index];
                          return GestureDetector(
                            onTap: () => _togglePlayPause(index),  // Play/Pause on tap
                            child: AspectRatio(
                              aspectRatio: controller.value.isInitialized
                                  ? controller.value.aspectRatio
                                  : 16 / 9,
                              child: controller.value.isInitialized
                                  ? VideoPlayer(controller)
                                  : Center(child: CircularProgressIndicator()),
                            ),
                          );
                        } else {
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
            SizedBox(height: 10),
            if (sharedFiles.isNotEmpty) 
            ElevatedButton.icon(
              onPressed: _clearAllFiles,
              icon: Icon(Icons.delete),
              label: Text('Clear All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
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
