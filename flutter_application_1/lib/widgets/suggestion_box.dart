import 'package:flutter/material.dart';


class SuggestionBox extends StatelessWidget {
final List<String> suggestions;
final ValueChanged<String> onSelect;
const SuggestionBox({super.key, required this.suggestions, required this.onSelect});


@override
Widget build(BuildContext context) {
if (suggestions.isEmpty) return const SizedBox.shrink();
return SizedBox(
height: 48,
child: ListView.separated(
scrollDirection: Axis.horizontal,
itemBuilder: (context, index) {
final s = suggestions[index];
return GestureDetector(
onTap: () => onSelect(s),
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
margin: const EdgeInsets.only(left: 8),
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
child: Center(child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600))),
),
);
},
separatorBuilder: (_, __) => const SizedBox(width: 6),
itemCount: suggestions.length,
),
);
}
}