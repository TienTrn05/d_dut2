import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'loading_bloc.dart';

import '../../common/widgets/loading/custom_loading.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  const LoadingOverlay({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        BlocBuilder<LoadingBloc, LoadingState>(
          builder: (context, state) {
            if (!state.isLoading) return SizedBox.shrink();
            return CustomLoading();
          },
        ),
      ],
    );
  }
}
