import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/pdf_download_service.dart';

class CameraScreen extends StatefulWidget {
  final int reclamationId;

  const CameraScreen({
    super.key,
    required this.reclamationId,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isSaving = false;

  final ApiService _apiService = ApiService();

  static const Color blue = Color(0xFF005BAA);
  static const Color deepBlue = Color(0xFF003B73);
  static const Color green = Color(0xFF2F9E63);
  static const Color textDark = Color(0xFF14213D);

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras == null || cameras!.isEmpty) {
        throw Exception('Aucune caméra trouvée');
      }

      controller = CameraController(
        cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
Future<bool> _isDocumentImage(String imagePath) async {
  final inputImage = InputImage.fromFilePath(imagePath);

  final textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  final recognizedText = await textRecognizer.processImage(inputImage);
  await textRecognizer.close();

  final text = recognizedText.text.trim().toLowerCase();

  debugPrint('TEXT FOUND = $text');

  final words = text
      .split(RegExp(r'\s+'))
      .where((word) => word.trim().length > 2)
      .toList();

  final keywords = [
    'algérie',
    'algerie',
    'telecom',
    'télécom',
    'intervention',
    'reclamation',
    'réclamation',
    'client',
    'ods',
    'rapport',
    'signature',
    'date',
  ];

  final hasEnoughWords = words.length >= 8;

  final hasKeyword = keywords.any(
    (keyword) => text.contains(keyword),
  );

  return hasEnoughWords && hasKeyword;
}  Future<void> _openPdf(String? pdfUrl) async {
    if (pdfUrl == null || pdfUrl.isEmpty) return;

    final uri = Uri.parse(pdfUrl);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible d’ouvrir le PDF');
    }
  }

Future<void> _takeAndUploadPhoto() async 
{
  if (controller == null || !controller!.value.isInitialized) return;

  setState(() {
    isSaving = true;
  });

  try {
    final image = await controller!.takePicture();

    final isDocument = await _isDocumentImage(image.path);

    if (!isDocument) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Photo refusée : veuillez prendre une vraie photo du document.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return; // ✅ STOP TOTAL — no backend call
    }

    final rapportId = await _apiService.uploadReclamationPhoto(
  widget.reclamationId,
  image.path,
);

debugPrint('RAPPORT ID = $rapportId');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo envoyée avec succès 📸')),
    );

   /* if (pdfUrl != null && pdfUrl.isNotEmpty) {
      await PdfDownloadService.downloadPdf(
        pdfUrl: pdfUrl,
        fileName: 'rapport_reclamation_${widget.reclamationId}.pdf',
      );
    }*/

    if (!mounted) return;
    Navigator.pop(context, true);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }
}
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7FAFD),
        body: Center(
          child: CircularProgressIndicator(color: blue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(controller!),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                      Colors.black.withOpacity(0.55),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          _topCameraBar(context),

          _bottomCameraPanel(),

          if (isSaving)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.55),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Envoi de la photo...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _topCameraBar(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, topPadding + 10, 16, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [deepBlue, blue, green],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: deepBlue.withOpacity(0.30),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            _roundButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Caméra',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(width: 14),
            _roundButton(
              icon: Icons.picture_as_pdf_rounded,
              onTap: () {},
              invisible: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomCameraPanel() {
    return Positioned(
      left: 18,
      right: 18,
      bottom: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Prenez une photo claire pour générer le rapport.',
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: isSaving ? null : _takeAndUploadPhoto,
            child: Container(
              width: 86,
              height: 86,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [deepBlue, blue, green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: blue.withOpacity(0.35),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.16),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
    bool invisible = false,
  }) {
    return Opacity(
      opacity: invisible ? 0 : 1,
      child: Material(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: invisible ? null : onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              icon,
              color: Colors.white,
              size: 27,
            ),
          ),
        ),
      ),
    );
  }
}