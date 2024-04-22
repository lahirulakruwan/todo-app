import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/todo_task.dart';
import 'package:frontend/providers/todo_list_provider.dart';

class TodoTaskList extends ConsumerStatefulWidget {
  const TodoTaskList({super.key,required this.onSelectedTodo});

  final void Function(String id) onSelectedTodo;

  @override
   ConsumerState<ConsumerStatefulWidget> createState() => _TodoTaskListState();
}

class _TodoTaskListState extends ConsumerState<TodoTaskList> {
  
  late Future<List<TodoTask>> _fetchTodos;
  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchTodos =  ref.read(todoListProvider.notifier).loadTodosFromDB();
    
  }

  void _selectedTodo(String id){
   widget.onSelectedTodo(id);
  }



  @override
  Widget build(BuildContext context) {
    final updatedTodos =ref.watch(todoListProvider);

    return FutureBuilder(
      future: _fetchTodos,
      builder: (ctx,todoSnapshots){
        if(todoSnapshots.connectionState == ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if(!todoSnapshots.hasData){
          return const Center(
            child: Text('No todo tasks found'),
          );
        }
        if(todoSnapshots.hasError){
          return const Center(
            child: Text('Something went wrong...'),
          );
        }
        final loadedTodos = ref.watch(todoListProvider);

        return buildTable(loadedTodos,_selectedTodo,ref);

       }
    );
  }
}

Widget buildTable(List<TodoTask> todos,Function _selectedTodo,WidgetRef ref){

    return Card(
         child: Padding(
          padding:const EdgeInsets.all(17.0),
          child: Column(
          children: [
  
          SingleChildScrollView(
            child: Container(
              width:  450,
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text(
                          "Id",
                          style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                          ),
                  ),
                  DataColumn(
                    label: Text(
                          "Todo Task",
                          style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                          ),
                  ),
                   DataColumn(
                    label: Text(
                          "Update",
                          style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                          ),
                  ),
                  DataColumn(
                    label: Text(
                           "Remove",
                           style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                           ),
                  ),
                ], 
                rows: todos.map((todo){

                      return DataRow(
                        cells:[
                          DataCell(Text(
                                  todo.id.toString() ?? 'N/A',
                                  )
                                ),
                          DataCell(Text(
                                  todo.task ?? 'N/A',
                                  )
                                ),
                          DataCell(IconButton(
                              icon: const Icon(Icons.update),
                              onPressed: () async{
                               _selectedTodo(todo.id.toString());
                              },
                              )
                            ),
                          DataCell(IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async{
                              // var result = await deleteTodoTask(todo.id.toString());
                               
                               ref
                               .read(todoListProvider.notifier)
                               .removeTodoTask(todo.id.toString());
                               
                              },
                              )
                            )
                        ], 
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
     ),
    );
  }