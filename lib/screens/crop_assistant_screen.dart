// lib/screens/crop_assistant_screen.dart
// Lightweight crop-specific AI assistant. Minimal, no complex history.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import '../services/ai_service.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class CropAssistantScreen extends StatefulWidget {
  final CropPlan plan;
  const CropAssistantScreen({super.key, required this.plan});

  @override
  State<CropAssistantScreen> createState() => _CropAssistantScreenState();
}

class _CropAssistantScreenState extends State<CropAssistantScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _isLoading = false;
  final AiService _ai = AiService();

  @override
  void initState() {
    super.initState();
    _addWelcome();
  }

  void _addWelcome() {
    // ignore: unused_local_variable
    final state = context.read<AppState>();
    final tip = widget.plan.quickTips.isNotEmpty
        ? widget.plan.quickTips.first
        : 'Water regularly and check soil moisture.';
    _messages.add(_ChatMessage(
      text:
          'Hi! I\'m your ${widget.plan.name} assistant 🌱\n\nYou\'re currently on Week ${widget.plan.currentWeek}: ${widget.plan.currentWeekTitle}.\n\nQuick tip: $tip\n\nAsk me anything about growing ${widget.plan.name}!',
      isUser: false,
    ));
  }

  Future<void> _send({bool skipAi = false}) async {
    print('SEND CALLED');
    print('AI CONFIGURED = ${_ai.isConfigured}, SKIP AI = $skipAi');
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollDown();

    final state = context.read<AppState>();
    String reply;

    if (skipAi) {
      // Predefined quick prompts
      reply = _fallbackAnswer(text, widget.plan);
    } else if (!_ai.isConfigured) {
      // Arbitrary message but no API key configured
      reply = '⚠️ AI is not configured. Please start the app with a valid Gemini API key to ask custom questions.';
    } else {
      // Arbitrary message with API key - use AI
      try {
        final answer = await _ai.askCropQuestion(
          question: text,
          cropName: widget.plan.name,
          currentWeek: widget.plan.currentWeekTitle,
          location: widget.plan.location,
          climate: state.profile?.climateZone ?? 'Subtropical',
        );
        reply = answer ?? 'Error: Received empty response from AI.';
      } on AiException catch (e) {
        reply = '⚠️ AI Connection Error: ${e.message}';
      } catch (e) {
        reply = '⚠️ AI Connection Error: Failed to reach the AI service.';
      }
    }

    if (mounted) {
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
        _isLoading = false;
      });
      _scrollDown();
    }
  }

  String _fallbackAnswer(String question, CropPlan plan) {
    final q = question.toLowerCase();
    if (q.contains('water')) {
      return 'For ${plan.name}, water early morning to avoid fungal issues. Check soil moisture with your finger — if the top inch is dry, it\'s time to water.';
    }
    if (q.contains('fertiliz') || q.contains('feed')) {
      return 'Start light fertilizing from Week 4 onwards. Use a balanced NPK fertilizer every 2 weeks.';
    }
    if (q.contains('pest') || q.contains('bug')) {
      return 'Check leaves weekly for pests. Remove them manually or use neem oil spray. Marigolds nearby help repel common pests.';
    }
    if (q.contains('harvest') || q.contains('ready') || q.contains('pick')) {
      return 'For ${plan.name}, signs of readiness appear around Week ${plan.totalWeeks - 1}. Look for colour change and firmness.';
    }
    if (q.contains('week') || q.contains('stage') || q.contains('now')) {
      return 'You\'re on Week ${plan.currentWeek}: ${plan.currentWeekTitle}. Complete the tasks in this stage before moving forward.';
    }
    return 'Great question! For ${plan.name} at Week ${plan.currentWeek} (${plan.currentWeekTitle}): focus on your pending tasks and check on the plant daily. Would you like tips on a specific aspect?';
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            color: AppColors.primary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 16,
              bottom: 14,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(widget.plan.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.plan.name} Assistant',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _ai.isConfigured
                            ? 'Powered by Grok AI'
                            : 'Smart farming tips',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.75)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Week ${widget.plan.currentWeek}',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ── Messages ─────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _TypingIndicator();
                }
                final msg = _messages[index];
                return _Bubble(message: msg);
              },
            ),
          ),

          // ── Quick prompts ─────────────────────────────────────────────
          if (_messages.length <= 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  'When to water?',
                  'Signs of pests?',
                  'When to harvest?',
                  'Current stage tips',
                ]
                    .map((q) => GestureDetector(
                          onTap: () {
                            _ctrl.text = q;
                            _send(skipAi: true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.selectedBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.selectedBorder
                                      .withOpacity(0.4)),
                            ),
                            child: Text(q,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ))
                    .toList(),
              ),
            ),

          // ── Input ─────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _send(),
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ask about ${widget.plan.name}...',
                      hintStyle: GoogleFonts.inter(
                          color: AppColors.textHint, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isLoading ? null : _send,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          _isLoading ? Colors.grey.shade300 : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: _isLoading ? Colors.grey : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(message.isUser ? 14 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: message.isUser ? Colors.white : AppColors.textPrimary,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(_anim.value),
              const SizedBox(width: 4),
              _dot((_anim.value + 0.3).clamp(0.3, 1.0)),
              const SizedBox(width: 4),
              _dot((1.0 - _anim.value + 0.3).clamp(0.3, 1.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(double opacity) => Opacity(
        opacity: opacity,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
              color: AppColors.textHint, shape: BoxShape.circle),
        ),
      );
}
