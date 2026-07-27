import 'package:flutter/material.dart';
import '../utilities/dark_mode_switcher.dart';

class ModuleSelector extends StatefulWidget {
  const ModuleSelector({super.key});

  @override
  State<ModuleSelector> createState() => _ModuleSelectorState();
}

class _ModuleSelectorState extends State<ModuleSelector> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: AnimatedOpacity(
          opacity: _isVisible ? 1 : 0,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: _isVisible ? Offset.zero : const Offset(0, 0.04),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            child: CustomScrollView(
              slivers: [
                // ─────────────────────────────────────────────
                // TOP BAR
                // ─────────────────────────────────────────────
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  pinned: false,

                  leading: IconButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: 'Logout',
                  ),

                  title: Text(
                    'Aletheia',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),

                  centerTitle: true,

                  actions: const [DarkModeSwitcher(), SizedBox(width: 8)],
                ),

                // ─────────────────────────────────────────────
                // CONTENT
                // ─────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Welcome back.',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Choose a space to continue your journey.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ─────────────────────────────────────
                        // CHECKPOINTS
                        // ─────────────────────────────────────
                        _ModuleCard(
                          title: 'Checkpoints',
                          subtitle: 'Reflect on the moments that shape you.',
                          icon: Icons.auto_awesome_rounded,
                          height: 210,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primaryContainer,
                              colorScheme.secondaryContainer,
                            ],
                          ),
                          foregroundColor: colorScheme.onPrimaryContainer,
                          onTap: () {
                            Navigator.pushNamed(context, '/checkpoints');
                          },
                        ),

                        const SizedBox(height: 16),

                        // ─────────────────────────────────────
                        // BELLYLOG
                        // ─────────────────────────────────────
                        _ModuleCard(
                          title: 'Bellylog',
                          subtitle:
                              'Understand the patterns behind your wellbeing.',
                          icon: Icons.favorite_rounded,
                          height: 190,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.tertiaryContainer,
                              colorScheme.secondaryContainer,
                            ],
                          ),
                          foregroundColor: colorScheme.onTertiaryContainer,
                          onTap: () {
                            Navigator.pushNamed(context, '/bellylog');
                          },
                        ),

                        const SizedBox(height: 16),

                        // ─────────────────────────────────────
                        // PALIMORA
                        // ─────────────────────────────────────
                        _ModuleCard(
                          title: 'Palimora',
                          subtitle: 'A deeper look at who you are becoming.',
                          icon: Icons.layers_rounded,
                          height: 190,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.surfaceContainerHighest,
                              colorScheme.primaryContainer,
                            ],
                          ),
                          foregroundColor: colorScheme.onSurface,
                          onTap: () {
                            // Palimora Action
                          },
                        ),

                        const SizedBox(height: 30),

                        Center(
                          child: Text(
                            'Your life, in different layers.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.65,
                              ),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MODULE CARD
// ─────────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double height;
  final Gradient gradient;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.height,
    required this.gradient,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: foregroundColor.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Stack(
              children: [
                // Decorative background circle
                Positioned(
                  right: -35,
                  bottom: -50,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: foregroundColor.withValues(alpha: 0.07),
                    ),
                  ),
                ),

                // Decorative smaller circle
                Positioned(
                  right: 32,
                  top: -35,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: foregroundColor.withValues(alpha: 0.06),
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: foregroundColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Icon(icon, color: foregroundColor, size: 29),
                    ),

                    const Spacer(),

                    // Title
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: foregroundColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),

                    const SizedBox(height: 6),

                    // Subtitle
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: foregroundColor.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),

                // Arrow
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: foregroundColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: foregroundColor,
                      size: 21,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
