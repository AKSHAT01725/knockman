import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final int cartCount;
  final String address;
  final VoidCallback? onMenuTap;
  final VoidCallback? onAddressTap;
  final VoidCallback? onCartTap;

  const Header({
    Key? key,
    required this.cartCount,
    required this.address,
    this.onMenuTap,
    this.onAddressTap,
    this.onCartTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[900],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ☰ Menu button
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: onMenuTap,
          ),

          // 📍 Address
          Expanded(
            child: InkWell(
              onTap: onAddressTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Deliver to",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    address,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // 🛒 Cart with badge
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: onCartTap,
              ),
              if (cartCount > 0)
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    cartCount.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
