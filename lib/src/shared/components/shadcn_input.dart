/// Legacy shadcn-style input wrapper. Deprecated in favour of [CkInput]
/// from `package:cookest_ui`.
import 'package:flutter/material.dart';

import '../theme/shadcn_theme.dart';

@Deprecated(
  'Use CkInput from package:cookest_ui/cookest_ui.dart instead.',
)
class ShadcnInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefix;
  final int? maxLines;

  const ShadcnInput({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefix,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkGreen(context),
                ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: obscureText ? 1 : maxLines,
          style: const TextStyle(fontSize: 14),
          cursorColor: AppTheme.sage,
          decoration: InputDecoration(
            hintText: placeholder,
            isDense: true,
            prefixIcon: prefix,
            prefixIconConstraints: prefix != null
                ? const BoxConstraints(minWidth: 40, minHeight: 40)
                : null,
          ),
        ),
      ],
    );
  }
}
