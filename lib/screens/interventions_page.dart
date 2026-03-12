import 'package:flutter/material.dart';

class InterventionsPage extends StatefulWidget {
  const InterventionsPage({super.key});

  @override
  State<InterventionsPage> createState() => _InterventionsPageState();
}

class _InterventionsPageState extends State<InterventionsPage> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> allItems = [
    {
      'id': 'D-101',
      'title': 'Panne fibre - Client A',
      'status': 'En cours',
      'priority': 'Haute',
    },
    {
      'id': 'D-102',
      'title': 'Installation modem - Client B',
      'status': 'En attente',
      'priority': 'Moyenne',
    },
    {
      'id': 'D-103',
      'title': 'Coupure ligne - Client C',
      'status': 'Terminée',
      'priority': 'Basse',
    },
    {
      'id': 'D-104',
      'title': 'Problème routeur - Client D',
      'status': 'En cours',
      'priority': 'Haute',
    },
  ];

  List<Map<String, String>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(allItems);
  }

  void filterItems(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        filteredItems = List.from(allItems);
      } else {
        filteredItems = allItems.where((item) {
          final id = item['id']!.toLowerCase();
          final title = item['title']!.toLowerCase();
          final status = item['status']!.toLowerCase();
          final priority = item['priority']!.toLowerCase();
          final search = query.toLowerCase();

          return id.contains(search) ||
              title.contains(search) ||
              status.contains(search) ||
              priority.contains(search);
        }).toList();
      }
    });
  }

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute':
        return Colors.red;
      case 'moyenne':
        return Colors.orange;
      case 'basse':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes interventions'),
        backgroundColor: const Color(0xFF4E6CF1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: searchController,
              onChanged: filterItems,
              decoration: InputDecoration(
                hintText: 'Rechercher une intervention...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          filterItems('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune intervention trouvée',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color(0xFF4E6CF1).withOpacity(0.12),
                            child: const Icon(
                              Icons.assignment_outlined,
                              color: Color(0xFF4E6CF1),
                            ),
                          ),
                          title: Text(
                            item['id']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['title']!),
                                const SizedBox(height: 6),
                                Text('Statut : ${item['status']}'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text('Priorité : '),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getPriorityColor(
                                          item['priority']!,
                                        ).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        item['priority']!,
                                        style: TextStyle(
                                          color: getPriorityColor(
                                            item['priority']!,
                                          ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ouvrir ${item['id']}'),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}