A simple, shareable, household to-do list 

This app synchronizes a set of tasks on a remote MySQL table, so that multiple users in the same household can track the creation and completion of those tasks. Some highlights include:

### Minimal CoreData requests

The main tableview controller interacts with transient model layer (Task) when adding, completing, editing, deleting, or uploading to-do items. When the app is idle, the existing Tasks are used to update the local persistent store by initializing CoreData managed object models (TaskModel) with the Task Objects, which are saved on a background context.

### Catch and retry failed URL requests

The NetworkCoordinator adheres to a FailedRequestCatcher protocol. When URL requests result in an error as a result of poor connectivity, these failed requests are stored and reattempted when the task list is refreshed or when the app enters the foreground. If they succeed, they are discarded and the appropriate completion handler takes over. If they fail again, they are shuffled back into the FailedRequestCatcher.
