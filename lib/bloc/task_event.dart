import 'package:equatable/equatable.dart';
import '../model/task.dart';

abstract class TaskEvent extends Equatable{
  const TaskEvent();
}



class LoadTasks extends TaskEvent{
  final DateTime date;
  const LoadTasks(this.date);

  @override

  List<Object> get props => [date];
}
class AddTask extends TaskEvent{
  final DateTime date;
  final Task newDayTask;
  const AddTask(this.date,this.newDayTask);

  @override

  List<Object> get props=>[date,newDayTask];

}
class UpdateTask extends TaskEvent{
  final DateTime date;
  final Task updatedDayTask;
  final int index;
  const UpdateTask(this.date,this.updatedDayTask,this.index);

  @override

  List<Object> get props=>[date,updatedDayTask];

}
class ToggleCompleted extends TaskEvent{
  final DateTime date;
  final Task updatedDayTask;
  final int index;
  const ToggleCompleted(this.date,this.updatedDayTask,this.index);
  @override

  List<Object> get props=>[date,updatedDayTask];
}
class DeleteTask extends TaskEvent{
  final DateTime date;
  final int index;
  const DeleteTask(this.date,this.index);

  @override

  List<Object> get props=>[date,index];


}

