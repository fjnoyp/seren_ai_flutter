// // Load the related tasks of another task

// // We separate this from JoinedTasks because:
// // 1. We don't always needs related tasks of all tasks, especially when loading a lot of tasks
// // 2. Loading related tasks would complicate task loading queries which are already complex
// // 3. We can load related tasks when needed, and not when loading tasks

// class TaskRelationsRepository extends BaseRepository<TaskRelationsModel> {
//   const TaskRelationsRepository(super.db);
// }
