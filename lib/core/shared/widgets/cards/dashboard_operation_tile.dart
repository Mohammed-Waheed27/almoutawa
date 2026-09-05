import '../layout/hub_operation_tile.dart';

/// Back-compat alias — prefer [HubOperationTile].
class DashboardOperationTile extends HubOperationTile {
  const DashboardOperationTile({
    super.key,
    required super.title,
    required super.subtitle,
    required super.icon,
    required super.onTap,
    super.accentColor,
    super.badge,
  });
}
