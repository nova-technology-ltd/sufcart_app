import 'package:flutter/material.dart';

class Quantity extends StatefulWidget {
  final double totalPrice;
  final Function(double) onQuantityChanged;
  const Quantity({super.key, required this.totalPrice, required this.onQuantityChanged});

  @override
  State<Quantity> createState() => _QuantityState();
}

class _QuantityState extends State<Quantity> {
  int productQuantity = 0;
  @override
  Widget build(BuildContext context) {
    double productPrice = widget.totalPrice; // Convert to double
    double totalPrice = productPrice * productQuantity;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Quantity",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: (){
                if (productQuantity == 0) {
                  return;
                } else {
                  setState(() {
                    productQuantity -=1;
                    widget.onQuantityChanged(-productPrice.toDouble());
                  });
                }
              },
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  shape: BoxShape.circle
                ),
                child: const Center(
                  child: Icon(Icons.remove, color: Colors.grey, size: 17,),
                ),
              ),
            ),
            Text(
              "  $productQuantity  ",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500
              ),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  productQuantity += 1;
                  widget.onQuantityChanged(productPrice.toDouble());
                });
              },
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  shape: BoxShape.circle,
                  color: Colors.black
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Colors.white, size: 17,),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
