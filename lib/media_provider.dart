import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart'; // For temporary file storage
import 'shared_files_provider.dart';
import 'shared_files_screen.dart';

class MediaProvider extends ChangeNotifier {
  PlatformFile? _selectedFile;
  Uint8List? _fileBytes;

  PlatformFile? get selectedFile => _selectedFile;
  Uint8List? get fileBytes => _fileBytes;

 // Method to pick media
 Future<void> pickMedia(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.media);
      if (result != null) {
        final pickedFile = result.files.first;
        
        // Check if file size is within limits (e.g., 5 MB)
        if (pickedFile.size > 5 * 1024 * 1024) {
          // Notify user that file is too large
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File is too large. Please select a file smaller than 5 MB.')),
          );
        } else {
          // File is within size limits, proceed
          _selectedFile = pickedFile;
          _fileBytes = pickedFile.bytes;
          notifyListeners();
        }
      }
    } catch (e) {
      // Handle any other errors that may occur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  // Method to share media
  Future<void> shareMedia(BuildContext context) async {
    if (_selectedFile != null) {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sharing is not supported on Web for this file.')),
        );
      } else {
        try {
          XFile? fileToShare;
          if (_selectedFile!.path != null) {
            fileToShare = XFile(_selectedFile!.path!);
          } else if (_fileBytes != null) {
            final tempDir = await getTemporaryDirectory();
            final file = await File('${tempDir.path}/${_selectedFile!.name}')
                .writeAsBytes(_fileBytes!);
            fileToShare = XFile(file.path);
          }

          if (fileToShare != null) {
            // Share the file
            await Share.shareXFiles([fileToShare], text: 'Check out this media!');

            // Add the shared file path to SharedFilesProvider
            final sharedFilesProvider = Provider.of<SharedFilesProvider>(context, listen: false);
            sharedFilesProvider.addSharedFile(fileToShare.path);

            // Refresh MediaProvider state if necessary
            refreshMedia();

            // Navigate to SharedFilesScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SharedFilesScreen()),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sharing file: $e')),
          );
        }
      }
    }
  }

  // Refresh media list or perform any necessary update
  void refreshMedia() {
  _selectedFile = null;
  _fileBytes = null;
  notifyListeners();
}

}
