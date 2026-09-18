import 'package:flutter/material.dart';

import '../data/routine_store.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoutineStore.instance,
      builder: (context, _) {
        final history = RoutineStore.instance.workoutHistory;
        return Scaffold(
          backgroundColor: const Color(0xFF08090C),
          appBar: AppBar(
            backgroundColor: const Color(0xFF08090C),
            elevation: 0,
            leading: IconButton(
              tooltip: 'Volver',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
            ),
            title: const Text(
              'Historial de entrenamientos',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          body: history.isEmpty
              ? const Center(
                  child: Text(
                    'Tus entrenamientos completados aparecerán aquí.',
                    style: TextStyle(color: Color(0xFF9B9FA8)),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    MediaQuery.paddingOf(context).bottom + 28,
                  ),
                  itemCount: history.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final session = history[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151820),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0x22FF6B1A),
                            child: Icon(
                              Icons.check_rounded,
                              color: Color(0xFFFF6B1A),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session['title'] as String? ?? 'Rutina',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  session['date'] as String? ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFF9B9FA8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${session['duration'] ?? 0} min',
                                style: const TextStyle(
                                  color: Color(0xFFFF6B1A),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${session['sets'] ?? 0} series',
                                style: const TextStyle(
                                  color: Color(0xFF9B9FA8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
