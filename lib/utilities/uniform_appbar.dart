import 'package:aletheia/utilities/dark_mode_switcher.dart';
import 'package:flutter/material.dart';

class UniformAppbar extends StatelessWidget implements PreferredSizeWidget {
  const UniformAppbar({
    super.key,
    required this.leadIcon,
    required this.titleText,
    required this.onPress,
  });

  final Icon leadIcon;
  final String titleText;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: onPress,
        icon: leadIcon,
        tooltip: 'Return',
      ),
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          titleText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 8,
          ),
        ),
      ),
      centerTitle: true,
      actions: const [DarkModeSwitcher(), SizedBox(width: 8)],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
