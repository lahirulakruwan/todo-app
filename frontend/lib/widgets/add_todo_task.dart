import 'package:flutter/material.dart';
import 'package:frontend/data/todo_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/todo_list_provider.dart';

class AddTodoTask extends ConsumerStatefulWidget {
  AddTodoTask(
    {super.key,
    required this.isAddTodo,
    required this.fetchedTodoTask,
    required this.refreshDataTable
    }
  );

  var   isAddTodo;
  final TodoTask? fetchedTodoTask;
  final VoidCallback refreshDataTable;

  @override
  ConsumerState<AddTodoTask> createState(){
    return _AddTodoTaskState();
  }
}

class _AddTodoTaskState extends ConsumerState<AddTodoTask> {

  final _taskController = TextEditingController();


  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _submitTodoTask(){

    final enteredTask = _taskController.text;

    if(enteredTask.trim().isEmpty){
      return;
    }
    
    _taskController.clear();
    
    if(widget.isAddTodo){

       ref
       .read(todoListProvider.notifier)
       .addTodoTask(enteredTask);
       

    }else{
      widget.isAddTodo = true;

      ref
       .read(todoListProvider.notifier)
       .updateTodoTask(widget.fetchedTodoTask!.id.toString(),enteredTask);
    }

     
  }

  @override
  Widget build(BuildContext context) {

    if(widget.isAddTodo == false){
      _taskController.text = widget.fetchedTodoTask!.task!;
    }

    return Container(
      padding: const EdgeInsets.only(
        top: 70.0,
        left: 420.0
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          SizedBox(
                  width: 400,
                  height: 50,
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelText: 'Add a todo task'
                    ),
                  ),
          ),
          const SizedBox(
            width: 20,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_task),
            label: Text(widget.isAddTodo ? 'Add':'Edit'),
            onPressed:(){
              _submitTodoTask();
              widget.refreshDataTable();
            }
          ),
        ],
      ),
    );
  }
}