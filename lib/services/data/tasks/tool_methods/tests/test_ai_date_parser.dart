import 'package:flutter_test/flutter_test.dart';
import 'package:seren_ai_flutter/services/data/tasks/tool_methods/ai_date_parser.dart';

//    flutter test lib/services/data/tasks/tool_methods/tests/ai_date_parser_test.dart
void main() {
  group('AiDateParser', () {
    group('parseIsoIntoLocal', () {
      test('should preserve wall clock time of ISO string in local timezone',
          () {
        // Test case: ISO string representing 1 PM UTC
        final isoString = '2025-03-17T13:00:00';

        final result = AiDateParser.parseIsoIntoLocal(isoString);

        // Verify the result preserves the hour (1 PM)
        expect(result?.hour, 13);
        expect(result?.minute, 0);
        expect(result?.second, 0);

        // Print out more details for debugging
        print('Original ISO: $isoString');
        print('Parsed result: $result');
        print('Result in UTC: ${result?.toUtc()}');
        print('Result isUTC: ${result?.isUtc}');
        print('Local offset: ${DateTime.now().timeZoneOffset}');
      });

      test('should handle null input', () {
        final result = AiDateParser.parseIsoIntoLocal(null);
        expect(result, isNull);
      });

      test('should handle invalid ISO format', () {
        final result = AiDateParser.parseIsoIntoLocal('not-an-iso-date');
        expect(result, isNull);
      });

      test('should handle different times of day', () {
        // Test morning time
        final morningResult =
            AiDateParser.parseIsoIntoLocal('2025-03-17T08:30:00.000Z');
        expect(morningResult?.hour, 8);
        expect(morningResult?.minute, 30);

        // Test afternoon time
        final afternoonResult =
            AiDateParser.parseIsoIntoLocal('2025-03-17T16:45:00.000Z');
        expect(afternoonResult?.hour, 16);
        expect(afternoonResult?.minute, 45);

        // Test midnight
        final midnightResult =
            AiDateParser.parseIsoIntoLocal('2025-03-17T00:00:00.000Z');
        expect(midnightResult?.hour, 0);
        expect(midnightResult?.minute, 0);
      });
    });

    group('parseDateList', () {
      test('should parse list of YYYY/MM/DD date strings', () {
        final dateStrings = [
          '2025/03/17',
          '2025/04/01',
          '2025/12/25',
        ];

        final results = AiDateParser.parseDateList(dateStrings);

        expect(results.length, 3);
        expect(results[0].year, 2025);
        expect(results[0].month, 3);
        expect(results[0].day, 17);

        expect(results[1].year, 2025);
        expect(results[1].month, 4);
        expect(results[1].day, 1);

        expect(results[2].year, 2025);
        expect(results[2].month, 12);
        expect(results[2].day, 25);
      });

      test('should skip invalid date formats', () {
        final dateStrings = [
          '2025/03/17',
          'invalid-date',
          '2025/04/01',
        ];

        final results = AiDateParser.parseDateList(dateStrings);

        expect(results.length, 2);
        expect(results[0].year, 2025);
        expect(results[0].month, 3);
        expect(results[0].day, 17);

        expect(results[1].year, 2025);
        expect(results[1].month, 4);
        expect(results[1].day, 1);
      });
    });
  });
}
