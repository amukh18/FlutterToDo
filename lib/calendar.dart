
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:irisassignment2/bloc/bloc.dart';
import 'package:irisassignment2/model/task.dart';
import 'package:table_calendar/table_calendar.dart';

class TaskCalendar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final TaskBloc _taskBloc = BlocProvider.of<TaskBloc>(context);

    return TableCalendar(
      locale: 'en_US',
      // calendarController: _calendarController,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.none,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      calendarStyle: CalendarStyle(
        weekdayStyle: TextStyle(color: Colors.white),
        weekendStyle: TextStyle(color: Colors.white),
        outsideStyle: TextStyle(color: Colors.grey.shade900),
        unavailableStyle: TextStyle(color: Colors.red),
        outsideWeekendStyle: TextStyle(color: Colors.grey.shade900),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        dowTextBuilder: (date, locale) {
          return DateFormat.E(locale).format(date).substring(0, 2);
        },
        weekdayStyle: TextStyle(color: Colors.white),
        weekendStyle: TextStyle(color: Colors.white),
      ),
      headerVisible: false,
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          _taskBloc.add(LoadTasks(date));
          return Container(
              margin: const EdgeInsets.all(6.0),
              width: 150,
              height: 150,
              child: RaisedButton(
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.blue,
                    ),
                  ),
                ),
                onPressed: (){
                  _taskBloc.add(LoadTasks(date));
                },
                onLongPress: (){
                  final TextEditingController controller1 = TextEditingController();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text('Add task'), //Dialog box with two options
                            content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
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
                                                  style: TextStyle(
                                                    fontSize: 17.0,),
                                                ),
                                                textColor: Colors.green,
                                                onPressed: () {

                                                  _taskBloc.add(AddTask(date, Task(
                                                      controller1.text,false)));
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
                                                onPressed: () { //Don't add item
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
              )

          );
        },
      ),
    );
  }
/*
  daySelected(DateTime date, BuildContext context,TaskBloc taskBloc) {
    taskBloc.add(LoadTasks(date));
  }

 */

  // CalendarController _calendarController ;
  // TaskCalendar(this._calendarController);




}





