import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tasks/Services/authentication.dart';
import 'package:family_tasks/models/family_task_data.dart';
import 'package:firebase_core/firebase_core.dart';
import '../pages/Helpers/constants.dart';

class DatabaseService {
  final String famID;
  DatabaseService(this.famID);

  static final CollectionReference taskDataCollection = FirebaseFirestore.instance.collection('family_tasks');
  static final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  static final AuthenticationService auth = AuthenticationService();

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Stream<FamilyTaskData> get taskDataForFamily {
    return taskDataCollection.doc(famID).snapshots().map(_taskDataFromSnapshot);
  }

  Future<FamilyTaskData> getSingleSnapshot() async {
    return _taskDataFromSnapshot(await taskDataCollection.doc(famID).get());
  }

  FamilyTaskData _taskDataFromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    FamilyTaskData ret = FamilyTaskData(
        tasks: List<TaskData>.generate(
          data['data'].length,
          (int index) => TaskData(
            name: data['data'][index]['name'],
            desc: data['data'][index]['desc'],
            taskType: TaskType.values[data['data'][index]['taskType']],
            status: Status.values[data['data'][index]['status']],
            due: (data['data'][index]['due'] as Timestamp).toDate(),
            color: availableColors[data['data'][index]['color']],
            location: data['data'][index]['location'],
            coords: data['data'][index]['coords'].cast<double>(),
            lastRem: (data['data'][index]['lastRem'] as Timestamp).toDate()
          )
        ),
        archive: List<TaskData>.generate(
            data['archive'].length,
            (int index) => TaskData(
              name: data['archive'][index]['name'],
              desc: data['archive'][index]['desc'],
              taskType: TaskType.values[data['archive'][index]['taskType']],
              status: Status.values[data['archive'][index]['status']],
              due: (data['archive'][index]['due'] as Timestamp).toDate(),
              color: availableColors[data['archive'][index]['color']],
              location: data['archive'][index]['location'],
              coords: data['archive'][index]['coords'].cast<double>(),
              lastRem: (data['archive'][index]['lastRem'] as Timestamp).toDate(),
              archived: (data['archive'][index]['archived'] as Timestamp).toDate()
            )
        ),
        name: data['name']
    );
    return ret;
  }

  Future<void> updateTaskData(List<TaskData> taskData) async {
    await taskDataCollection.doc(famID).update({
      'data': taskData.map((td) => {
        'name': td.name,
        'desc': td.desc,
        'taskType': TaskType.values.indexOf(td.taskType),
        'status': Status.values.indexOf(td.status),
        'due': Timestamp.fromDate(td.due),
        'color': availableColors.indexOf(td.color),
        'location': td.location,
        'coords': td.coords.cast<dynamic>(),
        'lastRem': Timestamp.fromDate(td.lastRem)
      }).toList()
    });
  }

  Future<void> updateArchiveData(List<TaskData> taskData) async {
    await taskDataCollection.doc(famID).update({
      'archive': taskData.map((td) =>
      {
        'name': td.name,
        'desc': td.desc,
        'taskType': TaskType.values.indexOf(td.taskType),
        'status': Status.values.indexOf(td.status),
        'due': Timestamp.fromDate(td.due),
        'color': availableColors.indexOf(td.color),
        'location': td.location,
        'coords': td.coords.cast<dynamic>(),
        'lastRem': Timestamp.fromDate(td.lastRem),
        'archived': Timestamp.fromDate(td.archived)
      }).toList()
    });
  }

  Future<void> updateFamilyName(String name) async {
    await taskDataCollection.doc(famID).update({
      'name': name
    });
  }

  Future<String> addNewFamily(String name) async {
    return (await taskDataCollection.add({
      'name': name,
      'data': [],
      'archive': []
    })).id;
  }

  static Future<String> get famIDFromAuth async {
    return (await userCollection.doc(auth.id).get()).get('group');
  }

  Future<bool> famExists({String? name}) async {
    String s = name ?? famID;
    if (name != null) {
      await userCollection.doc(auth.id).set({'group': name});
    }
    return (await taskDataCollection.doc(s).get()).exists;
  }

  static Future setUserFamily(String famID) async {
    await userCollection.doc(auth.id!).update({'group': famID});
  }

  static Future leaveUserFamily() async {
    await userCollection.doc(auth.id!).update({'group': '0'});
  }
}