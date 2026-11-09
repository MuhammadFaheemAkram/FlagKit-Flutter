import 'package:flagkit_sample/core/design_system/design_system.dart';
import 'package:flagkit_sample/di/injection.dart';
import 'package:flagkit_sample/domain/feed/feed.dart';
import 'package:flagkit_sample/features/common/why_line.dart';
import 'package:flagkit_sample/features/home/cubit/home_cubit.dart';
import 'package:flagkit_sample/features/home/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Home: the new home or the classic one, as `new_home_screen` says.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (_) => getIt<HomeCubit>(), child: const HomeView());
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeCubit>().state;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: state.newHome ? _NewHome(state) : _ClassicHome(state),
    );
  }
}

/// Why this home and this look.
WhyLine _whyLine(HomeState state) => WhyLine([
  (
    subject: state.newHome ? 'the new home' : 'the classic home',
    reading: state.homeWhy,
  ),
  (subject: 'the ${state.theme.name} look', reading: state.themeWhy),
]);

/// The classic home: the feed as one plain list.
class _ClassicHome extends StatelessWidget {
  const _ClassicHome(this.state);

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _whyLine(state),
        const SectionHeader('Stories'),
        for (final item in state.items) _FeedTile(item),
      ],
    );
  }
}

/// The new home: a banner, then the feed split into the config's sections.
class _NewHome extends StatelessWidget {
  const _NewHome(this.state);

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final sections = state.config.sections;
    final banner = state.config.banner;
    return ListView(
      children: [
        if (banner != null) _Banner(banner),
        _whyLine(state),
        for (final (index, section) in sections.indexed) ...[
          SectionHeader(section.title),
          for (final item in _share(index, sections.length)) _FeedTile(item),
        ],
      ],
    );
  }

  // Each section gets its slice of the feed, in order.
  List<FeedItem> _share(int index, int count) {
    final items = state.items;
    final size = (items.length / count).ceil();
    final start = (index * size).clamp(0, items.length);
    return items.sublist(start, (start + size).clamp(0, items.length));
  }
}

class _Banner extends StatelessWidget {
  const _Banner(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.medium,
        0,
      ),
      child: Card.filled(
        color: scheme.primaryContainer,
        child: ListTile(
          leading: Icon(
            Icons.campaign_outlined,
            color: scheme.onPrimaryContainer,
          ),
          title: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: scheme.onPrimaryContainer),
          ),
        ),
      ),
    );
  }
}

class _FeedTile extends StatelessWidget {
  const _FeedTile(this.item);

  final FeedItem item;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.article_outlined),
    title: Text(item.title),
    subtitle: Text(item.topic),
  );
}
