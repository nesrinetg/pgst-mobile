import 'package:flutter/material.dart';
import 'info_derangement.dart';

class InfoDerangementSheet extends StatelessWidget {
  final String id;
  final String nom;
  final String typeService;
  final String priorite;
  final String statut;
  final String adresse;
  final String clientNom;
  final String clientTelephone;
  final String description;

  const InfoDerangementSheet({
    super.key,
    required this.id,
    required this.nom,
    required this.typeService,
    required this.priorite,
    required this.statut,
    required this.adresse,
    required this.clientNom,
    required this.clientTelephone,
    required this.description,
  });

  static const Color atBlue = Color(0xFF0A5C9F);
  static const Color atGreen = Color(0xFF24A148);
  static const Color textDark = Color(0xFF1E2A35);
  static const Color textSoft = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    nom,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _priorityColor(priorite).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    priorite,
                    style: TextStyle(
                      color: _priorityColor(priorite),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _infoRow('ID', id),
                  _infoRow('Type service', typeService),
                  _infoRow('Statut', statut),
                  _infoRow('Adresse', adresse),
                  _infoRow('Client', clientNom),
                  _infoRow('Téléphone', clientTelephone),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: textSoft,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Formulaire annulation après'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: atBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Caméra confirmation après'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: atGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Confirmer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textSoft,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute':
        return Colors.red;
      case 'moyenne':
        return Colors.orange;
      case 'basse':
        return atGreen;
      default:
        return atBlue;
    }
  }
}