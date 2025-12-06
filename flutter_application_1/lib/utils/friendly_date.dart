String friendlyDate(DateTime date) {
final diff = DateTime.now().difference(date);
if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()} yr ago';
if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()} mo ago';
if (diff.inDays >= 1) return '${diff.inDays} days ago';
if (diff.inHours >= 1) return '${diff.inHours} hrs ago';
if (diff.inMinutes >= 1) return '${diff.inMinutes} mins ago';
return 'just now';
}