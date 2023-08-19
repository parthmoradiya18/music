import 'package:flutter/material.dart';

class MyBox extends StatelessWidget {
  final child;
  Function()? onTap;
  double? margin;
  MyBox({super.key,required this.child,this.margin,this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        margin: EdgeInsets.all(margin ?? 0),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade500,blurRadius: 15,offset: const Offset(5, 5)),
              const BoxShadow( color: Colors.white,blurRadius: 15,offset: Offset(-5, -5) )]
        ),
        child: Center(child: child,),
      ),
    );
  }
}
