import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../models/todo_model.dart';
import 'providers.dart';

class FilteredTodosState extends Equatable {
  final List<Todo> filteredTodos;

  FilteredTodosState({required this.filteredTodos});

  factory FilteredTodosState.initial() {
    return FilteredTodosState(filteredTodos: []);
  }

  @override
  List<Object> get props => [filteredTodos];

  @override
  bool get stringify => true;

  FilteredTodosState copyWith({
    List<Todo>? filteredTodos,
  }) {
    return FilteredTodosState(
      filteredTodos: filteredTodos ?? this.filteredTodos,
    );
  }
}

class FilteredTodos with ChangeNotifier {
  late FilteredTodosState _state;
  final List<Todo> initialFilteredTodos;
  FilteredTodos({
    required this.initialFilteredTodos,
  }) {
    print('initialFilteredTodos: $initialFilteredTodos');
    _state = FilteredTodosState(filteredTodos: initialFilteredTodos);
  }
  FilteredTodosState get state => _state;

  void update(
    TodoFilter todoFilter,
    TodoSearch todoSearch,
    TodoList todoList,
  ) {
    List<Todo> _filteredTodos;

    switch (todoFilter.state.filter) {
      case Filter.active:
        _filteredTodos = todoList.state.todos
            .where((Todo todo) => !todo.isCompleted)
            .toList();
        break;
      case Filter.completed:
        _filteredTodos = todoList.state.todos
            .where((Todo todo) => todo.isCompleted)
            .toList();
        break;
      case Filter.all:
      default:
        _filteredTodos = todoList.state.todos;
        break;
    }

    if (todoSearch.state.searchText.isNotEmpty) {
      _filteredTodos = _filteredTodos
          .where((Todo todo) => todo.desc
              .toLowerCase()
              .contains(todoSearch.state.searchText.toLowerCase()))
          .toList();
    }
    //state = ***
    _state = _state.copyWith(filteredTodos: _filteredTodos);
    notifyListeners();
  }
}
