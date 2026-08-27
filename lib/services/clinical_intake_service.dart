import '../models/clinical_intake_model.dart';
import '../models/patient_model.dart';

/// ClinicalIntakeService provides state management and AI mock engines
/// for the patient clinical intake workflow:
/// 1. AI Health Conversation
/// 2. Voice-to-Text Clinical History
/// 3. OCR Medical Document Scanning
/// 4. Medical History Timeline
/// 5. AI Clinical History Summary
class ClinicalIntakeService {
  ClinicalIntakeService._internal();
  static final ClinicalIntakeService instance = ClinicalIntakeService._internal();
  factory ClinicalIntakeService() => instance;

  // In-memory store keyed by ABHA ID
  final Map<String, List<ChatMessage>> _chatSessions = {};
  final Map<String, List<VoiceIntakeRecord>> _voiceRecords = {};
  final Map<String, List<ScannedDocument>> _scannedDocs = {};

  // Supported intake languages for speech-to-text
  static const List<Map<String, String>> supportedLanguages = [
    {'name': 'English (India)', 'code': 'en-IN', 'flag': '🇮🇳'},
    {'name': 'हिन्दी (Hindi)', 'code': 'hi-IN', 'flag': '🇮🇳'},
    {'name': 'मराठी (Marathi)', 'code': 'mr-IN', 'flag': '🇮🇳'},
    {'name': 'ગુજરાતી (Gujarati)', 'code': 'gu-IN', 'flag': '🇮🇳'},
    {'name': 'தமிழ் (Tamil)', 'code': 'ta-IN', 'flag': '🇮🇳'},
    {'name': 'తెలుగు (Telugu)', 'code': 'te-IN', 'flag': '🇮🇳'},
    {'name': 'বাংলা (Bengali)', 'code': 'bn-IN', 'flag': '🇮🇳'},
    {'name': 'ಕನ್ನಡ (Kannada)', 'code': 'kn-IN', 'flag': '🇮🇳'},
  ];

  // ── 1. AI Conversation Logic ───────────────────────────────────────────────

  List<ChatMessage> getChatHistory(PatientModel patient) {
    if (!_chatSessions.containsKey(patient.abhaId)) {
      _chatSessions[patient.abhaId] = _getInitialGreeting(patient);
    }
    return List.unmodifiable(_chatSessions[patient.abhaId]!);
  }

  List<ChatMessage> _getInitialGreeting(PatientModel patient) {
    return [
      ChatMessage(
        id: 'msg_welcome',
        text: 'Namaste ${patient.firstName}! I am your AI Clinical Assistant. '
            'I will help prepare your health history before you meet the AYUSH physician. '
            'What main health concern or symptom brings you in today?',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        quickSuggestions: [
          'Persistent knee & lower back pain for 2 weeks',
          'Indigestion, acidity & bloating after meals',
          'Mild fever, sore throat and dry cough',
          'Chronic migraine & sleep disturbance',
        ],
      ),
    ];
  }

  ChatMessage addUserMessage(PatientModel patient, String text, {bool isVoice = false}) {
    if (!_chatSessions.containsKey(patient.abhaId)) {
      _chatSessions[patient.abhaId] = _getInitialGreeting(patient);
    }
    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      isVoiceInput: isVoice,
    );
    _chatSessions[patient.abhaId]!.add(userMsg);
    return userMsg;
  }

  ChatMessage generateAiResponse(PatientModel patient, String userText) {
    final lower = userText.toLowerCase();
    String reply;
    List<String>? suggestions;

    if (lower.contains('pain') || lower.contains('knee') || lower.contains('back') || lower.contains('joint')) {
      reply = 'Thank you for sharing. Could you describe the nature of this pain? '
          'Is it sharp, dull aching, or burning? Does it worsen in the morning or after physical activity?';
      suggestions = [
        'Dull aching pain, severe in the morning',
        'Sharp throbbing pain with mild swelling',
        'Worse after climbing stairs or sitting long',
      ];
    } else if (lower.contains('acid') || lower.contains('digestion') || lower.contains('stomach') || lower.contains('bloat')) {
      reply = 'I have noted your digestive discomfort. How long have you experienced this acidity? '
          'Do you notice a connection to spicy/oily food, stress, or irregular meal times?';
      suggestions = [
        'Started 3 weeks ago after spicy meals',
        'Constant burning sensation in the chest',
        'Accompanied by sour belching & poor appetite',
      ];
    } else if (lower.contains('fever') || lower.contains('cough') || lower.contains('cold') || lower.contains('throat')) {
      reply = 'Understood. What is the highest recorded temperature? Are you experiencing any chills, '
          'body aches, or difficulty breathing?';
      suggestions = [
        'Fever around 100°F with body fatigue',
        'Dry cough mostly at night, no breathing issue',
        'Mild throat irritation and nasal congestion',
      ];
    } else if (lower.contains('morning') || lower.contains('severe') || lower.contains('started') || lower.contains('week') || lower.contains('day')) {
      reply = 'Noted. Are you currently taking any allopathic, ayurvedic, or over-the-counter medications for this? '
          'Also, please mention any known drug or food allergies.';
      suggestions = [
        'Taking Paracetamol occasionally, no allergies',
        'Taking Ayurvedic Triphala Churna at bedtime',
        'Allergic to Penicillin and Sulfa drugs',
        'No active medications or known allergies',
      ];
    } else {
      reply = 'Thank you. I have added this clinical insight to your intake record. '
          'Is there any family medical history (e.g. diabetes, hypertension, arthritis) '
          'or previous surgical procedures you would like the doctor to know?';
      suggestions = [
        'Father has Type 2 Diabetes and Hypertension',
        'Underwent appendectomy in 2018',
        'No major family history or past surgeries',
      ];
    }

    final aiMsg = ChatMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      text: reply,
      isUser: false,
      timestamp: DateTime.now(),
      quickSuggestions: suggestions,
    );

    _chatSessions[patient.abhaId]!.add(aiMsg);
    return aiMsg;
  }

  // ── 2. Voice-to-Text Logic ───────────────────────────────────────────────────

  List<VoiceIntakeRecord> getVoiceRecords(PatientModel patient) {
    if (!_voiceRecords.containsKey(patient.abhaId)) {
      _voiceRecords[patient.abhaId] = [
        VoiceIntakeRecord(
          id: 'vr_sample_1',
          patientAbhaId: patient.abhaId,
          languageName: 'English (India)',
          languageCode: 'en-IN',
          originalTranscript: 'I have been feeling joint stiffness in both knees for the past three weeks, '
              'especially when waking up in the morning. Herbal oil massage gave temporary relief.',
          editedTranscript: 'I have been feeling joint stiffness in both knees for the past three weeks, '
              'especially when waking up in the morning. Herbal oil massage gave temporary relief.',
          recordingDuration: const Duration(seconds: 14),
          recordedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ];
    }
    return List.unmodifiable(_voiceRecords[patient.abhaId]!);
  }

  void saveVoiceRecord(PatientModel patient, VoiceIntakeRecord record) {
    if (!_voiceRecords.containsKey(patient.abhaId)) {
      _voiceRecords[patient.abhaId] = [];
    }
    _voiceRecords[patient.abhaId]!.insert(0, record);
  }

  // ── 3. OCR Document Scanner Logic ───────────────────────────────────────────

  List<ScannedDocument> getScannedDocuments(PatientModel patient) {
    if (!_scannedDocs.containsKey(patient.abhaId)) {
      _scannedDocs[patient.abhaId] = _getDefaultScannedDocs();
    }
    return List.unmodifiable(_scannedDocs[patient.abhaId]!);
  }

  List<ScannedDocument> _getDefaultScannedDocs() {
    return [
      ScannedDocument(
        id: 'doc_1',
        title: 'Ayush OPD Prescription - Dr. S. K. Joshi',
        docType: MedicalDocType.prescription,
        documentDate: DateTime.now().subtract(const Duration(days: 45)),
        issuingFacilityOrDoctor: 'Govt. Ayush Multi-Specialty Clinic, Ahmedabad',
        rawOcrText: '''
[AYUSH OPD CLINICAL SLIP]
Date: 12-Jul-2026 | Reg No: AY-2026-9921
Dr. S. K. Joshi (BAMS, MD Ayu - Dravyaguna)
Patient: Aarav Patel | Age: 38/M | ABHA: 14-8912-3401-7752
Diagnosis: Sandhigata Vata (Osteoarthritis Stage I - Early)
Rx:
1. Yogaraja Guggulu - 2 tabs BD with warm water after meals x 30 days
2. Shallaki 500mg - 1 cap BD x 30 days
3. Mahanarayan Taila - Local application BD with warm fomentation
Advice: Avoid sour, fermented & cold food items. Mild morning walking.
''',
        extractedDiagnoses: ['Sandhigata Vata (Early Knee Osteoarthritis)'],
        extractedMedications: [
          'Yogaraja Guggulu 2 tabs BD',
          'Shallaki 500mg 1 cap BD',
          'Mahanarayan Taila (Topical)',
        ],
        extractedLabValues: ['Normal Serum Uric Acid (5.2 mg/dL)'],
        summary: 'Prescribed Classical Ayurvedic anti-inflammatory formulation for early bilateral knee joint stiffness.',
      ),
      ScannedDocument(
        id: 'doc_2',
        title: 'Comprehensive Diagnostic Lab Report (Biochemistry)',
        docType: MedicalDocType.labReport,
        documentDate: DateTime.now().subtract(const Duration(days: 90)),
        issuingFacilityOrDoctor: 'National Reference Pathology Lab, NABL Accredited',
        rawOcrText: '''
[NABL ACCREDITED PATHOLOGY REPORT]
Sample Collected: 28-May-2026 | Reported: 29-May-2026
Patient: Aarav Patel | Ref: Dr. Joshi
- Fasting Blood Sugar: 98 mg/dL (Normal: 70-100)
- HbA1c: 5.6 % (Normal < 5.7%)
- Lipid Profile: Total Cholesterol 188 mg/dL, Triglycerides 142 mg/dL
- Serum Creatinine: 0.95 mg/dL (Normal: 0.7 - 1.2)
- ESR: 22 mm/hr (Mildly elevated, normal < 15)
- CRP (C-Reactive Protein): 4.8 mg/L (Borderline inflammation)
''',
        extractedDiagnoses: ['Mild inflammatory activity (ESR 22 mm/hr, CRP 4.8 mg/L)'],
        extractedMedications: [],
        extractedLabValues: [
          'Fasting Blood Sugar: 98 mg/dL',
          'HbA1c: 5.6%',
          'Total Cholesterol: 188 mg/dL',
          'Serum Creatinine: 0.95 mg/dL',
          'ESR: 22 mm/hr (Mildly Elevated)',
        ],
        summary: 'Metabolic markers within normal limits; mild inflammatory markers consistent with joint symptoms.',
      ),
    ];
  }

  void addScannedDocument(PatientModel patient, ScannedDocument doc) {
    if (!_scannedDocs.containsKey(patient.abhaId)) {
      _scannedDocs[patient.abhaId] = _getDefaultScannedDocs();
    }
    _scannedDocs[patient.abhaId]!.insert(0, doc);
  }

  // Pre-configured sample document templates for simulation
  static final List<ScannedDocument> sampleDocumentTemplates = [
    ScannedDocument(
      id: 'template_discharge',
      title: 'Discharge Summary - Laparoscopic Cholecystectomy',
      docType: MedicalDocType.dischargeSummary,
      documentDate: DateTime.now().subtract(const Duration(days: 420)),
      issuingFacilityOrDoctor: 'Apollo Multispeciality Hospital, Ahmedabad',
      rawOcrText: '''
[INPATIENT DISCHARGE SUMMARY]
DOA: 14-Jan-2025 | DOD: 17-Jan-2025
Primary Diagnosis: Symptomatic Cholelithiasis
Procedure Done: Elective 4-Port Laparoscopic Cholecystectomy (Under GA)
Post-Operative Course: Uneventful. Histopathology confirmed chronic cholecystitis.
Discharge Advice: Normal low-fat diet. No heavy lifting for 6 weeks. Wound healed.
''',
      extractedDiagnoses: ['Symptomatic Cholelithiasis (S/P Lap Cholecystectomy)'],
      extractedMedications: ['No active post-op surgical medications'],
      extractedLabValues: ['Histopathology: Benign Chronic Cholecystitis'],
      summary: 'Elective laparoscopic gall bladder removal in Jan 2025 with uncomplicated recovery.',
    ),
    ScannedDocument(
      id: 'template_ayush_prescription',
      title: 'Ayurvedic Kayachikitsa Prescription',
      docType: MedicalDocType.prescription,
      documentDate: DateTime.now().subtract(const Duration(days: 15)),
      issuingFacilityOrDoctor: 'Dr. Meera Vaidya, BAMS MD (Kaya)',
      rawOcrText: '''
[AYURVEDIC CLINIC PRESCRIPTION]
Date: 12-Aug-2026
Diagnosis: Amlapitta (Hyperacidity) with Agnimandya
Rx:
1. Avipattikar Churna - 3g with lukewarm water before meals BD
2. Shankha Bhasma - 125mg with honey after lunch
3. Kamadudha Rasa (Moti Yukta) - 1 tab BD x 15 days
Pathya: Take coconut water, avoid sour curd, tamarind, and late-night dinners.
''',
      extractedDiagnoses: ['Amlapitta (Hyperacidity & Gastric Dyspepsia)'],
      extractedMedications: [
        'Avipattikar Churna 3g BD before food',
        'Shankha Bhasma 125mg with honey',
        'Kamadudha Rasa (Moti Yukta) 1 tab BD',
      ],
      extractedLabValues: ['Normal Endoscopy finding (Mild Gastritis)'],
      summary: 'Ayurvedic regime for Pitta pacification and hyperacidity relief.',
    ),
  ];

  // ── 4. Unified Timeline Generation ──────────────────────────────────────────

  List<TimelineEvent> getMedicalHistoryTimeline(PatientModel patient) {
    final List<TimelineEvent> events = [];

    // Events from OCR documents
    final docs = getScannedDocuments(patient);
    for (final d in docs) {
      events.add(TimelineEvent(
        id: 'timeline_doc_${d.id}',
        title: d.title,
        category: d.docType == MedicalDocType.prescription
            ? TimelineCategory.medication
            : (d.docType == MedicalDocType.labReport
                ? TimelineCategory.labReport
                : TimelineCategory.scannedDoc),
        date: d.documentDate,
        summary: d.summary,
        details: [
          'Facility: ${d.issuingFacilityOrDoctor}',
          if (d.extractedDiagnoses.isNotEmpty) 'Findings: ${d.extractedDiagnoses.join(", ")}',
          if (d.extractedMedications.isNotEmpty) 'Prescribed: ${d.extractedMedications.join(", ")}',
        ],
        sourceTag: 'OCR Verified',
      ));
    }

    // Events from Voice intake records
    final voiceRecs = getVoiceRecords(patient);
    for (final v in voiceRecs) {
      events.add(TimelineEvent(
        id: 'timeline_voice_${v.id}',
        title: 'Voice Narration (${v.languageName})',
        category: TimelineCategory.voiceNarration,
        date: v.recordedAt,
        summary: v.editedTranscript,
        details: [
          'Duration: ${v.recordingDuration.inSeconds} seconds',
          'Language: ${v.languageName}',
        ],
        sourceTag: 'Voice Intake',
      ));
    }

    // Historical ABDM verified clinical events
    events.addAll([
      TimelineEvent(
        id: 'hist_1',
        title: 'ABDM Health Record Linkage & Baseline Profile',
        category: TimelineCategory.hospitalVisit,
        date: DateTime.now().subtract(const Duration(days: 180)),
        summary: 'ABHA ID generated and linked to National Health Ecosystem.',
        details: ['Identity verified with Aadhaar e-KYC', 'Consent Manager Active'],
        sourceTag: 'ABDM Synced',
      ),
      TimelineEvent(
        id: 'hist_2',
        title: 'Surgical Procedure: Laparoscopic Cholecystectomy',
        category: TimelineCategory.diagnosis,
        date: DateTime.now().subtract(const Duration(days: 420)),
        summary: 'Elective minimally invasive gallbladder removal.',
        details: ['Apollo Multispeciality Hospital', 'Discharged in stable condition'],
        sourceTag: 'Hospital EMR',
      ),
    ]);

    // Sort descending by date
    events.sort((a, b) => b.date.compareTo(a.date));
    return events;
  }

  // ── 5. AI Clinical History Summary Generator ───────────────────────────────

  ClinicalHistorySummary generateClinicalSummary(PatientModel patient) {
    // Inspect recent chat sessions and voice records
    final chats = getChatHistory(patient);
    final voiceRecs = getVoiceRecords(patient);

    String chiefComplaint = 'Bilateral knee joint stiffness and mild lower back pain (Duration: 3 weeks)';
    String hpi = 'Patient reports progressive onset of morning joint stiffness in both knees accompanied by mild lumbar ache. Symptoms worsen in cold weather and upon prolonged sitting. Mild relief noted with herbal oils. Denies trauma, fever, or acute locking.';

    if (voiceRecs.isNotEmpty && voiceRecs.first.editedTranscript.isNotEmpty) {
      chiefComplaint = voiceRecs.first.editedTranscript;
    } else if (chats.length > 2) {
      final userMsgs = chats.where((m) => m.isUser).map((m) => m.text).toList();
      if (userMsgs.isNotEmpty) {
        chiefComplaint = userMsgs.first;
      }
    }

    return ClinicalHistorySummary(
      patientAbhaId: patient.abhaId,
      patientName: patient.name,
      generatedAt: DateTime.now(),
      chiefComplaint: chiefComplaint,
      historyOfPresentIllness: hpi,
      pastMedicalHistory: [
        'Sandhigata Vata (Early Knee Osteoarthritis) diagnosed 2026',
        'Occasional Amlapitta (Hyperacidity / Functional Dyspepsia)',
        'No history of Diabetes Mellitus or Hypertension',
      ],
      pastSurgicalHistory: [
        'Laparoscopic Cholecystectomy (Elective, Jan 2025 - Uneventful)',
      ],
      currentMedications: [
        'Yogaraja Guggulu - 2 tablets BD after food',
        'Shallaki 500mg - 1 capsule BD',
        'Mahanarayan Taila - Topical application on knees',
      ],
      allergies: [
        'Sulfa drugs (Causes mild erythematous rash)',
        'No known food or herbal allergies',
      ],
      familyHistory: [
        'Father: Type 2 Diabetes Mellitus & Hypertension (Well-controlled)',
        'Mother: History of Osteoarthritis in later age (60+)',
      ],
      personalHistory: {
        'Diet': 'Predominantly vegetarian, moderate spice tolerance',
        'Appetite & Digestion': 'Agni: Vishamagni (Variable digestion & occasional bloating)',
        'Sleep': '6-7 hours/night, occasional disturbance due to back ache',
        'Bowel / Bladder': 'Regular bowel habits (1x/day), no dysuria',
        'AYUSH Prakriti': 'Vata-Pitta predominant constitution',
        'Addictions / Habits': 'Non-smoker, non-alcoholic, tea 2x daily',
      },
      previousInvestigations: [
        'Biochemistry Panel (May 2026): FBS 98 mg/dL, HbA1c 5.6%, Creatinine 0.95 mg/dL',
        'Inflammatory Markers: ESR 22 mm/hr (Mild elevation), CRP 4.8 mg/L',
        'X-Ray Bilateral Knees AP/Lat: Mild joint space narrowing medial compartment',
      ],
      aiClinicalImpression:
          'Presentation strongly aligns with Sandhigata Vata (Degenerative Joint Disorder with Vata aggravation). '
          'Recommended for AYUSH Panchakarma evaluation (Janu Basti / Patra Pinda Sveda) '
          'and dietary modulation for Pitta-Vata balance.',
    );
  }
}
