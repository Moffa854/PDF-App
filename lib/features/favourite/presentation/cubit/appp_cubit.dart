import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'appp_state.dart';

class ApppCubit extends Cubit<ApppState> {
  ApppCubit() : super(ApppInitial());
}
