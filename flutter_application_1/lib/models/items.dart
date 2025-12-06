class Item {
final int id;
final String type; // 'lost' or 'found'
final String title;
final String location;
final DateTime date;
final String description;
final String imageUrl;
final String contact;
final String postedBy;


Item({
required this.id,
required this.type,
required this.title,
required this.location,
required this.date,
required this.description,
required this.imageUrl,
required this.contact,
required this.postedBy,
});
}