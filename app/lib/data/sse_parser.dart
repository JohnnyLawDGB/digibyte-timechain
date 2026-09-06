class SseEvent {
  const SseEvent(this.event, this.data);
  final String event;
  final String data;
  @override
  String toString() => 'SseEvent($event, $data)';
}

/// Minimal text/event-stream parser over a stream of lines (CR/LF already split).
Stream<SseEvent> parseSse(Stream<String> lines) async* {
  var event = 'message';
  final data = <String>[];
  await for (final raw in lines) {
    final line = raw.endsWith('\r') ? raw.substring(0, raw.length - 1) : raw;
    if (line.isEmpty) {
      if (data.isNotEmpty) yield SseEvent(event, data.join('\n'));
      event = 'message'; data.clear();
      continue;
    }
    if (line.startsWith(':')) continue;
    final idx = line.indexOf(':');
    final field = idx < 0 ? line : line.substring(0, idx);
    var value = idx < 0 ? '' : line.substring(idx + 1);
    if (value.startsWith(' ')) value = value.substring(1);
    if (field == 'event') event = value;
    if (field == 'data') data.add(value);
  }
  if (data.isNotEmpty) yield SseEvent(event, data.join('\n'));
}
