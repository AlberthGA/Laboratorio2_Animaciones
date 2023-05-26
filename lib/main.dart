import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/image_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';


void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lorem Picsum Images',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ImageScreen(),
    );
  }
}
class ImageScreen extends StatefulWidget {
  @override
  _ImageScreenState createState() => _ImageScreenState();
}



class _ImageScreenState extends State<ImageScreen> {
  final ApiService apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  List<ImageModel> _images = [];
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
          await apiService.fetchImages(_currentPage);
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
      ),
      // implement the masonry layout
      body: MasonryGridView.count(
        controller: _scrollController,
        itemCount: _images.length + 1,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
        // the number of columns
        crossAxisCount: 3,
        // vertical gap between two items
        mainAxisSpacing: 4,
        // horizontal gap between two items
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          if (index < _images.length) {
            final image = _images[index];
            return Card(
              // Replace the color with an image
              child: CachedNetworkImage(
                imageUrl: image.imageUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            );
          } else if (_isLoading) {
            return Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}


