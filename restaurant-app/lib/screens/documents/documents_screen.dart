import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/loading_widget.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  bool _isLoading = false;

  Future<void> _uploadDocument(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    
    if (pickedFile == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(restaurantProvider.notifier).uploadDocument(
        type: type,
        file: File(pickedFile.path),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفع المستند بنجاح'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل رفع المستند: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = ref.watch(restaurantProvider).restaurant;

    return Scaffold(
      appBar: AppBar(title: const Text('المستندات'), centerTitle: true),
      body: _isLoading
          ? const LoadingWidget()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDocumentCard(
                  title: 'السجل التجاري',
                  type: 'commercial_register',
                  status: restaurant?.documents?.commercialRegister != null ? 'uploaded' : 'pending',
                  url: restaurant?.documents?.commercialRegister,
                ),
                _buildDocumentCard(
                  title: 'البطاقة الضريبية',
                  type: 'tax_card',
                  status: restaurant?.documents?.taxCard != null ? 'uploaded' : 'pending',
                  url: restaurant?.documents?.taxCard,
                ),
                _buildDocumentCard(
                  title: 'شهادة صحية',
                  type: 'health_certificate',
                  status: restaurant?.documents?.healthCertificate != null ? 'uploaded' : 'pending',
                  url: restaurant?.documents?.healthCertificate,
                ),
                _buildDocumentCard(
                  title: 'صورة الهوية',
                  type: 'id_card',
                  status: restaurant?.documents?.idCard != null ? 'uploaded' : 'pending',
                  url: restaurant?.documents?.idCard,
                ),
              ],
            ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String type,
    required String status,
    String? url,
  }) {
    final isUploaded = status == 'uploaded';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUploaded ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle : Icons.upload_file,
                color: isUploaded ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    isUploaded ? 'تم الرفع' : 'مطلوب',
                    style: TextStyle(
                      color: isUploaded ? Colors.green : Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isUploaded && url != null)
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  // View document
                },
              ),
            ElevatedButton(
              onPressed: () => _uploadDocument(type),
              style: ElevatedButton.styleFrom(
                backgroundColor: isUploaded ? Colors.grey[200] : AppTheme.primaryColor,
                foregroundColor: isUploaded ? Colors.black : Colors.white,
              ),
              child: Text(isUploaded ? 'تحديث' : 'رفع'),
            ),
          ],
        ),
      ),
    );
  }
}
