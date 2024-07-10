import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestPage extends HookWidget {
  final String? param;

  const TestPage({Key? key, this.param}) : super(key: key);

  Future<void> _invokeFunction(TextEditingController inputController, ValueNotifier<String> response) async {
    final input = inputController.text;
    final session = Supabase.instance.client.auth.currentSession;
    final jwtToken = session?.accessToken;

    try {
      final supabaseResponse = await Supabase.instance.client.functions.invoke(
        'chat',
        body: {'input': input},
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );
      response.value = supabaseResponse.data.toString();
    } catch (error, stackTrace) {
      response.value = 'Error: ${error.toString()}\nStackTrace: ${stackTrace.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputController = useTextEditingController();
    final response = useState('');

    return Scaffold(
      appBar: AppBar(
        title: Text('Test Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: inputController,
              decoration: InputDecoration(labelText: 'Input'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _invokeFunction(inputController, response),
              child: Text('Invoke Function'),
            ),
            SizedBox(height: 16),
            Text('Response: ${response.value}'),
          ],
        ),
      ),
    );
  }
}
