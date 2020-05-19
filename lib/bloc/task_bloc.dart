import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:irisassignment2/bloc/bloc.dart';
import 'package:hive/hive.dart';
import './bloc.dart';
import '../model/task.dart';
import 'package:intl/intl.dart';

class TaskBloc extends Bloc<TaskEvent,TaskState>{
  @override
  TaskState get initialState => TaskInitial();

  @override
  Stream<TaskState> mapEventToState(
      TaskEvent event,
      )async* {
  if (event is LoadTasks)
      {
        await Hive.openBox(DateFormat.yMMMMd().format(event.date));
        final daytask= Hive.box(DateFormat.yMMMMd().format(event.date));
        yield LoadedTasks(daytask,event.date);
      }
    else if (event is AddTask)
    {
      await Hive.openBox(DateFormat.yMMMMd().format(event.date));
      final daytask= Hive.box(DateFormat.yMMMMd().format(event.date));
      daytask.add(event.newDayTask);
      yield LoadedTasks(daytask,event.date);
    }
    else if (event is UpdateTask)
    {  await Hive.openBox(DateFormat.yMMMMd().format(event.date));
       final daytasks = Hive.box(DateFormat.yMMMMd().format(event.date));
       daytasks.putAt(event.index, event.updatedDayTask);
      yield LoadedTasks(daytasks,event.date);
    }
    else if (event is ToggleCompleted)
      {
        await Hive.openBox(DateFormat.yMMMMd().format(event.date));
        final daytasks = Hive.box(DateFormat.yMMMMd().format(event.date));
        daytasks.putAt(event.index, event.updatedDayTask);
        yield LoadedTasks(daytasks,event.date);

      }
    else if (event is DeleteTask)
    {
      await Hive.openBox(DateFormat.yMMMMd().format(event.date));
      final daytasks = Hive.box(DateFormat.yMMMMd().format(event.date));
      daytasks.deleteAt(event.index);
      yield LoadedTasks(daytasks,event.date);
    }
  }


}