import 'package:cloud_firestore/cloud_firestore.dart';

class ToDoItem {
  String? title;
  String? description;
  bool? isDone;
  String? toDoId;

  ToDoItem({this.title, this.description, this.isDone, this.toDoId});

  copyWith({String? title, String? description, bool? isDone, String? toDoId}) {
    return ToDoItem(
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      toDoId: toDoId ?? this.toDoId
    );
  }

  factory ToDoItem.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? snapshotOptions) {
    final data = snapshot.data();

    return ToDoItem(
      title: data?['title'],
      description: data?['description'],
      isDone: data?['is_done'],
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      if(title != null) 'title': title,
      if(description != null) 'description': description,
      if(isDone != null) 'is_done': isDone,
    };
  }
}