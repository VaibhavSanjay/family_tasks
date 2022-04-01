import 'package:family_tasks/pages/Helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../Services/database.dart';
import '../models/family_task_data.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key, required this.onJoinOrCreate, required this.onLeave}) : super(key: key);

  final Function(String famID) onJoinOrCreate;
  final Function() onLeave;


  @override
  State<AccountPage> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  static late String? famID;
  static bool setID = false;
  static late DatabaseService ds;
  static late Stream<FamilyTaskData> stream;
  String _input = '';
  final _formKey = GlobalKey<FormState>();
  bool _foundFamily = false;

  static void setFamID(String? ID) {
    famID = ID;
    setID = true;
    ds = DatabaseService(famID);
    if (famID != null) {
      stream = ds.taskDataForFamily;
    }
  }

  Widget _getButton(IconData icon, String text, String desc, Function() onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        elevation: 5,
        child: Container(
          margin: const EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: Icon(icon, size: MediaQuery.of(context).size.height/8, color: Colors.blueAccent)
                    ),
                    Container(padding: const EdgeInsets.only(left: 20), child: Text(text, style: const TextStyle(fontSize: 50, color: Colors.blueAccent)))
                  ]
              ),
              Container(
                width: MediaQuery.of(context).size.width/3,
                padding: const EdgeInsets.only(top: 10),
                child: Text(desc, style: const TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (setID) {
      return famID == null ? Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          elevation: 10,
                          color: Colors.transparent,
                          child: Container(
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: [0.1, 0.5, 0.7],
                                  colors: [Colors.lightBlueAccent, Colors.lightBlue, Colors.blueAccent],
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(27),
                                  topRight: Radius.circular(27),
                                )
                            ),
                            width: double.infinity,
                            height: 60,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Card(
                          elevation: 10,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: AutoSizeText(
                                'Welcome!',
                                style: TextStyle(
                                    fontSize: 45,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue
                                ),
                                maxLines: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _getButton(
                              FontAwesomeIcons.userPlus,
                              'Create',
                              'Create a New Task Listing. Send the group ID to those you want to add.',
                              () {
                                _input = '';
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Form(
                                      key: _formKey,
                                      child: AlertDialog(
                                        title: const Text('Create New Group', style: TextStyle(fontWeight: FontWeight.bold)),
                                        contentPadding: const EdgeInsets.only(top: 20, left: 24, right: 24),
                                        content: TextFormField(
                                          maxLength: 20,
                                          decoration: const InputDecoration(
                                              hintText: 'Group Name',
                                              border: OutlineInputBorder(),
                                              counterText: ''
                                          ),
                                          onChanged: (String? value) {
                                            _input = value ?? '';
                                          },
                                          validator: (String? value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter a name';
                                            }
                                            return null;
                                          },
                                        ),
                                        actions: [
                                          TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: (){
                                                Navigator.pop(context);
                                              }
                                          ),
                                          TextButton(
                                            child: const Text('Create'),
                                            onPressed: () async {
                                              if (_formKey.currentState!.validate()) {
                                                Navigator.pop(context);
                                                famID = await ds.addNewFamily(_input);
                                                widget.onJoinOrCreate(famID!);
                                              }
                                            }
                                          ),
                                        ]
                                      ),
                                    );
                                  }
                                );
                              },
                            ),
                          ),
                          const Divider(
                            thickness: 8,
                            indent: 20,
                            endIndent: 20,
                            color: Colors.black,
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            child: _getButton(
                              FontAwesomeIcons.peopleRoof,
                              'Join',
                              'If someone already created a group, join it with their ID.',
                               () {
                                  _input = '';
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Form(
                                        key: _formKey,
                                        child: AlertDialog(
                                            title: const Text('Join Group', style: TextStyle(fontWeight: FontWeight.bold)),
                                            contentPadding: const EdgeInsets.only(top: 20, right: 24, left: 24),
                                            content: TextFormField(
                                              maxLength: 30,
                                              decoration: const InputDecoration(
                                                  hintText: 'Group ID',
                                                  border: OutlineInputBorder(),
                                                  counterText: ''
                                              ),
                                              onChanged: (String? value) {
                                                _input = value ?? '';
                                              },
                                              validator: (String? value) {
                                                return _foundFamily ? null : 'Invalid ID';
                                              },
                                            ),
                                            actions: [
                                              TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                  }
                                              ),
                                              TextButton(
                                                  child: const Text('Join'),
                                                  onPressed: () async {
                                                    _foundFamily = await ds.famExists(_input.isEmpty ? '0' : _input);
                                                    if (_formKey.currentState!.validate()) {
                                                      Navigator.pop(context);
                                                      famID = _input;
                                                      widget.onJoinOrCreate(famID!);
                                                    }
                                                  }
                                              ),
                                            ]
                                        ),
                                      );
                                    }
                                  );
                               }
                            )
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ]
          ),
        ),
      ) : StreamBuilder<FamilyTaskData>(
        stream: stream,
        builder: (context, AsyncSnapshot<FamilyTaskData> snapshot) {
          if (snapshot.hasError) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(Icons.error_outline, size: 100),
                  Text('Error!', style: TextStyle(fontSize: 30))
                ]
            );
          } else {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    )
                );
              case ConnectionState.active:
                String name = snapshot.data == null ? '' : snapshot.data!.name;
                int taskCount = snapshot.data == null ? 0 : snapshot.data!.tasks.length;

                List<TaskData> archive = snapshot.data == null ? [] : snapshot.data!.archive;
                int archiveCount = archive.length;
                DateTime? lastArchived = archiveCount > 0 ? archive[archiveCount - 1].archived.toLocal() : null;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (cont) {
                                  return Form(
                                    key: _formKey,
                                    child: AlertDialog(
                                        title: const Text('Edit Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                        contentPadding: const EdgeInsets.only(top: 20, left: 24, right: 24),
                                        content: TextFormField(
                                          initialValue: name,
                                          maxLength: 20,
                                          decoration: const InputDecoration(
                                              hintText: 'Group Name',
                                              border: OutlineInputBorder(),
                                              counterText: ''
                                          ),
                                          onChanged: (String? value) {
                                            _input = value ?? '';
                                          },
                                          validator: (String? value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter a name';
                                            }
                                            return null;
                                          },
                                        ),
                                        actions: [
                                          TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: (){
                                                Navigator.pop(context);
                                              }
                                          ),
                                          TextButton(
                                              child: const Text('Update'),
                                              onPressed: () async {
                                                if (_formKey.currentState!.validate()) {
                                                  Navigator.pop(context);
                                                  await ds.updateFamilyName(_input);
                                                }
                                              }
                                          ),
                                        ]
                                    ),
                                  );
                                }
                            );
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                              alignment: Alignment.center,
                              child: Card(
                                  elevation: 5,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: AutoSizeText(name, style: const TextStyle(fontSize: 40), maxLines: 2)
                                        ),
                                      ),
                                      Container(padding: const EdgeInsets.only(right: 10), child: const Icon(Icons.edit, size: 40))
                                    ],
                                  )
                              )
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Card(
                                    elevation: 5,
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                  child: const Icon(FontAwesomeIcons.clipboard, size: 110)
                                              ),
                                              Text('$taskCount', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
                                            ],
                                          ),
                                          Container(
                                              padding: const EdgeInsets.only(left: 25, right: 25, bottom: 20),
                                              child: const Text('To Do', style: TextStyle(fontSize: 30))
                                          ),
                                        ]
                                    )
                                ),
                                Card(
                                    elevation: 5,
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                  padding: const EdgeInsets.only(top: 20),
                                                  child: const Icon(Icons.inbox, size: 110)
                                              ),
                                              Text('$archiveCount', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
                                            ],
                                          ),
                                          Container(
                                              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                                              child: const Text('Archived', style: TextStyle(fontSize: 30))
                                          ),
                                        ]
                                    )
                                )
                              ]
                          ),
                        ),
                        lastArchived != null ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          child: Card(
                              elevation: 5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                child: AutoSizeText('Last Archived: ${archive[0].name}, '
                                    '${daysOfWeek[lastArchived.weekday]} '
                                    '${DateFormat('h:mm a').format(lastArchived)}',
                                    style: const TextStyle(fontSize: 20),
                                    maxLines: 1,
                                ),
                              )
                          ),
                        ) : const SizedBox.shrink(),

                      ]
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  elevation: 5,
                                  backgroundColor: Colors.white,
                                  textStyle: const TextStyle(fontSize: 20)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Icon(Icons.perm_identity),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Group ID'),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                showDialog<void>(
                                    context: context,
                                    builder: (cont) {
                                      return FamilyIDWidget(famID: famID!);
                                    }
                                );
                              },
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                                primary: Colors.white,
                                elevation: 5,
                                backgroundColor: Colors.red,
                                textStyle: const TextStyle(fontSize: 20, color: Colors.white)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.exit_to_app, color: Colors.white),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Leave'),
                                ),
                              ],
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (cont) {
                                    return AlertDialog(
                                        title: const Text('Leave Family'),
                                        content: const Text('Are you sure you want to leave this family?'),
                                        actions: [
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.pop(cont);
                                            },
                                          ),
                                          TextButton(
                                              child: const Text('Confirm'),
                                              onPressed: () {
                                                Navigator.pop(cont);
                                                widget.onLeave();
                                                setState(() {});
                                              }
                                          )
                                        ]
                                    );
                                  }
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  ]
                );
              case ConnectionState.done:
                return const Center(
                    child: Text('Connection Closed', style: TextStyle(fontSize: 30))
                );
            }
          }
        }
      );
    } else {
      return const Center(
          child: SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          )
      );
    }

  }
}

class FamilyIDWidget extends StatefulWidget {
  final String famID;

  const FamilyIDWidget({Key? key, required this.famID}) : super(key: key);

  @override
  State<FamilyIDWidget> createState() => _FamilyIDWidgetState();
}

class _FamilyIDWidgetState extends State<FamilyIDWidget> {
  IconData _curIcon = Icons.copy;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('Copy and send to others!', style: TextStyle(fontWeight: FontWeight.bold))),
      contentPadding: const EdgeInsets.only(top: 20, left: 12, bottom: 24, right: 0),
      content: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey)
                ),
                child: Text(widget.famID, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30))
            ),
          ),
          IconButton(
              icon: Icon(_curIcon, size: 30),
              onPressed: (){
                setState(() {
                  _curIcon = FontAwesomeIcons.clipboardCheck;
                  Clipboard.setData(ClipboardData(text: widget.famID));
                });
              }
          )
        ],
      ),
    );
  }
}
