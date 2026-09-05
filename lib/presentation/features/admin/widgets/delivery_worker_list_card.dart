import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/shared/widgets/cards/decorative_card_tone.dart';
import '../../../../core/shared/widgets/cards/decorative_summary_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/staff_profile.dart';

/// Fleet-style summary row for delivery workers — blob shell, status badge, contact strip.
class DeliveryWorkerListCard extends StatelessWidget {
  const DeliveryWorkerListCard({
    super.key,
    required this.worker,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  final StaffProfile worker;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isActive = worker.isActive;
    final phoneLabel = worker.phone?.trim().isNotEmpty == true
        ? worker.phone!.trim()
        : 'لا يوجد رقم هاتف';
    final emailLabel = worker.email?.trim().isNotEmpty == true
        ? worker.email!.trim()
        : '—';
    final joinedLabel = DateFormat('yyyy/MM/dd', 'ar').format(worker.createdAt);

    return DecorativeSummaryCard(
      title: worker.displayName,
      subtitle: phoneLabel,
      icon: Icons.local_shipping_rounded,
      badge: isActive ? 'نشط' : 'موقوف',
      tone: isActive ? DecorativeCardTone.green : DecorativeCardTone.neutral,
      onTap: onEdit,
      trailing: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert_rounded,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.85),
        ),
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onEdit();
            case 'toggle':
              onToggleActive();
            case 'delete':
              onDelete();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('تعديل')),
          PopupMenuItem(
            value: 'toggle',
            child: Text(isActive ? 'إيقاف' : 'تفعيل'),
          ),
          const PopupMenuItem(value: 'delete', child: Text('حذف')),
        ],
      ),
      metrics: [
        DecorativeSummaryMetric(label: 'البريد', value: emailLabel),
        DecorativeSummaryMetric(label: 'تاريخ الإضافة', value: joinedLabel),
        DecorativeSummaryMetric(
          label: 'الحالة',
          value: isActive ? 'يعمل' : 'موقوف',
          valueColor: isActive ? AppColors.success : AppColors.onSurfaceVariant,
        ),
      ],
    );
  }
}
