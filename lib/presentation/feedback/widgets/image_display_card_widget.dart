import 'package:flutter/material.dart';
import 'package:scrm/common/widgets/card_container_widget.dart';

class ImageDisplayCard extends StatelessWidget {
  const ImageDisplayCard({
    super.key,
    required this.imagePath,
    required this.isNetworkImage,
    this.height = 250,
  });

  final String imagePath;
  final bool isNetworkImage;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      height: height,
      margin: const EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isNetworkImage
            ? Image.network(
                imagePath,
                width: double.infinity,
                height: height,
                fit: BoxFit.fill,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, size: 50, color: Colors.grey),
                  );
                },
              )
            : Image.asset(
                imagePath,
                width: double.infinity,
                height: height,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, size: 50, color: Colors.grey),
                  );
                },
              ),
      ),
    );
  }
}

