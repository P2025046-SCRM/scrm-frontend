import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:scrm/common/styles/text_styles.dart';
import 'package:scrm/common/widgets/appbar_widget.dart';
import 'package:scrm/common/widgets/hl_button_widget.dart';
import 'package:scrm/common/widgets/text_field_widget.dart';
import 'package:scrm/data/services/history_service.dart';
import 'package:scrm/utils/waste_type_helper.dart';
import 'package:scrm/utils/logger.dart';

class FeedbackScreen extends StatefulWidget {
  final String predictionId;
  final String imagePath;
  final bool isAssetImage;
  final String layer1;
  final String? layer2;
  final double layer1Confidence;
  final double? layer2Confidence;

  const FeedbackScreen({
    super.key,
    required this.predictionId,
    required this.imagePath,
    required this.isAssetImage,
    required this.layer1,
    this.layer2,
    required this.layer1Confidence,
    this.layer2Confidence,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  bool _isCorrect = true;
  String? _selectedL1Class;
  String? _selectedL2Class;
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;
  bool _isLoadingFeedback = true;
  
  // Store initial values to compare if there are any changes
  bool _initialIsCorrect = true;
  String? _initialL1Class;
  String? _initialL2Class;
  String _initialNotes = '';
  
  // Store existing feedback data for display
  Map<String, dynamic>? _existingFeedback;

  // The 4 recyclable classes (display format)
  static const List<String> recyclableClasses = [
    'Retazos',
    'Biomasa',
    'Metales',
    'Plásticos',
  ];

  // Helper function to normalize display class name to model format
  String? _normalizeClassToModelFormat(String? displayClass) {
    if (displayClass == null) return null;
    // Map "Plásticos" (display) to "Plastico" (model format)
    if (displayClass == 'Plásticos') {
      return 'Plastico';
    }
    return displayClass;
  }

  // Helper function to convert model format to display format
  String? _modelFormatToDisplayFormat(String? modelClass) {
    if (modelClass == null) return null;
    // Map "Plastico" (model format) to "Plásticos" (display)
    if (modelClass == 'Plastico') {
      return 'Plásticos';
    }
    return modelClass;
  }

  // Helper function to format reviewed_at date
  String _formatReviewedAtDate(dynamic reviewedAt) {
    if (reviewedAt == null) return '';
    
    try {
      DateTime dateTime;
      if (reviewedAt is DateTime) {
        dateTime = reviewedAt;
      } else if (reviewedAt is String) {
        dateTime = DateTime.parse(reviewedAt);
      } else {
        // Handle Firestore Timestamp
        dateTime = reviewedAt.toDate();
      }
      
      final localDateTime = dateTime.toLocal();
      return 'Revisado: ${localDateTime.day}/${localDateTime.month}/${localDateTime.year} ${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
    } catch (e, stackTrace) {
      AppLogger.logError(e, stackTrace: stackTrace, reason: 'Error formatting reviewed_at date');
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen to notes controller to update button state
    _notesController.addListener(() {
      setState(() {}); // Rebuild to update save button state
    });
    
    // Load existing feedback
    _loadExistingFeedback();
  }

  Future<void> _loadExistingFeedback() async {
    try {
      final historyService = Provider.of<HistoryService>(context, listen: false);
      final feedback = await historyService.getUserFeedback(predictionId: widget.predictionId);
      
      if (mounted && feedback != null) {
        final isCorrect = feedback['is_correct'] as bool? ?? true;
        final correctL1Class = feedback['correct_l1_class'] as String?;
        final correctL2Class = feedback['correct_l2_class'] as String?;
        final notes = feedback['notes'] as String?;
        
        setState(() {
          _existingFeedback = feedback;
          _isCorrect = isCorrect;
          _selectedL1Class = correctL1Class;
          // Convert model format to display format for L2 (e.g., "Plastico" -> "Plásticos")
          _selectedL2Class = _modelFormatToDisplayFormat(correctL2Class);
          _notesController.text = notes ?? '';
          
          // Store initial values for comparison
          _initialIsCorrect = isCorrect;
          _initialL1Class = correctL1Class;
          _initialL2Class = correctL2Class;
          _initialNotes = notes ?? '';
          
          _isLoadingFeedback = false;
        });
      } else {
        // No existing feedback, use defaults
        if (mounted) {
          setState(() {
            _isLoadingFeedback = false;
          });
        }
      }
    } catch (e, stackTrace) {
      AppLogger.logError(e, stackTrace: stackTrace, reason: 'Error loading existing feedback');
      if (mounted) {
        setState(() {
          _isLoadingFeedback = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    // Check if isCorrect has changed
    if (_isCorrect != _initialIsCorrect) {
      return true;
    }
    
    // Check if L1 class has changed (only relevant if incorrect)
    if (!_isCorrect) {
      if (_selectedL1Class != _initialL1Class) {
        return true;
      }
      
      // Check if L2 class has changed (only relevant if Reciclable)
      if (_selectedL1Class == 'Reciclable') {
        final currentL2Normalized = _normalizeClassToModelFormat(_selectedL2Class);
        if (currentL2Normalized != _initialL2Class) {
          return true;
        }
      }
    }
    
    // Check if notes have changed
    if (_notesController.text.trim() != _initialNotes) {
      return true;
    }
    
    return false;
  }

  bool _isSaveButtonEnabled() {
    // If no changes have been made, disable save button
    if (!_hasChanges()) {
      return false;
    }
    
    // If toggle is true (default) and no other changes, notes must be provided
    if (_isCorrect == true && _selectedL1Class == null && _selectedL2Class == null) {
      if (_notesController.text.trim().isEmpty) {
        return false;
      }
    }
    
    return true;
  }

  Future<void> _saveFeedback() async {
    if (_isSaving) return;

    // Validation: if no changes have been made
    if (!_hasChanges()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se han realizado cambios'),
        ),
      );
      return;
    }
    
    // Validation: if toggle is true and no other changes, notes are required
    if (_isCorrect == true && _selectedL1Class == null && _selectedL2Class == null) {
      if (_notesController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor agregue notas para guardar'),
          ),
        );
        return;
      }
    }

    // Validation: if incorrect, must select L1 class
    if (!_isCorrect && _selectedL1Class == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione si es Reciclable o No Reciclable'),
        ),
      );
      return;
    }

    // Validation: if Reciclable is selected, must select L2 class
    if (!_isCorrect && _selectedL1Class == 'Reciclable' && _selectedL2Class == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione una clase de reciclable'),
        ),
      );
      return;
    }

    // Validation: if incorrect and selected classes match predicted classes
    if (!_isCorrect) {
      final predictedL1 = widget.layer1;
      final predictedL2 = widget.layer2;
      
      // Normalize layer1 for comparison (handle "NoReciclable" vs display format)
      final selectedL1Normalized = _selectedL1Class;
      final predictedL1Normalized = predictedL1 == 'NoReciclable' ? 'NoReciclable' : predictedL1;
      
      // Check if L1 matches
      bool l1Matches = selectedL1Normalized == predictedL1Normalized;
      
      // Check if L2 matches (if applicable)
      bool l2Matches = true; // Default to true if not applicable
      if (selectedL1Normalized == 'Reciclable' && predictedL1Normalized == 'Reciclable') {
        // Normalize selected L2 class to model format for comparison
        final selectedL2Normalized = _normalizeClassToModelFormat(_selectedL2Class);
        l2Matches = selectedL2Normalized == predictedL2;
      } else if (selectedL1Normalized != 'Reciclable' && predictedL1Normalized != 'Reciclable') {
        // Both are NoReciclable, so L2 doesn't matter
        l2Matches = true;
      } else {
        // One is Reciclable and one is not, so they don't match
        l2Matches = false;
      }
      
      if (l1Matches && l2Matches) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las clases seleccionadas son las mismas que las predichas. No se realizarán cambios.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final historyService = Provider.of<HistoryService>(context, listen: false);

      await historyService.updateUserFeedback(
        predictionId: widget.predictionId,
        isCorrect: _isCorrect,
        correctL1Class: _isCorrect ? null : _selectedL1Class,
        // Normalize L2 class to model format before saving (e.g., "Plásticos" -> "Plastico")
        correctL2Class: _isCorrect ? null : _normalizeClassToModelFormat(_selectedL2Class),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Retroalimentación guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while loading feedback
    if (_isLoadingFeedback) {
      return Scaffold(
        appBar: CustomAppbar(title: 'Retroalimentación', showProfile: false),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Format classification text
    final String classificationText = WasteTypeHelper.getWasteType(widget.layer1, widget.layer2 ?? '');
    final String displayLayer1 = widget.layer1 == 'NoReciclable' ? 'No Reciclable' : widget.layer1;
    final String layer1ConfidenceText = (widget.layer1Confidence * 100).toStringAsFixed(1);
    final String? layer2ConfidenceText = widget.layer2Confidence != null
        ? (widget.layer2Confidence! * 100).toStringAsFixed(1)
        : null;

    // Build image path with SAS token if needed
    String imagePath = widget.imagePath;
    // Only append SAS token if it's not already appended and it's a network URL
    if (imagePath.isNotEmpty && imagePath.startsWith('http')) {
      // Check if SAS token is already appended
      final hasSasToken = imagePath.contains('?') || imagePath.contains('&');
      if (!hasSasToken) {
        try {
          final sasToken = dotenv.env['AZURE_CONTAINER_SAS_TOKEN'];
          if (sasToken != null && sasToken.isNotEmpty) {
            imagePath = '$imagePath?$sasToken';
          }
        } catch (e, stackTrace) {
          AppLogger.logError(e, stackTrace: stackTrace, reason: 'Error appending SAS token to image URL');
        }
      }
    }
    
    // Determine if image is asset or network based on final imagePath
    final bool isNetworkImage = imagePath.isNotEmpty && 
                                (imagePath.startsWith('http://') || imagePath.startsWith('https://'));
    final bool isAssetImage = !isNetworkImage && imagePath.isNotEmpty && imagePath.startsWith('assets/');
    final String finalImagePath = imagePath.isEmpty || (!isNetworkImage && !isAssetImage)
        ? 'assets/sample_wood_image.jpg'
        : imagePath;

    return Scaffold(
      appBar: CustomAppbar(title: 'Retroalimentación', showProfile: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image display - top center
            Container(
              width: double.infinity,
              height: 250,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                boxShadow: List<BoxShadow>.generate(
                  3,
                  (index) => BoxShadow(
                    color: const Color.fromARGB(33, 0, 0, 0),
                    blurRadius: 2 * (index + 1),
                    offset: Offset(0, 2 * (index + 1)),
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isNetworkImage
                    ? Image.network(
                        finalImagePath,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.fill,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error, size: 50, color: Colors.grey),
                          );
                        },
                      )
                    : Image.asset(
                        finalImagePath,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error, size: 50, color: Colors.grey),
                          );
                        },
                      ),
              ),
            ),

            // Existing feedback display (only show if feedback exists and is not just default)
            if (_existingFeedback != null && 
                (_existingFeedback!['is_correct'] != true || 
                 _existingFeedback!['notes'] != null ||
                 _existingFeedback!['correct_l1_class'] != null)) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: List<BoxShadow>.generate(
                    3,
                    (index) => BoxShadow(
                      color: const Color.fromARGB(33, 0, 0, 0),
                      blurRadius: 2 * (index + 1),
                      offset: Offset(0, 2 * (index + 1)),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Revisión del Operador', style: kSubtitleTextStyle),
                    const SizedBox(height: 12),
                    // Status: Correcto/Incorrecto
                    Row(
                      children: [
                        Text('Estado: ', style: kRegularTextStyle),
                        Text(
                          _existingFeedback!['is_correct'] == true ? 'Correcto' : 'Incorrecto',
                          style: kRegularTextStyle.copyWith(
                            color: _existingFeedback!['is_correct'] == true 
                                ? Colors.green 
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Correct classification if Incorrecto
                    if (_existingFeedback!['is_correct'] != true) ...[
                      const SizedBox(height: 8),
                      if (_existingFeedback!['correct_l1_class'] != null) ...[
                        Text(
                          'Clasificación Correcta: ${_existingFeedback!['correct_l1_class'] == 'NoReciclable' ? 'No Reciclable' : _existingFeedback!['correct_l1_class']}',
                          style: kRegularTextStyle,
                        ),
                        if (_existingFeedback!['correct_l2_class'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Clase: ${_modelFormatToDisplayFormat(_existingFeedback!['correct_l2_class']) ?? _existingFeedback!['correct_l2_class']}',
                            style: kRegularTextStyle,
                          ),
                        ],
                      ],
                    ],
                    // Reviewed at date
                    if (_existingFeedback!['reviewed_at'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _formatReviewedAtDate(_existingFeedback!['reviewed_at']),
                        style: kDescriptionTextStyle,
                      ),
                    ],
                    // Notes if exists
                    if (_existingFeedback!['notes'] != null && 
                        (_existingFeedback!['notes'] as String).isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Notas:', style: kRegularTextStyle),
                      const SizedBox(height: 4),
                      Text(
                        _existingFeedback!['notes'] as String,
                        style: kDescriptionTextStyle,
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Classification display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                boxShadow: List<BoxShadow>.generate(
                  3,
                  (index) => BoxShadow(
                    color: const Color.fromARGB(33, 0, 0, 0),
                    blurRadius: 2 * (index + 1),
                    offset: Offset(0, 2 * (index + 1)),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Clasificación', style: kSubtitleTextStyle),
                  const SizedBox(height: 12),
                  Text(
                    'Nivel 1: $displayLayer1 ($layer1ConfidenceText%)',
                    style: kRegularTextStyle,
                  ),
                  if (widget.layer2 != null && layer2ConfidenceText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Nivel 2: ${widget.layer2} ($layer2ConfidenceText%)',
                      style: kRegularTextStyle,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Tipo: $classificationText',
                    style: kRegularTextStyle,
                  ),
                ],
              ),
            ),

            // Toggle: Is correct?
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                boxShadow: List<BoxShadow>.generate(
                  3,
                  (index) => BoxShadow(
                    color: const Color.fromARGB(33, 0, 0, 0),
                    blurRadius: 2 * (index + 1),
                    offset: Offset(0, 2 * (index + 1)),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('¿Es correcta?', style: kRegularTextStyle),
                  Switch(
                    value: _isCorrect,
                    onChanged: (value) {
                      setState(() {
                        _isCorrect = value;
                        if (value) {
                          // Reset selections when toggling to correct
                          _selectedL1Class = null;
                          _selectedL2Class = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            // Radio buttons: Reciclable or No Reciclable (only if incorrect)
            if (!_isCorrect) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: List<BoxShadow>.generate(
                    3,
                    (index) => BoxShadow(
                      color: const Color.fromARGB(33, 0, 0, 0),
                      blurRadius: 2 * (index + 1),
                      offset: Offset(0, 2 * (index + 1)),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Seleccione el tipo correcto:', style: kRegularTextStyle),
                    const SizedBox(height: 12),
                    RadioGroup<String>(
                      groupValue: _selectedL1Class,
                      onChanged: (value) {
                        setState(() {
                          _selectedL1Class = value;
                          // Reset L2 class when switching to NoReciclable
                          if (value == 'NoReciclable') {
                            _selectedL2Class = null;
                          }
                        });
                      },
                      child: Column(
                        children: [
                          ListTile(
                            leading: Radio<String>(value: 'Reciclable'),
                            title: const Text('Reciclable'),
                            onTap: () {
                              setState(() {
                                _selectedL1Class = 'Reciclable';
                              });
                            },
                          ),
                          ListTile(
                            leading: Radio<String>(value: 'NoReciclable'),
                            title: const Text('No Reciclable'),
                            onTap: () {
                              setState(() {
                                _selectedL1Class = 'NoReciclable';
                                _selectedL2Class = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Dropdown: Recyclable classes (only if Reciclable is selected)
              if (_selectedL1Class == 'Reciclable') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: List<BoxShadow>.generate(
                      3,
                      (index) => BoxShadow(
                        color: const Color.fromARGB(33, 0, 0, 0),
                        blurRadius: 2 * (index + 1),
                        offset: Offset(0, 2 * (index + 1)),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Seleccione la clase:', style: kRegularTextStyle),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey(_selectedL2Class),
                        initialValue: _selectedL2Class,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: recyclableClasses.map((String class_) {
                          return DropdownMenuItem<String>(
                            value: class_,
                            child: Text(class_),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedL2Class = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],

            // Notes field
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                boxShadow: List<BoxShadow>.generate(
                  3,
                  (index) => BoxShadow(
                    color: const Color.fromARGB(33, 0, 0, 0),
                    blurRadius: 2 * (index + 1),
                    offset: Offset(0, 2 * (index + 1)),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notas (opcional)', style: kRegularTextStyle),
                  const SizedBox(height: 12),
                  TextFieldWidget(
                    textController: _notesController,
                    text: 'Agregar notas...',
                    inputType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 1,
                  ),
                ],
              ),
            ),

            // Save button
            SizedBox(
              width: double.infinity,
              child: _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : HighlightedButton(
                      buttonText: 'Guardar',
                      onPressed: _isSaveButtonEnabled() ? _saveFeedback : null,
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


