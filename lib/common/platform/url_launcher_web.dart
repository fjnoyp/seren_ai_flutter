import 'dart:html' as html;

class UrlLauncher {
  static void downloadFile(String url, String fileName) {
    // Create an anchor element to trigger download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none'
      ..target = '_blank';

    // Add to document body and trigger click
    html.document.body!.children.add(anchor);
    anchor.click();

    anchor.remove();
  }
}
