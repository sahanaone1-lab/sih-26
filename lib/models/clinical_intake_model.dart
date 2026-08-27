import 'package:flutter/material.dart';

/// Message in the AI Health Conversation.
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isVoiceInput;
  final List<String>? quickSuggestions;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isVoiceInput = false,
    this.quickSuggestions,
  });
}

/// Voice recording and speech-to-text transcript record.
class VoiceIntakeRecord {
  final String id;
  final String patientAbhaId;
  final String languageName;
  final String languageCode;
  final String originalTranscript;
  final String editedTranscript;
  final Duration recordingDuration;
  final DateTime recordedAt;

  const VoiceIntakeRecord({
    required this.id,
    required this.patientAbhaId,
    required this.languageName,
    required this.languageCode,
    required this.originalTranscript,
    required this.editedTranscript,
    required this.recordingDuration,
    required this.recordedAt,
  });
}

/// Document type enumeration for OCR scanning.
enum MedicalDocType {
  prescription,
  labReport,
  dischargeSummary,
  otherDocument,
}

extension MedicalDocTypeExtension on MedicalDocType {
  String get displayName {
    switch (this) {
      case MedicalDocType.prescription:
        return 'Prescription';
      case MedicalDocType.labReport:
        return 'Lab Report';
      case MedicalDocType.dischargeSummary:
        return 'Discharge Summary';
      case MedicalDocType.otherDocument:
        return 'Medical Document';
    }
  }

  IconData get icon {
    switch (this) {
      case MedicalDocType.prescription:
        return Icons.receipt_long_rounded;
      case MedicalDocType.labReport:
        return Icons.biotech_rounded;
      case MedicalDocType.dischargeSummary:
        return Icons.medical_information_rounded;
      case MedicalDocType.otherDocument:
        return Icons.description_rounded;
    }
  }
}

/// Scanned medical document with extracted OCR details.
class ScannedDocument {
  final String id;
  final String title;
  final MedicalDocType docType;
  final DateTime documentDate;
  final String issuingFacilityOrDoctor;
  final String rawOcrText;
  final List<String> extractedDiagnoses;
  final List<String> extractedMedications;
  final List<String> extractedLabValues;
  final String summary;

  const ScannedDocument({
    required this.id,
    required this.title,
    required this.docType,
    required this.documentDate,
    required this.issuingFacilityOrDoctor,
    required this.rawOcrText,
    required this.extractedDiagnoses,
    required this.extractedMedications,
    required this.extractedLabValues,
    required this.summary,
  });
}

/// Category of events in the patient's medical history timeline.
enum TimelineCategory {
  aiIntake,
  voiceNarration,
  scannedDoc,
  diagnosis,
  medication,
  labReport,
  hospitalVisit,
}

extension TimelineCategoryExtension on TimelineCategory {
  String get displayName {
    switch (this) {
      case TimelineCategory.aiIntake:
        return 'AI Intake';
      case TimelineCategory.voiceNarration:
        return 'Voice History';
      case TimelineCategory.scannedDoc:
        return 'OCR Scanned Doc';
      case TimelineCategory.diagnosis:
        return 'Diagnosis';
      case TimelineCategory.medication:
        return 'Medication';
      case TimelineCategory.labReport:
        return 'Lab Investigation';
      case TimelineCategory.hospitalVisit:
        return 'Consultation / Visit';
    }
  }

  IconData get icon {
    switch (this) {
      case TimelineCategory.aiIntake:
        return Icons.smart_toy_rounded;
      case TimelineCategory.voiceNarration:
        return Icons.mic_rounded;
      case TimelineCategory.scannedDoc:
        return Icons.document_scanner_rounded;
      case TimelineCategory.diagnosis:
        return Icons.local_hospital_rounded;
      case TimelineCategory.medication:
        return Icons.medication_rounded;
      case TimelineCategory.labReport:
        return Icons.science_rounded;
      case TimelineCategory.hospitalVisit:
        return Icons.calendar_today_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TimelineCategory.aiIntake:
        return const Color(0xFF046A38); // Green
      case TimelineCategory.voiceNarration:
        return const Color(0xFFFF671F); // Saffron
      case TimelineCategory.scannedDoc:
        return const Color(0xFF1E3A8A); // Blue
      case TimelineCategory.diagnosis:
        return const Color(0xFFDC2626); // Red
      case TimelineCategory.medication:
        return const Color(0xFF7C3AED); // Purple
      case TimelineCategory.labReport:
        return const Color(0xFF0284C7); // Cyan/Sky
      case TimelineCategory.hospitalVisit:
        return const Color(0xFF0A192F); // Navy
    }
  }
}

/// Chronological event item in the medical timeline.
class TimelineEvent {
  final String id;
  final String title;
  final TimelineCategory category;
  final DateTime date;
  final String summary;
  final List<String> details;
  final String sourceTag; // e.g. "ABDM Synced", "AI Intake", "OCR Scan"

  const TimelineEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.summary,
    required this.details,
    required this.sourceTag,
  });
}

/// Structured AI Clinical History Summary matching standard medical documentation.
class ClinicalHistorySummary {
  final String patientAbhaId;
  final String patientName;
  final DateTime generatedAt;
  final String chiefComplaint;
  final String historyOfPresentIllness;
  final List<String> pastMedicalHistory;
  final List<String> pastSurgicalHistory;
  final List<String> currentMedications;
  final List<String> allergies;
  final List<String> familyHistory;
  final Map<String, String> personalHistory; // Diet, Sleep, Habits, Prakriti
  final List<String> previousInvestigations;
  final String aiClinicalImpression;

  const ClinicalHistorySummary({
    required this.patientAbhaId,
    required this.patientName,
    required this.generatedAt,
    required this.chiefComplaint,
    required this.historyOfPresentIllness,
    required this.pastMedicalHistory,
    required this.pastSurgicalHistory,
    required this.currentMedications,
    required this.allergies,
    required this.familyHistory,
    required this.personalHistory,
    required this.previousInvestigations,
    required this.aiClinicalImpression,
  });
}
