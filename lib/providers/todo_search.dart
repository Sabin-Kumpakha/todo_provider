import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class TodoSearchState extends Equatable {
  final String searchText;
  TodoSearchState({
    required this.searchText,
  });

  factory TodoSearchState.initial() {
    return TodoSearchState(searchText: "");
  }

  @override
  List<Object> get props => [searchText];

  @override
  bool get stringify => true;

  TodoSearchState copyWith({
    String? searchText,
  }) {
    return TodoSearchState(
      searchText: searchText ?? this.searchText,
    );
  }
}

class TodoSearch with ChangeNotifier {
  TodoSearchState _state = TodoSearchState.initial();
  TodoSearchState get state => _state;

  void setSearchText(String newsearchText) {
    _state = _state.copyWith(searchText: newsearchText);
    notifyListeners();
  }
}
