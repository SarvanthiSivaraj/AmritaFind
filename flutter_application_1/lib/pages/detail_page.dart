import 'package:flutter/material.dart';
import '../models/items.dart';
import '../utils/friendly_date.dart';


class DetailPage extends StatelessWidget {
final Item item;
const DetailPage({super.key, required this.item});


@override
Widget build(BuildContext context) {
return Scaffold(
body: Column(children: [
Stack(children: [
Image.network(item.imageUrl, width: double.infinity, height: 280, fit: BoxFit.cover),
Positioned(top: 40, left: 16, child: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.95), child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)))),
]),
Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
const SizedBox(height: 12),
Row(children: [const Icon(Icons.place), const SizedBox(width: 8), Text(item.location)]),
const SizedBox(height: 8),
Row(children: [const Icon(Icons.calendar_today), const SizedBox(width: 8), Text(friendlyDate(item.date))]),
const SizedBox(height: 16),
Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF0F7F9), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8), Text(item.description)])),
const SizedBox(height: 12),
Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Posted By', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text(item.postedBy), const SizedBox(height: 4), Text(item.contact, style: const TextStyle(color: Colors.grey))])),
const SizedBox(height: 16),
Row(children: [
Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.message), label: const Text('Chat Now'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)))),
const SizedBox(width: 12),
ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF0F3F7), padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Icon(Icons.call, color: Colors.black))
])
])))
]),
);
}
}