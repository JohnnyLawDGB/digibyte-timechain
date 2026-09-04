import 'package:flutter_test/flutter_test.dart';
import 'package:digibyte_timechain/data/sse_parser.dart';

void main() {
  test('groups event/data lines into events on the blank line', () async {
    final lines = Stream.fromIterable(['event: tip', 'data: {"h":1}', '', 'event: ping', 'data: {"t":2}', '', ': comment', 'data: no-event', '']);
    final out = await parseSse(lines).toList();
    expect(out.map((e) => '${e.event}|${e.data}'), ['tip|{"h":1}', 'ping|{"t":2}', 'message|no-event']);
  });
  test('joins multi-line data with newlines and tolerates CR', () async {
    final out = await parseSse(Stream.fromIterable(['data: a\r', 'data: b', '', ''])).toList();
    expect(out.single.data, 'a\nb');
  });
}
