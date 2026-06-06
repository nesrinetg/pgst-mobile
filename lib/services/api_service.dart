import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'connect_api.dart';
import '../models/intervention_pointer.dart';
import '../models/kpi_data.dart';

class RapportResult {
  final int? rapportId;
  final String? pdfUrl;

  RapportResult({
    this.rapportId,
    this.pdfUrl,
  });
}

class ApiService {
  // ─────────────────────────────────────────────
  // HELPERS PRIVÉS
  // ─────────────────────────────────────────────

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _headers({bool withToken = true}) async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (withToken && token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  String _extractError(String body, int statusCode) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        if (data['message'] != null) return data['message'].toString();
        if (data['error'] != null) return data['error'].toString();
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstValue = errors.values.first;
            if (firstValue is List && firstValue.isNotEmpty) {
              return firstValue.first.toString();
            }
            return firstValue.toString();
          }
        }
      }
      return 'Request failed with status $statusCode';
    } catch (_) {
      return 'Request failed with status $statusCode';
    }
  }

  /// Décode le base64, écrit le PDF localement et l'ouvre avec le lecteur natif
  Future<void> _savePdfLocally({
    required String base64Str,
    required String fileName,
  }) async {
    final bytes = base64Decode(base64Str);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    debugPrint('PDF sauvegardé : ${file.path}');
    await OpenFilex.open(file.path);
  }

  // ─────────────────────────────────────────────
  // AUTH & USER
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse(ConnectApi.url('/user')),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        if (data['user'] is Map<String, dynamic>) return data['user'];
        return data;
      }
      throw Exception('Invalid user response format');
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }

  Future<void> logoutRequest() async {
    final response = await http.post(
      Uri.parse(ConnectApi.url('/logout')),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, response.statusCode));
    }
  }

  Future<void> clearLocalToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ─────────────────────────────────────────────
  // INTERVENTIONS
  // ─────────────────────────────────────────────

  Future<List<InterventionPointer>> getMapPointers() async {
    final response = await http.get(
      Uri.parse(ConnectApi.url('/interventions/map-pointers')),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] ?? [];
      return list.map((item) => InterventionPointer.fromJson(item)).toList();
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }

  Future<List<dynamic>> getInterventions({
    String? query,
    String? statut,
    int limit = 20,
  }) async {
    final params = <String, String>{'limit': limit.toString()};

    if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();
    if (statut != null && statut.trim().isNotEmpty && statut != 'all') {
      params['statut'] = statut.trim();
    }

    final uri = Uri.parse(ConnectApi.url('/interventions'))
        .replace(queryParameters: params);

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data['data'] is List) return data['data'];
      if (data is List) return data;
      throw Exception('Invalid interventions response format');
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }

  Future<int> getNonTraiteCount() async {
    final response = await http.get(
      Uri.parse(ConnectApi.url('/interventions/count-non-traite')),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }

  // ─────────────────────────────────────────────
  // RÉCLAMATIONS
  // ─────────────────────────────────────────────

  Future<void> startReclamation(int id) async {
    final response = await http.post(
      Uri.parse(ConnectApi.url('/reclamations/$id/start')),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, response.statusCode));
    }
  }

  Future<void> finishReclamation(int id) async {
    final response = await http.post(
      Uri.parse(ConnectApi.url('/reclamations/$id/finish')),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, response.statusCode));
    }
  }

  Future<void> reportProblem(int id, String motif) async {
    final response = await http.post(
      Uri.parse(ConnectApi.url('/reclamations/$id/report-problem')),
      headers: await _headers(),
      body: jsonEncode({'motif': motif}),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, response.statusCode));
    }
  }

  // ─────────────────────────────────────────────
  // RAPPORTS — UPLOAD PHOTO (intervention finie)
  // ─────────────────────────────────────────────

  /// Envoie la photo au backend → reçoit le PDF en base64 → sauvegarde + ouvre
  Future<int> uploadReclamationPhoto(
    int reclamationId,
    String imagePath,
  ) async {
    final token = await _getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ConnectApi.url('/rapports/fini')),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });

    request.fields['reclamation_id'] = reclamationId.toString();
    request.files.add(await http.MultipartFile.fromPath('photo', imagePath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      debugPrint('PHOTO RESPONSE = $data');

      // Sauvegarder + ouvrir le PDF reçu
      if (data['pdf_base64'] != null && data['pdf_nom'] != null) {
        await _savePdfLocally(
          base64Str: data['pdf_base64'],
          fileName: data['pdf_nom'],
        );
      }

      final rapportId = int.tryParse(data['rapport_id'].toString()) ?? 0;
      if (rapportId <= 0) {
        throw Exception('rapport_id invalide: ${data['rapport_id']}');
      }
      return rapportId;
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }

  // ─────────────────────────────────────────────
  // RAPPORTS — ANNULATION (problème signalé)
  // ─────────────────────────────────────────────

  /// Envoie le motif → reçoit le PDF en base64 → sauvegarde + ouvre
  Future<RapportResult> sendAnnulationReport({
    required int reclamationId,
    required String motif,
    String impact = '',
    String actions = '',
  }) async {
    final response = await http.post(
      Uri.parse(ConnectApi.url('/rapports/annulation')),
      headers: await _headers(),
      body: jsonEncode({
        'reclamation_id': reclamationId,
        'motif': motif,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      // Sauvegarder + ouvrir le PDF reçu
      if (data['pdf_base64'] != null && data['pdf_nom'] != null) {
        await _savePdfLocally(
          base64Str: data['pdf_base64'],
          fileName: data['pdf_nom'],
        );
      }

      return RapportResult(
        rapportId: int.tryParse(data['rapport_id'].toString()),
        pdfUrl: null,
      );
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }

  // ─────────────────────────────────────────────
  // RAPPORTS — UPLOAD PDF GÉNÉRÉ CÔTÉ MOBILE
  // ─────────────────────────────────────────────

  Future<int> uploadGeneratedPdfToDatabase({
    required int reclamationId,
    required String motif,
    required String statut,
    required String pdfPath,
  }) async {
    final token = await _getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ConnectApi.url('/rapports/upload-mobile')),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });

    request.fields['id_reclamation'] = reclamationId.toString();
    request.fields['motif'] = motif;
    request.fields['statut'] = statut;
    request.files.add(await http.MultipartFile.fromPath('pdf', pdfPath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return int.tryParse(data['rapport_id'].toString()) ?? 0;
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }

  Future<Map<String, dynamic>> getRapportInfo(int rapportId) async {
    final response = await http.get(
      Uri.parse(ConnectApi.url('/rapports/$rapportId')),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) return data;
      throw Exception('Invalid rapport response format');
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }

  // ─────────────────────────────────────────────
  // NOTIFICATIONS
  // ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSimpleNotifications() async {
    final response = await http.get(
      Uri.parse(ConnectApi.url('/simple-notifications')),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] ?? [];
      return list.map((item) => {
        'title': item['title'],
        'body': item['body'],
      }).toList();
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }

  // ─────────────────────────────────────────────
  // KPI
  // ─────────────────────────────────────────────

  Future<KpiData> getKpi({required String period}) async {
    final response = await http.get(
      Uri.parse(ConnectApi.url('/kpi'))
          .replace(queryParameters: {'period': period}),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('KPI RESPONSE = $data');
      return KpiData.fromJson(data);
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }

  Future<Map<String, dynamic>> getDailyStats({required String period}) async {
    final response = await http.get(
      Uri.parse(ConnectApi.url('/kpi/daily-stats'))
          .replace(queryParameters: {'period': period}),
      headers: await _headers(),
    );

    if (response.statusCode == 200) return jsonDecode(response.body);

    throw Exception(_extractError(response.body, response.statusCode));
  }

  Future<String?> downloadKpiPdf({required String period}) async {
    final response = await http.get(
      Uri.parse(ConnectApi.url('/kpi/report'))
          .replace(queryParameters: {'period': period}),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pdf_url']?.toString();
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }

  // ─────────────────────────────────────────────
  // MODE SOUS-TRAITANT
  // ─────────────────────────────────────────────

  Future<String> setVacationMode() async {
    final response = await http.post(
      Uri.parse(ConnectApi.url('/subcontractor/vacation')),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status']?.toString() ?? 'inactive';
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }

  Future<String> setActiveMode() async {
    final response = await http.post(
      Uri.parse(ConnectApi.url('/subcontractor/active')),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status']?.toString() ?? 'active';
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }
  Future<Map<String, dynamic>> getNotifications() async {
  final response = await http.get(
    Uri.parse(ConnectApi.url('/notifications')),
    headers: await _headers(),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(_extractError(response.body, response.statusCode));
}

Future<void> markAllNotificationsRead() async {
  await http.post(
    Uri.parse(ConnectApi.url('/notifications/read-all')),
    headers: await _headers(),
  );
}
}