import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:datasetcam/widgets/skeuomorphic_container.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Set<String>> _photoSets = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (!mounted) return;

    // Add a small delay to give the file system a moment to update after a deletion.
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final Directory? extDir = await getExternalStorageDirectory();
      if (extDir == null) {
        throw Exception('Could not get external storage directory.');
      }
      final Directory customDir = Directory('${extDir.path}/Pictures/datasetcam');

      if (await customDir.exists()) {
        final allFiles = customDir.listSync().whereType<File>().toList();
        
        // Sort files by name to ensure consistent and complete loading
        allFiles.sort((a, b) => path.basename(a.path).compareTo(path.basename(b.path)));
        
        final Map<String, List<String>> fileMap = {};

        for (var file in allFiles) {
          final fileName = path.basename(file.path);
          final parts = fileName.split('_');
          if (parts.length == 2 && parts[0].isNotEmpty) {
            final setNumber = parts[0];
            fileMap.putIfAbsent(setNumber, () => []).add(file.path);
          }
        }

        final List<Set<String>> tempSets = fileMap.values.where((list) => list.length >= 2).map((list) => list.toSet()).toList();

        setState(() {
          _photoSets = tempSets;
        });
      } else {
        setState(() {
          _photoSets = [];
        });
      }
    } catch (e) {
      debugPrint('Error loading photos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dataset Gallery'),
        backgroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPhotos,
        child: _photoSets.isEmpty
            ? const Center(child: Text('No photos found.', style: TextStyle(color: Colors.white)))
            : GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: _photoSets.length,
                itemBuilder: (context, index) {
                  final set = _photoSets[index];
                  return SkeuomorphicContainer(
                    padding: const EdgeInsets.all(8.0),
                    borderRadius: BorderRadius.circular(15.0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                      children: set.map((filePath) {
                        return Image.file(
                          File(filePath),
                          fit: BoxFit.cover,
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
      ),
    );
  }
}