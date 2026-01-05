import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/upload_service.dart';

class DocumentsUploadScreen extends ConsumerStatefulWidget {
  const DocumentsUploadScreen({super.key});

  @override
  ConsumerState<DocumentsUploadScreen> createState() =>
      _DocumentsUploadScreenState();
}

class _DocumentsUploadScreenState extends ConsumerState<DocumentsUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  File? _nationalIdFrontFile;
  File? _nationalIdBackFile;
  File? _licenseFile;
  File? _vehicleRegistrationFile;

  String? _nationalIdFrontUrl;
  String? _nationalIdBackUrl;
  String? _licenseUrl;
  String? _vehicleRegistrationUrl;

  bool _isUploading = false;
  String? _currentUploadingDocument;
  double _uploadProgress = 0.0;

  bool get _allDocumentsUploaded =>
      _nationalIdFrontUrl != null &&
      _nationalIdBackUrl != null &&
      _licenseUrl != null &&
      _vehicleRegistrationUrl != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رفع المستندات'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.driverGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.upload_file,
                        size: 48,
                        color: AppColors.white,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ارفع مستنداتك',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'نحتاج للتحقق من هويتك ورخصتك للبدء في التوصيل',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Progress Indicator
                _buildProgressIndicator(),
                const SizedBox(height: 24),

                // Document Cards
                _DocumentUploadCard(
                  title: 'البطاقة الشخصية (الوجه)',
                  subtitle: 'صورة واضحة للوجه الأمامي للبطاقة',
                  icon: Icons.badge,
                  file: _nationalIdFrontFile,
                  uploadedUrl: _nationalIdFrontUrl,
                  isUploading: _currentUploadingDocument == 'national_id_front',
                  onTap: () => _pickAndUploadDocument(
                    'national_id_front',
                    'البطاقة الشخصية (الوجه)',
                  ),
                  onRemove: () => _removeDocument('national_id_front'),
                ),
                const SizedBox(height: 12),

                _DocumentUploadCard(
                  title: 'البطاقة الشخصية (الخلف)',
                  subtitle: 'صورة واضحة للوجه الخلفي للبطاقة',
                  icon: Icons.badge_outlined,
                  file: _nationalIdBackFile,
                  uploadedUrl: _nationalIdBackUrl,
                  isUploading: _currentUploadingDocument == 'national_id_back',
                  onTap: () => _pickAndUploadDocument(
                    'national_id_back',
                    'البطاقة الشخصية (الخلف)',
                  ),
                  onRemove: () => _removeDocument('national_id_back'),
                ),
                const SizedBox(height: 12),

                _DocumentUploadCard(
                  title: 'رخصة القيادة',
                  subtitle: 'صورة واضحة لرخصة القيادة السارية',
                  icon: Icons.credit_card,
                  file: _licenseFile,
                  uploadedUrl: _licenseUrl,
                  isUploading: _currentUploadingDocument == 'license',
                  onTap: () => _pickAndUploadDocument(
                    'license',
                    'رخصة القيادة',
                  ),
                  onRemove: () => _removeDocument('license'),
                ),
                const SizedBox(height: 12),

                _DocumentUploadCard(
                  title: 'رخصة المركبة',
                  subtitle: 'صورة واضحة لرخصة تسيير المركبة',
                  icon: Icons.directions_car,
                  file: _vehicleRegistrationFile,
                  uploadedUrl: _vehicleRegistrationUrl,
                  isUploading: _currentUploadingDocument == 'vehicle_registration',
                  onTap: () => _pickAndUploadDocument(
                    'vehicle_registration',
                    'رخصة المركبة',
                  ),
                  onRemove: () => _removeDocument('vehicle_registration'),
                ),
                const SizedBox(height: 24),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معلومات هامة',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.info,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تأكد من أن الصور واضحة وجميع البيانات مقروءة. يجب أن تكون المستندات سارية المفعول.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Submit Button
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _allDocumentsUploaded && !_isUploading
                    ? _submitDocuments
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'إرسال للمراجعة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    int uploadedCount = 0;
    if (_nationalIdFrontUrl != null) uploadedCount++;
    if (_nationalIdBackUrl != null) uploadedCount++;
    if (_licenseUrl != null) uploadedCount++;
    if (_vehicleRegistrationUrl != null) uploadedCount++;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تقدم الرفع',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '$uploadedCount / 4 مستندات',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: uploadedCount / 4,
          backgroundColor: AppColors.grey200,
          valueColor: AlwaysStoppedAnimation<Color>(
            uploadedCount == 4 ? AppColors.success : AppColors.primary,
          ),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
      ],
    );
  }

  void _showUploadSourceDialog(String documentType, String documentName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'رفع $documentName',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _UploadSourceOption(
                    icon: Icons.camera_alt,
                    label: 'الكاميرا',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(documentType, ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _UploadSourceOption(
                    icon: Icons.photo_library,
                    label: 'المعرض',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(documentType, ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadDocument(String documentType, String documentName) async {
    _showUploadSourceDialog(documentType, documentName);
  }

  Future<void> _pickImage(String documentType, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) return;

      final file = File(image.path);

      setState(() {
        switch (documentType) {
          case 'national_id_front':
            _nationalIdFrontFile = file;
            break;
          case 'national_id_back':
            _nationalIdBackFile = file;
            break;
          case 'license':
            _licenseFile = file;
            break;
          case 'vehicle_registration':
            _vehicleRegistrationFile = file;
            break;
        }
        _currentUploadingDocument = documentType;
        _isUploading = true;
      });

      // Upload the image
      final uploadService = ref.read(uploadServiceProvider);
      final imageUrl = await uploadService.uploadImage(file);

      if (!mounted) return;

      setState(() {
        switch (documentType) {
          case 'national_id_front':
            _nationalIdFrontUrl = imageUrl;
            break;
          case 'national_id_back':
            _nationalIdBackUrl = imageUrl;
            break;
          case 'license':
            _licenseUrl = imageUrl;
            break;
          case 'vehicle_registration':
            _vehicleRegistrationUrl = imageUrl;
            break;
        }
        _currentUploadingDocument = null;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفع المستند بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentUploadingDocument = null;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل رفع المستند: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeDocument(String documentType) {
    setState(() {
      switch (documentType) {
        case 'national_id_front':
          _nationalIdFrontFile = null;
          _nationalIdFrontUrl = null;
          break;
        case 'national_id_back':
          _nationalIdBackFile = null;
          _nationalIdBackUrl = null;
          break;
        case 'license':
          _licenseFile = null;
          _licenseUrl = null;
          break;
        case 'vehicle_registration':
          _vehicleRegistrationFile = null;
          _vehicleRegistrationUrl = null;
          break;
      }
    });
  }

  Future<void> _submitDocuments() async {
    if (!_allDocumentsUploaded) return;

    setState(() => _isUploading = true);

    try {
      final uploadService = ref.read(uploadServiceProvider);
      await uploadService.updateDocuments({
        'nationalIdFront': _nationalIdFrontUrl!,
        'nationalIdBack': _nationalIdBackUrl!,
        'licenseImage': _licenseUrl!,
        'vehicleRegistration': _vehicleRegistrationUrl!,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال المستندات للمراجعة'),
          backgroundColor: AppColors.success,
        ),
      );

      context.go(AppRoutes.pendingApproval);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إرسال المستندات: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final File? file;
  final String? uploadedUrl;
  final bool isUploading;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _DocumentUploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.file,
    required this.uploadedUrl,
    required this.isUploading,
    required this.onTap,
    required this.onRemove,
  });

  bool get isUploaded => uploadedUrl != null;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: isUploading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isUploading
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : file != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              file!,
                              fit: BoxFit.cover,
                              width: 56,
                              height: 56,
                            ),
                          )
                        : Icon(
                            icon,
                            color: isUploaded
                                ? AppColors.success
                                : AppColors.textSecondary,
                            size: 28,
                          ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUploaded ? 'تم الرفع' : subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isUploaded
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (isUploaded)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.close, color: AppColors.error),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                )
              else
                Icon(
                  Icons.cloud_upload_outlined,
                  color: isUploading ? AppColors.primary : AppColors.grey400,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
