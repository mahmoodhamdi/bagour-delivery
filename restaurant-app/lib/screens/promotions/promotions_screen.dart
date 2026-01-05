import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/promotions_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class PromotionsScreen extends ConsumerStatefulWidget {
  const PromotionsScreen({super.key});

  @override
  ConsumerState<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends ConsumerState<PromotionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(promotionsProvider.notifier).fetchPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final promotionsState = ref.watch(promotionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('العروض والتخفيضات'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPromotionDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('إضافة عرض'),
      ),
      body: promotionsState.isLoading
          ? const LoadingWidget()
          : promotionsState.error != null
              ? CustomErrorWidget(
                  message: promotionsState.error!,
                  onRetry: () => ref.read(promotionsProvider.notifier).fetchPromotions(),
                )
              : promotionsState.promotions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: promotionsState.promotions.length,
                      itemBuilder: (context, index) {
                        final promotion = promotionsState.promotions[index];
                        return _buildPromotionCard(promotion);
                      },
                    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد عروض حالياً',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف عروض لجذب المزيد من العملاء',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(dynamic promotion) {
    final isActive = promotion.isActive ?? false;
    final discountType = promotion.discountType ?? 'percentage';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promotion.title ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        discountType == 'percentage'
                            ? 'خصم ${promotion.discountValue}%'
                            : 'خصم ${promotion.discountValue} ج.م',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    ref.read(promotionsProvider.notifier).togglePromotion(
                      promotion.id,
                      value,
                    );
                  },
                ),
              ],
            ),
            if (promotion.description != null) ...[
              const SizedBox(height: 12),
              Text(
                promotion.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  'حتى ${promotion.endDate != null ? "${promotion.endDate!.day}/${promotion.endDate!.month}/${promotion.endDate!.year}" : "غير محدد"}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showEditPromotionDialog(promotion),
                  child: const Text('تعديل'),
                ),
                TextButton(
                  onPressed: () => _confirmDelete(promotion),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('حذف'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPromotionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _PromotionForm(),
    );
  }

  void _showEditPromotionDialog(dynamic promotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PromotionForm(promotion: promotion),
    );
  }

  void _confirmDelete(dynamic promotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العرض'),
        content: const Text('هل أنت متأكد من حذف هذا العرض؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(promotionsProvider.notifier).deletePromotion(promotion.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _PromotionForm extends ConsumerStatefulWidget {
  final dynamic promotion;

  const _PromotionForm({this.promotion});

  @override
  ConsumerState<_PromotionForm> createState() => _PromotionFormState();
}

class _PromotionFormState extends ConsumerState<_PromotionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();
  String _discountType = 'percentage';
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.promotion != null) {
      _titleController.text = widget.promotion.title ?? '';
      _descriptionController.text = widget.promotion.description ?? '';
      _discountController.text = widget.promotion.discountValue?.toString() ?? '';
      _discountType = widget.promotion.discountType ?? 'percentage';
      _endDate = widget.promotion.endDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.promotion == null ? 'إضافة عرض جديد' : 'تعديل العرض',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان العرض',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'قيمة الخصم',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _discountType,
                    items: const [
                      DropdownMenuItem(value: 'percentage', child: Text('%')),
                      DropdownMenuItem(value: 'fixed', child: Text('ج.م')),
                    ],
                    onChanged: (v) => setState(() => _discountType = v!),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.promotion == null ? 'إضافة' : 'حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      // Save promotion
    }
  }
}
