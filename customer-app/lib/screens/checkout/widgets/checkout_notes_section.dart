import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../checkout_screen.dart';

class CheckoutNotesSection extends ConsumerWidget {
  const CheckoutNotesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(checkoutNotesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.note_alt_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'ملاحظات على الطلب',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '(اختياري)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: notes,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'أضف أي ملاحظات خاصة بالطلب...',
            hintStyle: TextStyle(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),
          onChanged: (value) {
            ref.read(checkoutNotesProvider.notifier).state = value;
          },
        ),
      ],
    );
  }
}
