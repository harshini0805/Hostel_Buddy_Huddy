import 'package:flutter/material.dart';
import '../models/ticket_models.dart';
import '../services/ticket_service.dart';

class TicketFeedScreen extends StatefulWidget {
  const TicketFeedScreen({super.key});

  @override
  State<TicketFeedScreen> createState() => _TicketFeedScreenState();
}

class _TicketFeedScreenState extends State<TicketFeedScreen> {
  late Future<List<TicketResponse>> _ticketsFuture;
  final Set<String> _votedTickets = {};
  final TicketService _ticketService = TicketService(); // instance of service

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _ticketService.fetchTicketFeed();
  }

  void _vote(String ticketId) async {
    try {
      await _ticketService.voteOnTicket(ticketId);
      setState(() {
        _votedTickets.add(ticketId);
        _ticketsFuture = _ticketService.fetchTicketFeed();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already voted or error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hostel Issues')),
      body: FutureBuilder<List<TicketResponse>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load tickets'));
          }

          final tickets = snapshot.data!;

          if (tickets.isEmpty) {
            return const Center(child: Text('No active issues 🎉'));
          }

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final hasVoted = _votedTickets.contains(ticket.id);

              return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(ticket.description),
                    subtitle: Text(
                      '${ticket.category.toUpperCase()} • '
                      '${ticket.impactRadius} • '
                      '${ticket.urgency}',
                    ),
                    trailing: SizedBox(
                      width: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${ticket.votes.count}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            ticket.votes.count > 5
                                ? 'Wide'
                                : ticket.votes.count > 2
                                    ? 'Multi'
                                    : 'Solo',
                            style: TextStyle(
                              fontSize: 10,
                              color: ticket.votes.count > 5
                                  ? Colors.red
                                  : ticket.votes.count > 2
                                      ? Colors.orange
                                      : Colors.grey,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.arrow_upward,
                              size: 20,
                              color: hasVoted ? Colors.grey : Colors.blue,
                            ),
                            onPressed: hasVoted ? null : () => _vote(ticket.id),
                          ),
                        ],
                      ),
                    ),
                  ));
            },
          );
        },
      ),
    );
  }
}
