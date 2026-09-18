class SubTask {
  final String id;
  String title;
  bool isDone;

  SubTask({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  Map<String, dynamic> toMap(String taskId) {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'isDone': isDone ? 1 : 0,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] == 1,
    );
  }
}
