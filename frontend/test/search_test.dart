import 'package:flutter_test/flutter_test.dart';
import 'package:bora_la/features/search/data/search_repository.dart';

void main() {
  test('search filters events by keyword', () async {
    final repository = SearchRepository();

    final results = await repository.searchEvents('música');

    expect(results, isNotEmpty);
    expect(results.first.name.toLowerCase().contains('música'), isTrue);
  });
}
