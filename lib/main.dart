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
import 'model/task.dart';
import 'package:irisassignment2/calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;

void main () async  {

  WidgetsFlutterBinding.ensureInitialized(); //For both flutter_local notifications and Hive
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path); //Hive initialization
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox(DateFormat.yMMMMd().format(DateTime.now())); //Open today's box to load today's tasks

  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  var initializationSettingsAndroid = AndroidInitializationSettings('task_image');// Initialization with custom notification icon
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(initializationSettingsAndroid,initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: BlocProvider<TaskBloc>( //To provide TaskBloc
        builder: (context) => TaskBloc(),
        child: FirstPage(),
      ),
    );
  }
}


class FirstPage extends StatelessWidget {
  final TextEditingController controller1 = TextEditingController(); // for text field in addTaskDialog
  final TextEditingController controller2 = TextEditingController(); // for text field in updateTaskDialog

 //To show notification
  Future<void> _showNotification() async {
    Box task = Hive.box(DateFormat.yMMMMd().format(DateTime.now()));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Todo App', 'You have ${task.length} tasks to complete today!', platformChannelSpecifics);
  }
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
                if(state is TaskInitial) //Initial state
                  {
                    _showNotification();

                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                      children:<Widget>[
                        Container(
                            margin: EdgeInsets.all(16.0),
                            color: Colors.greenAccent,
                           child:TaskCalendar(), //Calendar
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
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                              color: Colors.redAccent,
                              child:TaskCalendar(),//Calendar
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
                            icon: Icon(Icons.update), //UPDATE TASK
                            onPressed: () {
                              updateTaskDialog(context, index, taskBox, date,); //OPEN NEW DIALOG
                            },),
                          IconButton(
                              icon: Icon(Icons.delete), //DELETE TASK
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


//DIALOG BOX TO UPDATE TASK
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










