import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/polls_bloc.dart';
import '../bloc/polls_event.dart';
import '../bloc/polls_state.dart';
import '../../../core/network/api_client.dart';
import '../data/polls_api.dart';
import 'package:dio/dio.dart';
import '../../../shared/theme/app_theme.dart';

class PollsTab extends StatefulWidget {
  final int tripId;
  const PollsTab({super.key, required this.tripId});

  @override
  State<PollsTab> createState() => _PollsTabState();
}

class _PollsTabState extends State<PollsTab> {
  late final PollsBloc _bloc;

  @override
  void initState() {
    super.initState();
    // Load polls once when the tab is opened.
    _bloc = PollsBloc(ApiClient())..add(LoadPolls(widget.tripId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripId = widget.tripId;

    return BlocProvider.value(
      value: _bloc,
      child: Stack(
        children: [
          BlocBuilder<PollsBloc, PollsState>(
            builder: (context, state) {
              if (state is PollsLoading || state is PollsInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is PollsLoaded) {
                final polls = state.polls;
                if (polls.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.poll_outlined,
                          size: 64,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No polls yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a poll to get group opinions',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: polls.length,
                  itemBuilder: (_, i) {
                    final p = polls[i];
                    final options = (p['options'] as List?) ?? const [];
                    return _PollCard(
                      poll: p,
                      options: options,
                      onVote: (pollId, optId) {
                        context.read<PollsBloc>().add(VoteOnPoll(pollId, optId));
                      },
                    );
                  },
                );
              }
              if (state is PollsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () async {
                final questionController = TextEditingController();
                final opt1 = TextEditingController();
                final opt2 = TextEditingController();
                final result = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Create Poll'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: questionController,
                            decoration: const InputDecoration(
                              labelText: 'Question',
                              hintText: 'What would you like to ask?',
                            ),
                            autofocus: true,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: opt1,
                            decoration: const InputDecoration(
                              labelText: 'Option 1',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: opt2,
                            decoration: const InputDecoration(
                              labelText: 'Option 2',
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                );
                if (result == true) {
                  final question = questionController.text.trim();
                  final options = [opt1.text.trim(), opt2.text.trim()].where((e) => e.isNotEmpty).toList();
                  if (question.isEmpty || options.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a question and at least one option')),
                      );
                    }
                    return;
                  }
                  try {
                    await PollsApi(ApiClient()).createPoll(
                      tripId: tripId,
                      question: question,
                      options: options,
                    );
                    if (context.mounted) {
                      context.read<PollsBloc>().add(LoadPolls(tripId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Poll created successfully!')),
                      );
                    }
                  } on DioException catch (e) {
                    if (context.mounted) {
                      final msg = e.response?.data?.toString() ?? 'Failed to create poll';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to create poll')),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New Poll'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PollCard extends StatelessWidget {
  final Map<String, dynamic> poll;
  final List<dynamic> options;
  final Function(int, int) onVote;

  const _PollCard({
    required this.poll,
    required this.options,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    // Compute total votes from backend-provided counts.
    final totalVotes = options.fold<int>(
      0,
      (sum, opt) => sum + (opt['votes'] as int? ?? 0),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.poll,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    poll['question'] ?? 'Poll',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (totalVotes > 0)
              Text(
                '$totalVotes vote${totalVotes == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            const SizedBox(height: 12),
            ...options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final votes = option['votes'] as int? ?? 0;
              final isSelected = option['is_selected'] as bool? ?? false;
              final percent =
                  totalVotes > 0 ? votes / totalVotes : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      final pollId = poll['id'] as int;
                      final optId = option['id'] as int;
                      onVote(pollId, optId);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withOpacity(0.4),
                        width: isSelected ? 2 : 1.5,
                      ),
                      backgroundColor: isSelected
                          ? AppTheme.primaryColor.withOpacity(0.06)
                          : Colors.transparent,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(
                                        65 + index), // A, B, C, etc.
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option['text'] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (totalVotes > 0)
                                Text(
                                  '${(percent * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          if (totalVotes > 0) ...[
                            const SizedBox(height: 8),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0,
                                end: percent,
                              ),
                              duration:
                                  const Duration(milliseconds: 350),
                              curve: Curves.easeOut,
                              builder: (context, value, _) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: value,
                                    minHeight: 6,
                                    backgroundColor: Colors
                                        .grey.shade200,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      isSelected
                                          ? AppTheme.primaryColor
                                          : AppTheme.primaryColor
                                              .withOpacity(0.5),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
