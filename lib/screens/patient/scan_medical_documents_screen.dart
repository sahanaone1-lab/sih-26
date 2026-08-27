import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/clinical_intake_model.dart';
import '../../models/patient_model.dart';
import '../../services/clinical_intake_service.dart';
import 'medical_history_timeline_screen.dart';

/// Screen 3: Scan Medical Documents (OCR Scanner)
///
/// Enables patients to upload or scan previous prescriptions, lab reports,
/// discharge summaries, and extract digitized medical data via OCR.
class ScanMedicalDocumentsScreen extends StatefulWidget {
  final PatientModel patient;

  const ScanMedicalDocumentsScreen({super.key, required this.patient});

  @override
  State<ScanMedicalDocumentsScreen> createState() =>
      _ScanMedicalDocumentsScreenState();
}

class _ScanMedicalDocumentsScreenState
    extends State<ScanMedicalDocumentsScreen> {
  final _service = ClinicalIntakeService.instance;
  late List<ScannedDocument> _documents;

  bool _isScanning = false;
  MedicalDocType _selectedType = MedicalDocType.prescription;
  ScannedDocument? _recentlyScannedDoc;

  @override
  void initState() {
    super.initState();
    _documents = List.from(_service.getScannedDocuments(widget.patient));
  }

  void _triggerScanSimulation(ScannedDocument template) async {
    setState(() {
      _isScanning = true;
      _recentlyScannedDoc = null;
    });

    // Simulate Optical Character Recognition scan processing
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final newDoc = ScannedDocument(
      id: 'scanned_${DateTime.now().millisecondsSinceEpoch}',
      title: '${_selectedType.displayName} - ${template.title}',
      docType: _selectedType,
      documentDate: DateTime.now(),
      issuingFacilityOrDoctor: template.issuingFacilityOrDoctor,
      rawOcrText: template.rawOcrText,
      extractedDiagnoses: template.extractedDiagnoses,
      extractedMedications: template.extractedMedications,
      extractedLabValues: template.extractedLabValues,
      summary: template.summary,
    );

    _service.addScannedDocument(widget.patient, newDoc);

    setState(() {
      _isScanning = false;
      _recentlyScannedDoc = newDoc;
      _documents = List.from(_service.getScannedDocuments(widget.patient));
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OCR extraction successful for ${newDoc.title}'),
        backgroundColor: AppColors.greenSuccess,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showScanModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(22.0),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Scan or Upload Medical Document',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyPrimary,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  const Text(
                    'Choose document type and sample template to run OCR extraction.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 18.0),

                  // Document Type Selection
                  const Text('Document Type',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navyPrimary)),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: MedicalDocType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return ChoiceChip(
                        label: Text(type.displayName),
                        avatar: Icon(type.icon,
                            size: 16.0,
                            color: isSelected
                                ? Colors.white
                                : AppColors.navyPrimary),
                        selected: isSelected,
                        selectedColor: AppColors.greenSuccess,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.navyPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.0,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => _selectedType = type);
                            setState(() => _selectedType = type);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20.0),

                  // Select Sample to Scan
                  const Text('Select Sample Document to Scan',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navyPrimary)),
                  const SizedBox(height: 8.0),
                  ...ClinicalIntakeService.sampleDocumentTemplates.map((template) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        _triggerScanSimulation(template);
                      },
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: AppColors.greenLight,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(template.docType.icon,
                                  color: AppColors.greenSuccess, size: 20.0),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template.title,
                                    style: const TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.navyPrimary),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    template.issuingFacilityOrDoctor,
                                    style: const TextStyle(
                                        fontSize: 11.0,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.document_scanner_rounded,
                                color: AppColors.saffronDark, size: 20.0),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12.0),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _triggerScanSimulation(
                          ClinicalIntakeService.sampleDocumentTemplates.first);
                    },
                    icon: const Icon(Icons.camera_alt_rounded, size: 18.0),
                    label: const Text('Capture with Device Camera & Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.saffronPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
          'Scan Medical Documents',
          style: TextStyle(
            color: AppColors.navyPrimary,
            fontSize: 16.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'View Timeline',
            icon: const Icon(Icons.timeline_rounded, color: AppColors.navyPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      MedicalHistoryTimelineScreen(patient: widget.patient),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scanner trigger header
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF046A38), Color(0xFF023E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18.0),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 14.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: const Icon(
                            Icons.document_scanner_rounded,
                            color: Colors.white,
                            size: 28.0,
                          ),
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'AI OCR Medical Scanner',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 3.0),
                              Text(
                                'Upload prescriptions, lab reports & discharge notes to extract clinical data.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isScanning ? null : _showScanModal,
                        icon: _isScanning
                            ? const SizedBox(
                                width: 16.0,
                                height: 16.0,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.0, color: Colors.white),
                              )
                            : const Icon(Icons.add_photo_alternate_rounded,
                                size: 18.0),
                        label: Text(
                          _isScanning ? 'Extracting Text via OCR...' : 'Scan New Document',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.saffronPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Recently Scanned Result (if any)
              if (_recentlyScannedDoc != null) ...[
                Row(
                  children: const [
                    Icon(Icons.auto_awesome_rounded,
                        color: AppColors.saffronDark, size: 18.0),
                    SizedBox(width: 6.0),
                    Text(
                      'Just Extracted via OCR',
                      style: TextStyle(
                        color: AppColors.navyPrimary,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                ExtractedDocumentCard(
                  doc: _recentlyScannedDoc!,
                  isHighlighted: true,
                  initiallyExpanded: true,
                ),
                const SizedBox(height: 24.0),
              ],

              // Scanned & Digitized Documents List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Digitized Medical Records',
                    style: TextStyle(
                      color: AppColors.navyPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${_documents.length} Records',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              ..._documents.map((doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: ExtractedDocumentCard(doc: doc),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom clean expandable card displaying extracted OCR medical data.
class ExtractedDocumentCard extends StatefulWidget {
  final ScannedDocument doc;
  final bool isHighlighted;
  final bool initiallyExpanded;

  const ExtractedDocumentCard({
    super.key,
    required this.doc,
    this.isHighlighted = false,
    this.initiallyExpanded = false,
  });

  @override
  State<ExtractedDocumentCard> createState() => _ExtractedDocumentCardState();
}

class _ExtractedDocumentCardState extends State<ExtractedDocumentCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded || widget.isHighlighted;
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: widget.isHighlighted
              ? AppColors.saffronPrimary
              : AppColors.surfaceBorder,
          width: widget.isHighlighted ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16.0),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: doc.docType == MedicalDocType.prescription
                          ? AppColors.saffronLight
                          : AppColors.greenLight,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(
                      doc.docType.icon,
                      color: doc.docType == MedicalDocType.prescription
                          ? AppColors.saffronDark
                          : AppColors.greenSuccess,
                      size: 22.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navyPrimary,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          doc.issuingFacilityOrDoctor,
                          style: const TextStyle(
                              fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Dated: ${doc.documentDate.day}/${doc.documentDate.month}/${doc.documentDate.year} • OCR Processed',
                          style: const TextStyle(
                              fontSize: 10.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.navyPrimary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 16.0, color: AppColors.divider),
                  // Extracted Diagnoses
                  if (doc.extractedDiagnoses.isNotEmpty) ...[
                    const Text('Extracted Diagnosis:',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyPrimary)),
                    const SizedBox(height: 4.0),
                    ...doc.extractedDiagnoses.map((diag) => Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 13.0, color: AppColors.greenSuccess),
                              const SizedBox(width: 6.0),
                              Expanded(
                                child: Text(diag,
                                    style: const TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.navyLight)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 10.0),
                  ],

                  // Extracted Medications
                  if (doc.extractedMedications.isNotEmpty) ...[
                    const Text('Prescribed Medications:',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyPrimary)),
                    const SizedBox(height: 4.0),
                    ...doc.extractedMedications.map((med) => Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Row(
                            children: [
                              const Icon(Icons.medication_rounded,
                                  size: 13.0, color: AppColors.saffronDark),
                              const SizedBox(width: 6.0),
                              Expanded(
                                child: Text(med,
                                    style: const TextStyle(
                                        fontSize: 12.0,
                                        color: AppColors.textPrimary)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 10.0),
                  ],

                  // Extracted Lab Values
                  if (doc.extractedLabValues.isNotEmpty) ...[
                    const Text('Key Lab Markers:',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyPrimary)),
                    const SizedBox(height: 4.0),
                    ...doc.extractedLabValues.map((lab) => Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Row(
                            children: [
                              const Icon(Icons.biotech_rounded,
                                  size: 13.0, color: Color(0xFF0284C7)),
                              const SizedBox(width: 6.0),
                              Expanded(
                                child: Text(lab,
                                    style: const TextStyle(
                                        fontSize: 12.0,
                                        color: AppColors.textPrimary)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 10.0),
                  ],

                  // Raw OCR Text Viewer Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RAW OCR EXTRACTED TEXT:',
                          style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          doc.rawOcrText.trim(),
                          style: const TextStyle(
                            fontSize: 11.0,
                            fontFamily: 'monospace',
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
