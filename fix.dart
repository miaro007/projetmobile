import 'dart:io';

void main() {
  final file = File('lib/data/repositories/species_repository_impl.dart');
  final lines = file.readAsLinesSync();
  final part1 = lines.sublist(0, 81);
  final part2 = lines.sublist(266);
  final newContent = [...part1, ...part2].join('\n');
  file.writeAsStringSync(newContent);
}
