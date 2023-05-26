import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/image_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lorem Picsum Images',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ImageScreen(),
    );
  }
}

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final ApiService apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  String _selectedFilter = 'all';
  final List<ImageModel> _images = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<ImageModel> images =
          await apiService.fetchImages(_currentPage, filter: _selectedFilter);
      setState(() {
        _images.addAll(images);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading images: $e');
    }
  }

  void _scrollListener() {
    if (!_isLoading &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      _loadImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratorio #2'),
        actions: [
          DropdownButton<String>(
            value: _selectedFilter,
            onChanged: (String? newValue) {
              setState(() {
                _selectedFilter = newValue!;
                _images.clear();
                _currentPage = 1;
                _loadImages();
              });
            },
            items: const [
              DropdownMenuItem(
                value: 'all',
                child: Text('All'),
              ),
              DropdownMenuItem(
                value: 'nature',
                child: Text('Nature'),
              ),
              DropdownMenuItem(
                value: 'animals',
                child: Text('Animals'),
              ),
              // Agrega más opciones de filtro si es necesario
            ],
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          int crossAxisCount;
          if (orientation == Orientation.portrait) {
            crossAxisCount = 3;
          } else {
            crossAxisCount = 6;
          }

          return MasonryGridView.count(
            controller: _scrollController,
            itemCount: _images.length + 1,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            itemBuilder: (context, index) {
              if (index < _images.length) {
                final image = _images[index];
                return Card(
                  child: CachedNetworkImage(
                    imageUrl: image.imageUrl,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                );
              } else if (_isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }
}
