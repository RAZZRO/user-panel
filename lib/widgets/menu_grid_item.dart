import 'package:flutter/material.dart';
import 'package:user_panel/models/menu.dart';

class MenuGridItem extends StatelessWidget {
  const MenuGridItem({
    super.key,
    required this.item,
    required this.onSelectedItem,
  });

  final MenuItem item;
  final void Function() onSelectedItem;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelectedItem,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  menuItemIcon[item],
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              flex: 1,
              child: Text(
                menuItemName[item].toString(),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
