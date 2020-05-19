// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:irisassignment2/bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:table_calendar/table_calendar.dart';
import 'model/task.dart';
import 'package:irisassignment2/calendar.dart';
void main () async  {

  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox(DateFormat.yMMMMd().format(DateTime.now()));
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: BlocProvider<TaskBloc>(
        builder: (context) => TaskBloc(),
        child: FirstPage(),
      ),
    );
  }
}


class FirstPage extends StatelessWidget {
  final TextEditingController controller1 = TextEditingController(); // for text field in addTaskDialog
  final TextEditingController controller2 = TextEditingController(); // for text field in updateTaskDialog
  /* void initState()
  {
    super.initState();
    _calendarController = CalendarController();

  }

  */


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text( "Today : " + DateFormat.yMMMMd().format(DateTime.now())
        )
      ),
        body: Container(
          child: BlocBuilder<TaskBloc,TaskState>(
              builder:(context,state){
                if(state is TaskInitial)
                  {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                      children:<Widget>[
                        Container(
                            margin: EdgeInsets.all(16.0),
                            color: Colors.blue,
                           child:TaskCalendar(),
                            ),
                       buildList(Hive.box(DateFormat.yMMMMd().format(DateTime.now())), DateTime.now())
                      ]
                    );
                  }
                else if(state is LoadedTasks)
                  {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children:<Widget>[
                          Container(
                              margin: EdgeInsets.all(16.0),
                              color: Colors.blue,
                              child:TaskCalendar(),
                  ),
                          buildList(state.task, state.date)
                        ]
                    );

                  }

                return Container();
              }
          )
        )
      );
  }
/*
  @override
  Widget build(BuildContext context) {
     return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(
              "Today : " + DateFormat.yMMMMd().format(DateTime.now())),
        ),
        body: Container(
          child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskInitial) {
                    openTodayBox();
                    return Column(
                        children: <Widget>[
                          TaskCalendar(_calendarController),
                          buildList(Hive.box(DateFormat.yMMMMd().format(DateTime.now())), DateTime.now())
                        ]
                    );
                  }
                  else if (state is LoadedTasks) {
                    return Column(children: <Widget>[
                      TaskCalendar(_calendarController),
                      buildList(state.task, state.date)
                    ]);
                  }
                }
            )
          ,

        ));
  }

 */
/*
  @override
  void dispose()
  {

  }

   */

  Widget buildList(Box taskBox, DateTime date) {

    return ValueListenableBuilder(
        valueListenable: taskBox.listenable(),
        builder: (context, Box taskBox, _) {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: taskBox.length,
            itemBuilder: (context, index) {
              return Card(
                color: (taskBox.getAt(index).completed)?Colors.limeAccent:Colors.white,
                  child: ListTile(
                    onTap: (){
                      taskBox.getAt(index).completed = !taskBox.getAt(index).completed;
                      final taskbloc = BlocProvider.of<TaskBloc>(context);
                      Task updatedDayTask = new Task(taskBox.getAt(index).desc,taskBox.getAt(index).completed);
                      taskbloc.add(ToggleCompleted(date, updatedDayTask, index));
                    },
                      leading: Icon(Icons.check),
                      title: Text(taskBox
                          .getAt(index)
                          .desc),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.update),
                            onPressed: () {
                              updateTaskDialog(context, index, taskBox, date,);
                            },),
                          IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                final taskbloc = BlocProvider.of<TaskBloc>(
                                    context);
                                taskbloc.add(DeleteTask(date, index));

                              })
                        ],
                      )

                  )
              );
            },
          );
        });
  }

/*
  addTaskDialog(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Add task'), //Dialog box with two options
              content:Column(
                  mainAxisSize: MainAxisSize.min,
                  children:<Widget>[
                    Text('Enter task description:'),
                    TextField(
                      controller: controller1,
                    ),
                    Row(
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.all(15.0),
                              child: FlatButton(
                                  child: Text('CONFIRM',
                                    style:TextStyle(
                                      fontSize: 17.0,),
                                  ),
                                  textColor: Colors.green,
                                  onPressed: () {
                                    addTask(Task(controller1.text));
                                    Navigator.pop(context);
                                  }
                              )

                          ),
                          Container(
                              margin: EdgeInsets.all(15.0),
                              child: FlatButton(
                                  child: Text('CANCEL',
                                    style: TextStyle(
                                        fontSize: 17.0),
                                  ),
                                  textColor: Colors.green,
                                  onPressed:(){ //Don't add item
                                    Navigator.pop(context);
                                  }
                              )
                          )

                        ]
                    )

                  ]
              )
          );
        }
    );

  }
  */

  updateTaskDialog(BuildContext context, int index, Box tasks, DateTime date) {
    final taskbloc = BlocProvider.of<TaskBloc>(context);    //Dialog box to
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Updating task'), //Dialog box with two options
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Enter updated task: '),
                    TextField(
                      controller: controller2,
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(15.0),
                          child: FlatButton(
                              child: Text(
                                  'UPDATE', style: TextStyle(fontSize: 17.0)),
                              textColor: Colors.green,
                              onPressed: () {
                                taskbloc.add(UpdateTask(date, Task(
                                    controller2.text,tasks.getAt(index).completed), index));
                                Navigator.pop(context);
                              }
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.all(15.0),
                            child: FlatButton(
                                child: Text(
                                    'CANCEL', style: TextStyle(fontSize: 17.0)),
                                textColor: Colors.green,
                                onPressed: () { //Don't add item
                                }
                            )
                        )
                      ],
                    )


                  ]
              )
          );
        }
    );
  }
}

/*
  }
  deleteTask(int index,DateTime date){ //Delete task from database
    final taskBox = Hive.box('tasks');
    taskBox.deleteAt(index);

  }

 */


/*
  addTask(Task task)//Add task to database
  {
    final taskBox = Hive.box('tasks');
    taskBox.add(task);

  }

 */








