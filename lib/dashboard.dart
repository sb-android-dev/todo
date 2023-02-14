import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo/sign_in.dart';
import 'package:todo/to_do_item.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _toDoFormKey = GlobalKey<FormState>();
  var title = '';
  var desc = '';

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Dos'),
        actions: [
          GestureDetector(
            child: const Icon(Icons.logout),
            onTap: () {
              signOut();
            },
          )
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            getToDoList();
          });
        },
        child: FutureBuilder<List<ToDoItem>>(
            future: getToDoList(),
            builder: (context, listSnapshot) {
              final list = listSnapshot.data ?? [];
              return list.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        return Card(
                          color: list[index].isDone == true
                              ? Colors.green[100]!
                              : Colors.white,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          clipBehavior: Clip.hardEdge,
                          child: Slidable(
                            endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  if (list[index].isDone != true)
                                    SlidableAction(
                                      onPressed: (context) {
                                        updateToDoNote(context, list[index]);
                                      },
                                      icon: Icons.check,
                                      label: 'Done',
                                      backgroundColor: Colors.green[900]!,
                                      foregroundColor: Colors.white,
                                    ),
                                  SlidableAction(
                                    onPressed: (context) {
                                      deleteToDoNote(context, list[index]);
                                    },
                                    icon: Icons.delete,
                                    label: 'Remove',
                                    backgroundColor: Colors.red[900]!,
                                    foregroundColor: Colors.white,
                                  )
                                ]),
                            closeOnScroll: true,
                            child: ListTile(
                              title:
                                  Text(listSnapshot.data?[index].title ?? 'NA'),
                              subtitle: Text(
                                  listSnapshot.data?[index].description ??
                                      'NA'),
                            ),
                          ),
                        );
                      },
                      itemCount: listSnapshot.data?.length ?? 0,
                    )
                  : const Center(
                      child: Text('No to-do found!'),
                    );
            }),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => addToDoItem(), child: const Icon(Icons.add)),
    );
  }

  void addToDoItem() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              left: 32,
              right: 32,
              top: 32,
              bottom: MediaQuery.of(context).viewInsets.bottom + 32),
          child: Form(
            key: _toDoFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      label: Text('Title'),
                      hintText: 'Enter title for todo. eg. Complete homework'),
                  validator: (value) =>
                      (value != null) ? null : 'Need to add title',
                  onChanged: (value) => title = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      label: Text('Description'),
                      hintText:
                          'Enter description. eg. Need to complete home work of science'),
                  minLines: 3,
                  maxLines: 3,
                  validator: (value) =>
                      (value != null) ? null : 'Need to add description',
                  onChanged: (value) => desc = value,
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_toDoFormKey.currentState != null &&
                        _toDoFormKey.currentState!.validate()) {
                      addToDoNote(context);
                    }
                  },
                  child: const Text('Save'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  addToDoNote(BuildContext context) async {
    final toDo = ToDoItem(title: title, description: desc, isDone: false);

    await db
        .collection('to-do')
        .withConverter(
            fromFirestore: ToDoItem.fromFireStore,
            toFirestore: (toDoItem, options) => toDoItem.toFireStore())
        .add(toDo)
        .then((value) {
      print(value.id);

      setState(() {
        getToDoList();
      });
    });

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  updateToDoNote(BuildContext context, ToDoItem toDoNote) async {
    await db
        .collection('to-do')
        .withConverter(
            fromFirestore: ToDoItem.fromFireStore,
            toFirestore: (toDoItem, options) => toDoItem.toFireStore())
        .doc(toDoNote.toDoId)
        .update({'is_done': true}).then((value) {
      setState(() {
        getToDoList();
      });
    });

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  deleteToDoNote(BuildContext context, ToDoItem toDoNote) async {
    await db
        .collection('to-do')
        .withConverter(
            fromFirestore: ToDoItem.fromFireStore,
            toFirestore: (toDoItem, options) => toDoItem.toFireStore())
        .doc(toDoNote.toDoId)
        .delete()
        .then((value) {
      setState(() {
        getToDoList();
      });
    });

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<List<ToDoItem>> getToDoList() async {
    final toDoBase = await db
        .collection('to-do')
        .withConverter(
            fromFirestore: ToDoItem.fromFireStore,
            toFirestore: (toDoItem, options) => toDoItem.toFireStore())
        .get();

    final list = <ToDoItem>[];

    for (var toDo in toDoBase.docs) {
      print('...${toDo.data().isDone}');
      list.add(toDo.data().copyWith(toDoId: toDo.id));
    }

    return list;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SignIn()));
  }
}
