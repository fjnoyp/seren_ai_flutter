// Copy this template: `cp lib/app_config_template.dart lib/app_config.dart`
// Edit lib/app_config.dart and enter your Supabase and PowerSync project details.
class AppConfig {
  static const bool isProdMode = true; // Set to false to use local config

  static String get supabaseUrl => isProdMode
      ? 'https://aunxmivgfpuzxwmyggvn.supabase.co'
      : 'http://127.0.0.1:54321';
  static String get supabaseAnonKey => isProdMode
      ? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1bnhtaXZnZnB1enh3bXlnZ3ZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTgyMjcyMjcsImV4cCI6MjAzMzgwMzIyN30.XNAuj7T-RICJnA2bD3gmSB7OnUx43CwkRZ75iveBfUA'
      : 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xZ21ja3FpenV1c3Rjd3NvbHRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE0NzAwNzksImV4cCI6MjAyNzA0NjA3OX0.WmoWQ5qH50u5wD1sUP6JFQ1jjLzhDhv9SSABx84rVw4';
  static String get powersyncUrl => isProdMode
      ? 'https://66d6dd833580ad8d5099e676.powersync.journeyapps.com'
      : 'http://localhost:8080';
  static const String supabaseStorageBucket =
      ''; // Optional. Only required when syncing attachments and using Supabase Storage. See packages/powersync_attachments_helper.

  static const String langgraphApiKey =
      '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';
  static const String langgraphBaseUrl = isProdMode
      ? 'https://seren-ai-langgraph-e7e8a3983001575f8924a6352b52e0c3.default.us.langgraph.app'
      : 'http://localhost:8123';
}
