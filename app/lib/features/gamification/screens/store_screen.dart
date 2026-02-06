import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/gamification_provider.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _categories = [
    ('all', 'Todos', Icons.apps),
    ('avatar', 'Avatares', Icons.face),
    ('frame', 'Marcos', Icons.crop_square),
    ('badge', 'Badges', Icons.military_tech),
    ('title', 'Titulos', Icons.title),
    ('theme', 'Temas', Icons.palette),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);

    // Load gamification data if not loaded
    Future.microtask(() {
      ref.read(gamificationProvider.notifier).loadGamificationData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _purchaseItem(CosmeticItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Comprar ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForType(item.type),
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(item.description),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Colors.orange, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${item.priceCoins} Coins',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(gamificationProvider.notifier).purchaseCosmetic(item.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                ? 'Has comprado ${item.name}!'
                : ref.read(gamificationProvider).error ?? 'Error al comprar',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  IconData _getIconForType(CosmeticType type) {
    switch (type) {
      case CosmeticType.avatar:
        return Icons.face;
      case CosmeticType.frame:
        return Icons.crop_square;
      case CosmeticType.badge:
        return Icons.military_tech;
      case CosmeticType.title:
        return Icons.title;
      case CosmeticType.theme:
        return Icons.palette;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gamificationState = ref.watch(gamificationProvider);
    final currency = gamificationState.currency;
    final storeItems = gamificationState.storeItems;
    final ownedCosmetics = gamificationState.ownedCosmetics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        actions: [
          // Coins balance
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.orange, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${currency?.coinsBalance ?? 0}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((c) => Tab(
            icon: Icon(c.$3, size: 20),
            text: c.$2,
          )).toList(),
        ),
      ),
      body: gamificationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                List<CosmeticItem> items;
                if (category.$1 == 'all') {
                  items = storeItems;
                } else {
                  final type = CosmeticType.values.firstWhere(
                    (t) => t.name == category.$1,
                    orElse: () => CosmeticType.avatar,
                  );
                  items = storeItems.where((i) => i.type == type).toList();
                }

                return _buildItemGrid(theme, items, ownedCosmetics, currency?.coinsBalance ?? 0);
              }).toList(),
            ),
    );
  }

  Widget _buildItemGrid(
    ThemeData theme,
    List<CosmeticItem> items,
    List<OwnedCosmetic> owned,
    int balance,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay items en esta categoria',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = owned.any((o) => o.cosmeticId == item.id);
        final canAfford = balance >= item.priceCoins;

        return _StoreItemCard(
          item: item,
          isOwned: isOwned,
          canAfford: canAfford,
          onTap: isOwned ? null : () => _purchaseItem(item),
          getIcon: _getIconForType,
        );
      },
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  final CosmeticItem item;
  final bool isOwned;
  final bool canAfford;
  final VoidCallback? onTap;
  final IconData Function(CosmeticType) getIcon;

  const _StoreItemCard({
    required this.item,
    required this.isOwned,
    required this.canAfford,
    required this.onTap,
    required this.getIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon area
                Expanded(
                  flex: 3,
                  child: Container(
                    color: isOwned
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    child: Center(
                      child: Icon(
                        getIcon(item.type),
                        size: 48,
                        color: isOwned
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),

                // Info area
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (isOwned)
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Adquirido',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on,
                                size: 16,
                                color: canAfford ? Colors.orange : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.priceCoins}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: canAfford ? Colors.orange : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Limited badge
            if (item.isLimited)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIMITADO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Owned overlay
            if (isOwned)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
