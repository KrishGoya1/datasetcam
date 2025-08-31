import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Set<String>> _photoSets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final Directory? extDir = await getExternalStorageDirectory();
      if (extDir == null) {
        throw Exception('Could not get external storage directory.');
      }
      final Directory customDir = Directory('${extDir.path}/Pictures/datasetcam');

      if (await customDir.exists()) {
        final allFiles = customDir.listSync().whereType<File>().toList();
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
      }
    } catch (e) {
      debugPrint('Error loading photos: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dataset Gallery'),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photoSets.isEmpty
              ? const Center(child: Text('No photos found.', style: TextStyle(color: Colors.white)))
              : RefreshIndicator(
                  onRefresh: _loadPhotos,
                  child: GridView.builder(
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
                      return Card(
                        color: Colors.grey[900],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
