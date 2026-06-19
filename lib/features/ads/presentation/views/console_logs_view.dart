import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/logger/app_logger.dart';

enum LogFilterLevel { all, info, debug, warning, error }

class ConsoleLogsView extends StatefulWidget {
  const ConsoleLogsView({super.key});

  @override
  State<ConsoleLogsView> createState() => _ConsoleLogsViewState();
}

class _ConsoleLogsViewState extends State<ConsoleLogsView> {
  final List<String> _allLogs = [];
  final List<String> _filteredLogs = [];
  late StreamSubscription<String> _logSubscription;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  LogFilterLevel _selectedLevel = LogFilterLevel.all;
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _logSubscription = sl<AppLogger>().logStream.listen((log) {
      if (mounted) {
        setState(() {
          _allLogs.add(log);
          _applyFilters();
        });
        if (_autoScroll) {
          _scrollToBottom();
        }
      }
    });
  }

  @override
  void dispose() {
    _logSubscription.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    _filteredLogs.clear();

    for (final log in _allLogs) {
      // 1. Level Filter
      bool matchesLevel = true;
      if (_selectedLevel == LogFilterLevel.info) {
        matchesLevel = log.startsWith('[INFO]');
      } else if (_selectedLevel == LogFilterLevel.debug) {
        matchesLevel = log.startsWith('[DEBUG]');
      } else if (_selectedLevel == LogFilterLevel.warning) {
        matchesLevel = log.startsWith('[WARNING]');
      } else if (_selectedLevel == LogFilterLevel.error) {
        matchesLevel = log.startsWith('[ERROR]');
      }

      // 2. Search Query Filter
      bool matchesQuery = true;
      if (query.isNotEmpty) {
        matchesQuery = log.toLowerCase().contains(query);
      }

      if (matchesLevel && matchesQuery) {
        _filteredLogs.add(log);
      }
    }
  }

  void _clearLogs() {
    setState(() {
      _allLogs.clear();
      _filteredLogs.clear();
    });
  }

  Future<void> _copyToClipboard() async {
    if (_allLogs.isEmpty) return;
    final text = _allLogs.join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logs copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Controls / Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) {
                  setState(() {
                    _applyFilters();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search logs...',
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.white54,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _applyFilters();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF161626),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: const TextStyle(
                    color: Colors.white30,
                    fontSize: 13,
                  ),
                ),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: LogFilterLevel.values.map((level) {
                    final isSelected = _selectedLevel == level;
                    final label = level.name.toUpperCase();
                    Color selectedColor = const Color(0xFF0097A7);
                    if (level == LogFilterLevel.error) {
                      selectedColor = Colors.redAccent;
                    }
                    if (level == LogFilterLevel.warning) {
                      selectedColor = Colors.amberAccent;
                    }
                    if (level == LogFilterLevel.debug) {
                      selectedColor = Colors.blueAccent;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white60,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedLevel = level;
                              _applyFilters();
                            });
                          }
                        },
                        selectedColor: selectedColor.withValues(alpha: 0.2),
                        backgroundColor: Colors.white.withValues(alpha: 0.02),
                        checkmarkColor: selectedColor,
                        side: BorderSide(
                          color: isSelected ? selectedColor : Colors.white10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Action Toolbar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _autoScroll,
                      onChanged: (val) {
                        setState(() {
                          _autoScroll = val ?? true;
                        });
                      },
                      activeColor: const Color(0xFF0097A7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Auto-scroll',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 18,
                      color: Colors.white70,
                    ),
                    onPressed: _copyToClipboard,
                    tooltip: 'Copy all logs',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.redAccent,
                    ),
                    onPressed: _clearLogs,
                    tooltip: 'Clear logs',
                  ),
                ],
              ),
            ],
          ),
        ),

        // Monospace Console Viewport
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF07070F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            clipBehavior: Clip.antiAlias,
            child: _filteredLogs.isEmpty
                ? const Center(
                    child: Text(
                      'No matching logs found.',
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = _filteredLogs[index];
                      Color color = Colors.white70;
                      if (log.startsWith('[ERROR]')) {
                        color = Colors.redAccent;
                      } else if (log.startsWith('[INFO]')) {
                        color = Colors.greenAccent;
                      } else if (log.startsWith('[WARNING]')) {
                        color = Colors.amberAccent;
                      } else if (log.startsWith('[DEBUG]')) {
                        color = Colors.blueAccent;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Text(
                          log,
                          style: TextStyle(
                            color: color,
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            height: 1.3,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
