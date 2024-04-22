import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/auth.dart';
import 'package:frontend/providers/todo_list_provider.dart';
import 'package:frontend/widgets/add_todo_task.dart';
import 'package:frontend/widgets/todo_task_list.dart';

import 'package:frontend/data/todo_task.dart';

class TodoTaskScreen extends ConsumerStatefulWidget{
  const TodoTaskScreen({super.key});

  @override
ConsumerState<TodoTaskScreen> createState() {
   return _TodoTaskScreenState();
  }
}

class _TodoTaskScreenState extends ConsumerState<TodoTaskScreen>{
  
  TodoTask? fetchedTodoTask;
  var _isAddTodo=true;
  final _auth = AppPortalAuth();

  void _fetchSingleTodoTask(String id) async{
     fetchedTodoTask = //await fetchTodoTask(id); 
     ref
      .read(todoListProvider.notifier)
      .getTodoTaskById(id.toString());
     //print('is add todo value:${_isAddTodo}');
     setState(() {
      _isAddTodo = false;
     });
  }


  void _refreshDataTable(){
    
    setState(() {
      _isAddTodo = true;
    });
  }


   @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text(
          'TODO LIST APP'
        ),
        actions: [
          IconButton(
            onPressed:() async{
              await _auth.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User Signed Out')));
            },
            icon: const Icon(Icons.logout,color: Colors.white,),
            tooltip: 'Logout',
        ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AddTodoTask(
              isAddTodo: _isAddTodo,
              fetchedTodoTask: fetchedTodoTask,
              refreshDataTable: _refreshDataTable,
            ),
            const SizedBox(
              height: 40,
            ),
            TodoTaskList(onSelectedTodo:(id){
                _fetchSingleTodoTask(id);
            })
          ],
        ),
      ),
    );
  }
}