import 'dart:io';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfDownloadService {
  static Future<String?> downloadPdf({
    required String pdfUrl,
    required String fileName,
  }) async {
    final response = await http.get(Uri.parse(pdfUrl));

    if (response.statusCode != 200) {
      throw Exception('Impossible de télécharger le PDF');
    }

    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/$fileName';

    final file = File(tempPath);
    await file.writeAsBytes(response.bodyBytes);

    final params = SaveFileDialogParams(
      sourceFilePath: tempPath,
      fileName: fileName,
      mimeTypesFilter: const ['application/pdf'],
    );

    return await FlutterFileDialog.saveFile(params: params);
  }
}