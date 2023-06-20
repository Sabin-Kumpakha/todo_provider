import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

Uuid uuid = Uuid();

class Todo extends Equatable {
  final String id;
  final String desc;
  final bool isCompleted;

  Todo({
    String? id,
    required this.desc,
    this.isCompleted = false,
  }) : id = id ?? uuid.v4();

  @override
  List<Object> get props => [id, desc, isCompleted];

  @override
  bool get stringify => true;
}

enum Filter {
  all,
  active,
  completed,
}



//Notes

//uuid package is used to generate unique id for each todo

//: id = id ?? uuid.v4() means if id is null then generate a new id else use the existing id

//get props => [id, desc, isCompleted]; 
//means that these are the properties that will be used to compare two todos

//stringify means convert to string
