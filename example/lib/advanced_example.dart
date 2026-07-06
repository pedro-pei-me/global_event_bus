import 'dart:async';
import 'package:flutter/material.dart';
import 'package:global_event_bus/global_event_bus.dart';

// 用户数据模型
class UserData {
  final String id;
  final String name;
  final String email;
  final DateTime loginTime;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.loginTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'loginTime': loginTime.toIso8601String(),
      };
}

// 购物车项目模型
class CartItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
      };
}

// 主页面
class AdvancedExamplePage extends StatefulWidget {
  const AdvancedExamplePage({super.key});

  @override
  State<AdvancedExamplePage> createState() => _AdvancedExamplePageState();
}

class _AdvancedExamplePageState extends State<AdvancedExamplePage> {
  UserData? _currentUser;
  List<CartItem> _cartItems = [];
  late StreamSubscription _userSubscription;
  late StreamSubscription _cartSubscription;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    // 监听用户登录事件
    _userSubscription = globalEventBus.listen<UserData>(
      listenerId: 'advanced_user_listener',
      onEvent: (event) {
        setState(() {
          _currentUser = event.data;
        });

        // 用户登录后发送欢迎事件
        globalEventBus.sendEvent<String>(
          type: 'user_welcome',
          data: '欢迎回来，${event.data.name}！',
          priority: GebPriority.high,
        );
      },
    );

    // 监听购物车更新事件
    _cartSubscription = globalEventBus.listen<List<CartItem>>(
      listenerId: 'advanced_cart_listener',
      onEvent: (event) {
        setState(() {
          _cartItems = event.data;
        });
      },
    );
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    _cartSubscription.cancel();
    super.dispose();
  }

  double get _totalPrice {
    return _cartItems.fold(
        0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('高级示例 - 多页面通信'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '用户信息',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (_currentUser == null)
                      const Text('未登录')
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('姓名: ${_currentUser!.name}'),
                          Text('邮箱: ${_currentUser!.email}'),
                          Text('登录时间: ${_currentUser!.loginTime}'),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 购物车信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '购物车 (${_cartItems.length} 件商品)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (_cartItems.isEmpty)
                      const Text('购物车为空')
                    else
                      Column(
                        children: [
                          ..._cartItems.map(
                            (item) => ListTile(
                              title: Text(item.productName),
                              subtitle: Text('数量: ${item.quantity}'),
                              trailing: Text(
                                  '¥${(item.price * item.quantity).toStringAsFixed(2)}'),
                            ),
                          ),
                          const Divider(),
                          Text(
                            '总计: ¥${_totalPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 操作按钮
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserLoginPage(),
                      ),
                    );
                  },
                  child: const Text('用户登录'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShoppingPage(),
                      ),
                    );
                  },
                  child: const Text('购物页面'),
                ),
                if (_currentUser != null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentUser = null;
                        _cartItems.clear();
                      });

                      globalEventBus.sendEvent<String>(
                        type: 'user_logout',
                        data: '用户已登出',
                        priority: GebPriority.normal,
                      );
                    },
                    child: const Text('登出'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 用户登录页面
class UserLoginPage extends StatelessWidget {
  const UserLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户登录'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('选择一个用户登录：'),
            const SizedBox(height: 16),
            // 修改用户列表为 Map 格式
            ...[
              {'name': '张三', 'email': 'zhangsan@example.com'},
              {'name': '李四', 'email': 'lisi@example.com'},
              {'name': '王五', 'email': 'wangwu@example.com'},
            ].map(
              (user) => Card(
                child: ListTile(
                  title: Text(user['name']!),
                  subtitle: Text(user['email']!),
                  trailing: const Icon(Icons.login),
                  onTap: () {
                    final userData = UserData(
                      id: user['name']!.hashCode.toString(),
                      name: user['name']!,
                      email: user['email']!,
                      loginTime: DateTime.now(),
                    );

                    // 发送用户登录事件
                    globalEventBus.sendEvent<UserData>(
                      type: 'user_login',
                      data: userData,
                      priority: GebPriority.high,
                      metadata: {
                        'source': 'login_page',
                        'method': 'manual_selection',
                      },
                    );

                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 购物页面
class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final List<CartItem> _localCart = [];

  final List<Map<String, dynamic>> _products = [
    {'id': '1', 'name': 'iPhone 15', 'price': 5999.0},
    {'id': '2', 'name': 'MacBook Pro', 'price': 12999.0},
    {'id': '3', 'name': 'AirPods Pro', 'price': 1999.0},
    {'id': '4', 'name': 'iPad Air', 'price': 4599.0},
    {'id': '5', 'name': 'Apple Watch', 'price': 2999.0},
  ];

  void _addToCart(Map<String, dynamic> product) {
    final existingIndex = _localCart.indexWhere(
      (item) => item.productId == product['id'],
    );

    if (existingIndex >= 0) {
      // 增加数量
      final existingItem = _localCart[existingIndex];
      _localCart[existingIndex] = CartItem(
        productId: existingItem.productId,
        productName: existingItem.productName,
        price: existingItem.price,
        quantity: existingItem.quantity + 1,
      );
    } else {
      // 添加新商品
      _localCart.add(
        CartItem(
          productId: product['id'],
          productName: product['name'],
          price: product['price'],
          quantity: 1,
        ),
      );
    }

    // 发送购物车更新事件
    globalEventBus.sendEvent<List<CartItem>>(
      type: 'cart_updated',
      data: List.from(_localCart),
      priority: GebPriority.normal,
      metadata: {
        'action': 'add_item',
        'productId': product['id'],
        'totalItems': _localCart.length,
      },
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('购物页面'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${_localCart.length}'),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () {
              // 显示购物车详情
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('购物车'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _localCart
                        .map(
                          (item) => ListTile(
                            title: Text(item.productName),
                            subtitle: Text('数量: ${item.quantity}'),
                            trailing: Text(
                                '¥${(item.price * item.quantity).toStringAsFixed(2)}'),
                          ),
                        )
                        .toList(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(product['name']),
              subtitle: Text('¥${product['price'].toStringAsFixed(2)}'),
              trailing: ElevatedButton(
                onPressed: () => _addToCart(product),
                child: const Text('加入购物车'),
              ),
            ),
          );
        },
      ),
    );
  }
}
