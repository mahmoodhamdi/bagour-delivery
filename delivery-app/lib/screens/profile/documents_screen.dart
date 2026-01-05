import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/upload_service.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المستندات'),
      ),
      body: authState.maybeWhen(
        authenticated: (user, driver) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor(driver?.status ?? 'pending')
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(driver?.status ?? 'pending'),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(driver?.status ?? 'pending'),
                      color: _getStatusColor(driver?.status ?? 'pending'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حالة التحقق',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _getStatusText(driver?.status ?? 'pending'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: _getStatusColor(driver?.status ?? 'pending'),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // National ID
              _DocumentCard(
                title: 'البطاقة الشخصية',
                subtitle: 'صورة الوجه والخلف',
                icon: Icons.badge_outlined,
                status: 'verified',
                onTap: () => _showUploadDialog(context, 'البطاقة الشخصية'),
              ),
              const SizedBox(height: 12),

              // Driver License
              _DocumentCard(
                title: 'رخصة القيادة',
                subtitle: driver != null
                    ? 'تنتهي في ${_formatDate(driver.licenseExpiryDate)}'
                    : 'لم يتم الرفع',
                icon: Icons.credit_card,
                status: driver != null ? 'verified' : 'pending',
                onTap: () => _showUploadDialog(context, 'رخصة القيادة'),
              ),
              const SizedBox(height: 12),

              // Vehicle License
              _DocumentCard(
                title: 'رخصة المركبة',
                subtitle: 'رخصة تسيير السيارة/الدراجة',
                icon: Icons.directions_car,
                status: 'pending',
                onTap: () => _showUploadDialog(context, 'رخصة المركبة'),
              ),
              const SizedBox(height: 12),

              // Criminal Record
              _DocumentCard(
                title: 'الفيش الجنائي',
                subtitle: 'شهادة حسن السير والسلوك',
                icon: Icons.verified_user_outlined,
                status: 'pending',
                onTap: () => _showUploadDialog(context, 'الفيش الجنائي'),
              ),
              const SizedBox(height: 24),

              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'تأكد من أن جميع المستندات واضحة وصالحة. سيتم مراجعتها خلال 24-48 ساعة.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        orElse: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _showUploadDialog(BuildContext context, String documentType) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'رفع $documentType',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _UploadOption(
                    icon: Icons.camera_alt,
                    label: 'الكاميرا',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(documentType, ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _UploadOption(
                    icon: Icons.photo_library,
                    label: 'المعرض',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(documentType, ImageSource.gallery);
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

  Future<void> _pickAndUploadImage(String documentType, ImageSource source) async {
    try {
      // Pick image
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      setState(() => _isUploading = true);

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Upload image
      final uploadService = ref.read(uploadServiceProvider);
      final imageUrl = await uploadService.uploadImage(File(image.path));

      // Update documents
      String documentKey = '';
      switch (documentType) {
        case 'البطاقة الشخصية':
          documentKey = 'nationalIdImage';
          break;
        case 'رخصة القيادة':
          documentKey = 'licenseImage';
          break;
        case 'رخصة المركبة':
          documentKey = 'vehicleRegistration';
          break;
        case 'الفيش الجنائي':
          documentKey = 'criminalRecord';
          break;
      }

      if (documentKey.isNotEmpty) {
        await uploadService.updateDocuments({documentKey: imageUrl});

        // Refresh auth state to get updated driver data
        await ref.read(authProvider.notifier).refreshUser();
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفع المستند بنجاح!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل رفع المستند: ${e.toString()}'),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'تم التحقق';
      case 'pending':
        return 'قيد المراجعة';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير معروف';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DocumentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String status;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusBadge(status: status),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case 'verified':
        color = AppColors.success;
        text = 'تم التحقق';
        break;
      case 'pending':
        color = AppColors.warning;
        text = 'قيد المراجعة';
        break;
      case 'rejected':
        color = AppColors.error;
        text = 'مرفوض';
        break;
      default:
        color = AppColors.grey500;
        text = 'غير مرفوع';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadOption({
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
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
