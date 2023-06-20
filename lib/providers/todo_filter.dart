import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../models/todo_model.dart';

class TodoFilterState extends Equatable {
  final Filter filter;

  TodoFilterState({required this.filter});

  factory TodoFilterState.initial() {
    return TodoFilterState(filter: Filter.all);
  }

  @override
  List<Object> get props => [filter];

  @override
  bool get stringify => true;

  TodoFilterState copyWith({
    Filter? filter,
  }) {
    return TodoFilterState(
      filter: filter ?? this.filter,
    );
  }
}

//changeNotifier is used to notify the listeners when the state changes
class TodoFilter with ChangeNotifier {
  TodoFilterState _state = TodoFilterState.initial();
  TodoFilterState get state => _state;

//changes/updates the state and notifies the listeners
  void changeFilter(Filter newfilter) {
    _state = _state.copyWith(filter: newfilter);
    notifyListeners();
  }
}
