import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/domain/flags/flag_reading.dart';
import 'package:flagkit_sample/features/common/flag_words.dart';
import 'package:material_ui/material_ui.dart';

/// One thing a screen shows because of a flag: what it is, in words
/// ("the one-page checkout"), and FlagKit's reading of the flag.
typedef Why = ({String subject, FlagReading reading});

/// "Why am I seeing this?": a button that opens a sentence per [whys],
/// each from `FlagKit.detail`. Explainability is a feature of the SDK, so
/// the sample shows it where the user is, not only on the Dashboard.
class WhyLine extends StatefulWidget {
  const WhyLine(this.whys, {super.key});

  final List<Why> whys;

  @override
  State<WhyLine> createState() => _WhyLineState();
}

class _WhyLineState extends State<WhyLine> {
  var _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // One node: a button that says whether it's open.
          MergeSemantics(
            child: Semantics(
              expanded: _open,
              child: TextButton.icon(
                onPressed: () => setState(() => _open = !_open),
                icon: Icon(_open ? Icons.expand_less : Icons.help_outline),
                label: const Text('Why am I seeing this?'),
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.small,
                0,
                AppSpacing.small,
                AppSpacing.small,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xSmall,
                children: [
                  for (final why in widget.whys)
                    Text(
                      whyWords(why.subject, why.reading),
                      style: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
