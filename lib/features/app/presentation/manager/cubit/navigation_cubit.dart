import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf_app/features/app/presentation/manager/cubit/navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationInitial());

  void setIndex(int index) {
    emit(NavigationUpdated(index));
  }
}
