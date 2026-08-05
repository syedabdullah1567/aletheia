import 'package:aletheia/data/palimora_database.dart';
import 'package:flutter/material.dart';

class ViewLogsPage extends StatefulWidget {
  const ViewLogsPage({super.key});

  @override
  State<ViewLogsPage> createState() => _ViewLogsPageState();
}

class _ViewLogsPageState extends State<ViewLogsPage> {
  PalimoraDatabase db = PalimoraDatabase();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    setState(() {
      db.loadData(0); // HASLOGGED
      db.loadData(1); // MOODS
      db.loadData(2); // SLEEP
      db.loadData(3); // PILLARRATINGS
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Reload Data',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Logged Status Flag
          Card(
            child: ListTile(
              leading: Icon(
                db.hasLogged ? Icons.check_circle : Icons.cancel,
                color: db.hasLogged ? Colors.green : Colors.grey,
              ),
              title: const Text('Has Logged Today?'),
              subtitle: Text('HASLOGGED: ${db.hasLogged}'),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Moods List
          const Text(
            'Logged Moods',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (db.moods.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No mood records found.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...db.moods.entries.map(
              (entry) => Card(
                child: ListTile(
                  leading: const Icon(Icons.mood),
                  title: Text('Mood: ${entry.value}'),
                  subtitle: Text('Timestamp: ${entry.key}'),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // 3. Sleep Logs List (ADDED)
          const Text(
            'Logged Sleep Records',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (db.sleep.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No sleep records found.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...db.sleep.entries.map((entry) {
              final hours = entry.value['hoursSlept'] ?? 0.0;
              final quality = entry.value['qualityOfSleep'] ?? 0.0;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bedtime, color: Colors.indigo),
                          const SizedBox(width: 8),
                          Text(
                            'Timestamp: ${entry.key}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Hours Slept:'),
                          Text(
                            '${hours.toStringAsFixed(1)} hrs',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Quality of Sleep:'),
                          Text(
                            '${quality.toStringAsFixed(1)} / 5.0',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),

          // 4. Pillar Ratings List
          const Text(
            'Logged Pillar Ratings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (db.pillarRatings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No pillar rating records found.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...db.pillarRatings.entries.map(
              (entry) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timestamp: ${entry.key}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      ...entry.value.entries.map(
                        (pillar) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(pillar.key.toUpperCase()),
                              Text(
                                '${pillar.value} / 5.0',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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
}
