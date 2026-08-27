import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/clinical_intake_model.dart';
import '../../models/patient_model.dart';
import '../../services/clinical_intake_service.dart';
import 'clinical_history_summary_screen.dart';

/// Screen 1: AI Health Conversation
///
/// Multi-turn conversational AI clinical intake assistant.
/// Supports both Voice and Text inputs, converts spoken speech to text,
/// asks clinical history questions, and shows quick-reply suggestion chips.
class AiHealthConversationScreen extends StatefulWidget {
  final PatientModel patient;

  const AiHealthConversationScreen({super.key, required this.patient});

  @override
  State<AiHealthConversationScreen> createState() => _AiHealthConversationScreenState();
}

class _AiHealthConversationScreenState extends State<AiHealthConversationScreen>
    with SingleTickerProviderStateMixin {
  final _service = ClinicalIntakeService.instance;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  late List<ChatMessage> _messages;
  bool _isTyping = false;
  bool _isRecording = false;
  Timer? _aiTimer;
  Timer? _recordingTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _messages = List.from(_service.getChatHistory(widget.patient));
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _aiTimer?.cancel();
    _recordingTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text, {bool isVoice = false}) {
    if (text.trim().isEmpty) return;

    final userMsg = _service.addUserMessage(widget.patient, text, isVoice: isVoice);
    _textController.clear();
    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate AI clinical reasoning latency
    _aiTimer?.cancel();
    _aiTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final aiMsg = _service.generateAiResponse(widget.patient, text);
      setState(() {
        _messages.add(aiMsg);
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  void _toggleVoiceRecording() {
    if (_isRecording) {
      // Finish recording and convert speech to text
      _recordingTimer?.cancel();
      _pulseController.stop();
      setState(() => _isRecording = false);
      const simulatedSpeech =
          'I have been having chronic knee pain and morning stiffness for 3 weeks.';
      _sendMessage(simulatedSpeech, isVoice: true);
    } else {
      _pulseController.repeat(reverse: true);
      setState(() {
        _isRecording = true;
      });
      // Simulate live recording countdown
      _recordingTimer?.cancel();
      _recordingTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted && _isRecording) {
          _toggleVoiceRecording();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 1,
        shadowColor: AppColors.cardShadow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.navyPrimary, size: 20.0),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.greenSuccess, width: 1.2),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppColors.greenSuccess, size: 18.0),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Health Assistant',
                    style: TextStyle(
                      color: AppColors.navyPrimary,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Clinical Intake for ${widget.patient.name}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'View Clinical Summary',
            icon: const Icon(Icons.assignment_rounded, color: AppColors.saffronDark),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ClinicalHistorySummaryScreen(patient: widget.patient),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Intake mode banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: const BoxDecoration(
                color: AppColors.saffronLight,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFFD8BF), width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.record_voice_over_rounded,
                      size: 15.0, color: AppColors.saffronDark),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'AI is gathering your symptoms & history. Speak or type below.',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.saffronDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chat Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // AI Typing Indicator
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 12.0,
                          height: 12.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: AppColors.greenSuccess,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'AI is analyzing your clinical details...',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Voice Recording Waveform Overlay
            if (_isRecording) _buildLiveRecordingBar(),

            // Quick Suggestion Chips from latest AI message
            if (!_isRecording &&
                _messages.isNotEmpty &&
                !_messages.last.isUser &&
                _messages.last.quickSuggestions != null &&
                _messages.last.quickSuggestions!.isNotEmpty)
              _buildSuggestionsBar(_messages.last.quickSuggestions!),

            // Bottom Input Bar (Microphone & Text Input)
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: const BoxDecoration(
                color: AppColors.greenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  size: 16.0, color: AppColors.greenSuccess),
            ),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
              decoration: BoxDecoration(
                color: isUser ? AppColors.navyPrimary : AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16.0),
                  topRight: const Radius.circular(16.0),
                  bottomLeft: Radius.circular(isUser ? 16.0 : 4.0),
                  bottomRight: Radius.circular(isUser ? 4.0 : 16.0),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.surfaceBorder),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (msg.isVoiceInput) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.mic_rounded,
                            size: 12.0, color: AppColors.saffronPrimary),
                        SizedBox(width: 4.0),
                        Text(
                          'Speech-to-Text Input',
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.saffronPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                  ],
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.navyPrimary,
                      fontSize: 13.5,
                      height: 1.4,
                      fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: isUser ? Colors.white60 : AppColors.textMuted,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8.0),
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: const BoxDecoration(
                color: AppColors.saffronLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  size: 16.0, color: AppColors.saffronDark),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionsBar(List<String> suggestions) {
    return Container(
      height: 44.0,
      padding: const EdgeInsets.only(left: 12.0, bottom: 6.0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ActionChip(
            backgroundColor: AppColors.background,
            side: const BorderSide(color: AppColors.greenSuccess, width: 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            avatar: const Icon(Icons.add_circle_outline_rounded,
                size: 14.0, color: AppColors.greenSuccess),
            label: Text(
              suggestion,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.greenSuccess,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => _sendMessage(suggestion),
          );
        },
      ),
    );
  }

  Widget _buildLiveRecordingBar() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: const Color(0xFFDC2626)
                  .withValues(alpha: 0.3 + (_pulseController.value * 0.7)),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12.0,
                height: 12.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10.0),
              const Expanded(
                child: Text(
                  'Listening to your voice... (Speak now)',
                  style: TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: _toggleVoiceRecording,
                child: const Text('Stop & Transcribe',
                    style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          // Voice / Mic Button
          IconButton(
            tooltip: _isRecording ? 'Stop Recording' : 'Voice Input (Speak)',
            icon: Icon(
              _isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
              color: _isRecording ? Colors.red : AppColors.saffronPrimary,
              size: 26.0,
            ),
            onPressed: _toggleVoiceRecording,
          ),

          // Text Field
          Expanded(
            child: TextField(
              controller: _textController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type your symptom or reply...',
                hintStyle: const TextStyle(fontSize: 13.0, color: AppColors.textMuted),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                fillColor: AppColors.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide:
                      const BorderSide(color: AppColors.greenSuccess, width: 1.5),
                ),
              ),
              onSubmitted: (text) => _sendMessage(text),
            ),
          ),
          const SizedBox(width: 8.0),

          // Send Button
          Container(
            decoration: const BoxDecoration(
              color: AppColors.greenSuccess,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18.0),
              onPressed: () => _sendMessage(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}
