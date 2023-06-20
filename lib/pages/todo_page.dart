import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_model.dart';
import '../providers/providers.dart';
import '../utils/debounce.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 40.0,
              ),
              child: Column(
                children: [
                  TodoHeader(),
                  CreateTodo(),
                  SizedBox(height: 20.0),
                  SearchAndFilterTodo(),
                  ShowTodos(),
                ],
              )),
        ),
      ),
    );
  }
}

class TodoHeader extends StatelessWidget {
  const TodoHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "TODO",
          style: TextStyle(fontSize: 40.0),
        ),
        Text(
          "${context.watch<ActiveTodoCount>().state.activeTodoCount} items left",
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.redAccent.shade200,
          ),
        ),
      ],
    );
  }
}

class CreateTodo extends StatefulWidget {
  const CreateTodo({Key? key}) : super(key: key);

  @override
  _CreateTodoState createState() => _CreateTodoState();
}

class _CreateTodoState extends State<CreateTodo> {
  final newTodoController = TextEditingController();

//The dispose method is called when the widget is removed from the tree permanently.
//newTodoController.dispose() is called in the dispose method of the CreateTodoState class.
//because the newTodoController is no longer needed when the CreateTodo widget is removed from the tree permanently.
  @override
  void dispose() {
    newTodoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: newTodoController,
      decoration: InputDecoration(
        hintText: "What needs to be done?",
      ),
      onSubmitted: (String? todoDesc) {
        if (todoDesc != null && todoDesc.trim().isNotEmpty) {
          context.read<TodoList>().addTodo(todoDesc);
          newTodoController.clear();
        }
      },
    );
  }
}

class SearchAndFilterTodo extends StatelessWidget {
  SearchAndFilterTodo({Key? key}) : super(key: key);
  final debounce = Debounce(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Search todos",
            border: InputBorder.none,
            filled: true,
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
          ),
          onChanged: (String? newsearchText) {
            if (newsearchText != null) {
              debounce.run(() {
                context.read<TodoSearch>().setSearchText(newsearchText);
              });
            }
          },
        ),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FilterButton(context, Filter.all),
            FilterButton(context, Filter.active),
            FilterButton(context, Filter.completed),
          ],
        ),
      ],
    );
  }

  Widget FilterButton(BuildContext context, Filter filter) {
    return TextButton(
      onPressed: () {
        context.read<TodoFilter>().changeFilter(filter);
      },
      child: Text(
        filter == Filter.all
            ? "All"
            : filter == Filter.active
                ? "Active"
                : "Completed",
        style: TextStyle(
          fontSize: 16.0,
          color: textColor(context, filter),
        ),
      ),
    );
  }

  Color textColor(BuildContext context, Filter filter) {
    final currentFilter = context.watch<TodoFilter>().state.filter;
    return currentFilter == filter ? Colors.black87 : Colors.grey.shade500;
  }
}

class ShowTodos extends StatelessWidget {
  const ShowTodos({Key? key}) : super(key: key);

  Widget showBackground(int direction) {
    return Container(
      alignment: direction == 0 ? Alignment.centerLeft : Alignment.centerRight,
      margin: EdgeInsets.all(4.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      color: Colors.redAccent.shade200,
      child: Icon(
        Icons.delete,
        size: 30.0,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<FilteredTodos>().state.filteredTodos;

    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      itemCount: todos.length,
      separatorBuilder: (context, int index) {
        return Divider(
          color: Colors.grey,
        );
      },
      itemBuilder: (context, int index) {
        return Dismissible(
          key: ValueKey(todos[index].id),
          background: showBackground(0),
          secondaryBackground: showBackground(1),
          onDismissed: (_) {
            context.read<TodoList>().removeTodoById(todos[index]);
          },
          confirmDismiss: (_) => showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text("Delete Todo"),
                content: Text("Are you sure you want to delete this todo?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("No"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("Yes"),
                  ),
                ],
              );
            },
          ),
          child: TodoItem(todo: todos[index]),
        );
      },
    );
  }
}

class TodoItem extends StatefulWidget {
  final Todo todo;
  TodoItem({Key? key, required this.todo}) : super(key: key);

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            bool isError = false;
            textController.text = widget.todo.desc;

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  title: Text("Edit Todo"),
                  content: TextField(
                    controller: textController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Edit todo",
                      errorText: isError ? "Value cannot be empty" : null,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child:
                          Text("Cancel", style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isError = textController.text.isEmpty ? true : false;

                          if (!isError) {
                            context.read<TodoList>().editTodo(
                                  widget.todo.id,
                                  textController.text,
                                );
                            Navigator.of(context).pop();
                          }
                        });
                      },
                      child:
                          Text("Save", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      leading: Checkbox(
        activeColor: Colors.black54,
        value: widget.todo.isCompleted,
        onChanged: (bool? checked) {
          context.read<TodoList>().toggleTodo(widget.todo.id);
        },
      ),
      title: Text(widget.todo.desc),
    );
  }
}
