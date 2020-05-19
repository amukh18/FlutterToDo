import 'package:hive/hive.dart';
part 'task.g.dart';
@HiveType(typeId:0)
class Task{
  @HiveField(0)
  String desc;
  @HiveField(1)
  bool completed;
  Task(this.desc,this.completed);
}