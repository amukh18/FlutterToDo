import 'package:equatable/equatable.dart';
import '../model/task.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

abstract class TaskState extends Equatable {
  const TaskState();
}

class TaskInitial extends TaskState {
  const TaskInitial();
  @override
  List<Object> get props => [];
}


/*
class DateSelected extends TaskState{
  const DateSelected();
  @override
  List<Object> get props => [];
}
*/

class LoadedTasks extends TaskState {
  final Box task;
  final DateTime date;
  const LoadedTasks(this.task,this.date);
  @override
  List<Object> get props => [task,date];
}