import 'package:flutter/material.dart';

import '../data/event_repository.dart';
import '../domain/event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventRepository _repository = EventRepositoryImpl();
  late Future<List<EventItem>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _repository.fetchFeaturedEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BoraLá'),
      ),
      body: FutureBuilder<List<EventItem>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Não foi possível carregar os eventos.'));
          }

          final events = snapshot.data ?? const <EventItem>[];

          if (events.isEmpty) {
            return const Center(child: Text('Nenhum evento encontrado.'));
          }

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'BoraLá',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(event.name),
                        subtitle: Text('${event.location} • ${event.category}'),
                        trailing: event.isPopular ? const Icon(Icons.star, color: Colors.amber) : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
