import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/clinical_intake_model.dart';
import '../../models/patient_model.dart';
import '../../services/clinical_intake_service.dart';
import 'clinical_history_summary_screen.dart';

/// Screen 2: Voice-to-Text Clinical History
///
/// Dedicated clinical narration module where the patient can describe their health
/// condition by speaking in their preferred Indian language. Converts speech to text,
/// provides an editable review area, and stores the record in their intake profile.
class VoiceToTextHistoryScreen extends StatefulWidget {
  final PatientModel patient;

  const VoiceToTextHistoryScreen({super.key, required this.patient});

  @override
  State<VoiceToTextHistoryScreen> createState() =>
      _VoiceToTextHistoryScreenState();
}

class _VoiceToTextHistoryScreenState extends State<VoiceToTextHistoryScreen>
    with SingleTickerProviderStateMixin {
  final _service = ClinicalIntakeService.instance;
  final _transcriptController = TextEditingController();

  Map<String, String> _selectedLanguage =
      ClinicalIntakeService.supportedLanguages.first;
  bool _isRecording = false;
  int _secondsRecorded = 0;
  Timer? _timer;
  late AnimationController _waveController;

  // Multi-lingual sample transcripts based on selected language
  static final Map<String, String> _sampleTranscriptsByLang = {
    'en-IN':
        'I have been experiencing recurring knee joint pain and morning stiffness for three weeks. The discomfort increases when climbing stairs or walking long distances. Mild fever occurred last week.',
    'hi-IN':
        'मुझे पिछले तीन हफ़्तों से दोनों घुटनों में दर्द और सुबह के समय अकड़न महसूस हो रही है। सीढ़ियाँ चढ़ने पर दर्द बढ़ जाता है। पिछले हफ़्ते हल्का बुखार भी आया था।',
    'mr-IN':
        'गेल्या तीन आठवड्यांपासून मला दोन्ही गुडघ्यांमध्ये वेदना आणि सकाळी कडकपणा जाणवत आहे. जिन्या चढताना वेदना वाढतात.',
    'gu-IN':
        'મને છેલ્લા ત્રણ અઠવાડિયાથી બંને ઘૂંટણમાં દુખાવો અને સવારે જકડન રહે છે. દાદરા ચડતી વખતે દુખાવો વધે છે.',
    'ta-IN':
        'கடந்த மூன்று வாரங்களாக இரண்டு முழங்கால்களிலும் வலி மற்றும் காலை நேர இறுக்கம் உள்ளது. படிகள் ஏறும் போது வலி அதிகரிக்கிறது.',
    'te-IN':
        'గత మూడు వారాలుగా రెండు మోకాళ్లలో నొప్పి మరియు ఉదయం దృఢత్వం ఉంది. మెట్లు ఎక్కేటప్పుడు నొప్పి పెరుగుతుంది.',
    'bn-IN':
        'গত তিন সপ্তাহ ধরে আমার উভয় হাঁটুতে ব্যথা এবং সকালে শক্ত ভাব অনুভূত হচ্ছে। সিঁড়ি ওঠার সময় ব্যথা বাড়ে।',
    'kn-IN':
        'ಕಳೆದ ಮೂರು ವಾರಗಳಿಂದ ಎರಡೂ ಮೊಣಕಾಲುಗಳಲ್ಲಿ ನೋವು ಮತ್ತು ಬೆಳಗಿನ ಬಿಗಿತವಿದೆ. ಮೆಟ್ಟಿಲುಗಳನ್ನು ಹತ್ತುವಾಗ ನೋವು ಹೆಚ್ಚಾಗುತ್ತದೆ.',
  };

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final existingRecords = _service.getVoiceRecords(widget.patient);
    if (existingRecords.isNotEmpty) {
      _transcriptController.text = existingRecords.first.editedTranscript;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _transcriptController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _secondsRecorded = 0;
      _transcriptController.clear();
    });
    _waveController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsRecorded++;
      });
      // Simulate live transcription updates
      if (_secondsRecorded == 3) {
        final langCode = _selectedLanguage['code'] ?? 'en-IN';
        _transcriptController.text = _sampleTranscriptsByLang[langCode] ??
            _sampleTranscriptsByLang['en-IN']!;
      }
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    _waveController.stop();
    setState(() {
      _isRecording = false;
    });

    if (_transcriptController.text.trim().isEmpty) {
      final langCode = _selectedLanguage['code'] ?? 'en-IN';
      _transcriptController.text = _sampleTranscriptsByLang[langCode] ??
          _sampleTranscriptsByLang['en-IN']!;
    }
  }

  void _saveVoiceRecord() {
    final text = _transcriptController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please record your voice or type clinical notes first.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final record = VoiceIntakeRecord(
      id: 'vr_${DateTime.now().millisecondsSinceEpoch}',
      patientAbhaId: widget.patient.abhaId,
      languageName: _selectedLanguage['name'] ?? 'English (India)',
      languageCode: _selectedLanguage['code'] ?? 'en-IN',
      originalTranscript: text,
      editedTranscript: text,
      recordingDuration: Duration(seconds: _secondsRecorded > 0 ? _secondsRecorded : 15),
      recordedAt: DateTime.now(),
    );

    _service.saveVoiceRecord(widget.patient, record);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8.0),
            Expanded(
              child: Text(
                'Voice clinical history saved & added to your Clinical Summary!',
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.greenSuccess,
        duration: Duration(seconds: 3),
      ),
    );
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
        title: const Text(
          'Voice-to-Text Clinical History',
          style: TextStyle(
            color: AppColors.navyPrimary,
            fontSize: 16.0,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF2EC), Color(0xFFFFE0D0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xFFFFCCA8)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: const BoxDecoration(
                        color: AppColors.saffronPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_rounded,
                          color: Colors.white, size: 24.0),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Describe Your Health Problem',
                            style: TextStyle(
                              color: AppColors.navyPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3.0),
                          Text(
                            'Speak in your native language. Our AI converts your voice to text for your doctor.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // Language Selector
              const Text(
                'Select Spoken Language',
                style: TextStyle(
                  color: AppColors.navyPrimary,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage['code'],
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.navyPrimary),
                    items: ClinicalIntakeService.supportedLanguages.map((lang) {
                      return DropdownMenuItem<String>(
                        value: lang['code'],
                        child: Row(
                          children: [
                            Text(lang['flag'] ?? '',
                                style: const TextStyle(fontSize: 16.0)),
                            const SizedBox(width: 8.0),
                            Text(
                              lang['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navyPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newCode) {
                      if (newCode != null) {
                        setState(() {
                          _selectedLanguage = ClinicalIntakeService.supportedLanguages
                              .firstWhere((l) => l['code'] == newCode);
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Voice Recording Hub & Waveform
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isRecording ? _stopRecording : _startRecording,
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          final scale = _isRecording
                              ? 1.0 + (_waveController.value * 0.12)
                              : 1.0;
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 88.0,
                              height: 88.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isRecording
                                    ? const Color(0xFFDC2626)
                                    : AppColors.saffronPrimary,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isRecording
                                            ? Colors.red
                                            : AppColors.saffronPrimary)
                                        .withValues(alpha: 0.35),
                                    blurRadius: _isRecording ? 24.0 : 12.0,
                                    spreadRadius: _isRecording ? 6.0 : 2.0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isRecording
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
                                color: Colors.white,
                                size: 42.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      _isRecording
                          ? 'Recording... 00:${_secondsRecorded.toString().padLeft(2, '0')}'
                          : 'Tap microphone to start speaking',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        color: _isRecording
                            ? const Color(0xFFDC2626)
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (_isRecording) ...[
                      const SizedBox(height: 4.0),
                      const Text(
                        'Speak clearly about your symptoms, pain, and timeline.',
                        style: TextStyle(fontSize: 11.0, color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Converted Text Review & Edit Area
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Converted Clinical Transcript',
                    style: TextStyle(
                      color: AppColors.navyPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.edit_note_rounded,
                            size: 13.0, color: AppColors.greenSuccess),
                        SizedBox(width: 4.0),
                        Text('Editable',
                            style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.greenSuccess,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _transcriptController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'Your converted speech will appear here. You can also type or edit this text directly before saving.',
                  fillColor: AppColors.background,
                  hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.0),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.0),
                    borderSide:
                        const BorderSide(color: AppColors.saffronPrimary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: _saveVoiceRecord,
                icon: const Icon(Icons.check_circle_rounded, size: 18.0),
                label: const Text('Save to Intake Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenSuccess,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
              const SizedBox(height: 10.0),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ClinicalHistorySummaryScreen(patient: widget.patient),
                    ),
                  );
                },
                icon: const Icon(Icons.assignment_rounded,
                    size: 18.0, color: AppColors.navyPrimary),
                label: const Text('Preview Clinical Summary'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
