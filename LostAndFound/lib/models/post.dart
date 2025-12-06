class Post {
  final String id;
  final String userName;
  final String category;
  final String itemType;
  final String description;
  final String location;
  final String? contactNumber;
  final String imageUrl;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userName,
    required this.category,
    required this.itemType,
    required this.description,
    required this.location,
    this.contactNumber,
    required this.imageUrl,
    required this.createdAt,
  });
}
