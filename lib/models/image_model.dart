class ImageModel {
  final String imageUrl;


  ImageModel({required this.imageUrl});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      imageUrl: json['download_url']
    );
  }
}
