import 'package:flutter/material.dart';

class AuthContainer extends StatefulWidget {
  final List<Widget> children;
  final GlobalKey formKey;
  const AuthContainer({
    super.key,
    required this.children,
    required this.formKey,
  });

  @override
  State<AuthContainer> createState() => _AuthContainerState();
}

class _AuthContainerState extends State<AuthContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
      ),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
      child: Card(
        child: Stack(
          fit: StackFit.loose,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                top: 20.0,
              ),
              child: SizedBox(
                child: Form(
                  key: widget.formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: widget.children,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
