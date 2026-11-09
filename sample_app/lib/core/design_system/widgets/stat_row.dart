import 'package:flagkit_sample/core/design_system/large_text.dart';
import 'package:material_ui/material_ui.dart';

/// One labelled number: an icon, a word and a count, read as one phrase by
/// screen readers ("Pending: 12"). The color is never the only signal: the
/// icon and the word say the same. Past 130 % text, the value goes under
/// the label.
class StatRow extends StatelessWidget {
  const StatRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;

  /// The icon's color (a status color); the theme's muted one by default.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stacked = context.prefersStackedLayout;
    final valueText = Text(value, style: theme.textTheme.titleMedium);
    return MergeSemantics(
      child: Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: ListTile(
          leading: Icon(
            icon,
            color: color ?? theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(label),
          // Beside the label it can squeeze the label into a narrow column
          // at large text ("Fetche" / "d" beside a time); there, it goes
          // under it.
          subtitle: stacked ? valueText : null,
          trailing: stacked ? null : valueText,
        ),
      ),
    );
  }
}
