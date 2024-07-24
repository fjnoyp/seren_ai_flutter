// Copy this template: `cp lib/app_config_template.dart lib/app_config.dart`
// Edit lib/app_config.dart and enter your Supabase and PowerSync project details.
class AppConfig {
  static const String supabaseUrl = 'http://127.0.0.1:54321';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xZ21ja3FpenV1c3Rjd3NvbHRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE0NzAwNzksImV4cCI6MjAyNzA0NjA3OX0.WmoWQ5qH50u5wD1sUP6JFQ1jjLzhDhv9SSABx84rVw4';
  static const String powersyncUrl = 'http://localhost:8080';
  static const String supabaseStorageBucket =
      ''; // Optional. Only required when syncing attachments and using Supabase Storage. See packages/powersync_attachments_helper.
}
