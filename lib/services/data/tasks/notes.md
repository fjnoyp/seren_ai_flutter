2. task
	1. id
	2. name
	3. description
	4. status
	5. priority
	6. dueDate
	7. createdDate
	8. lastUpdatedDate
	9. authorUserId 
	10. assignedUserId
	11. parentTeamId
	12. parentProjectId 
	13. estimatedDuration 
	14. *listDurations* 
		1. *list of start and end times for working on this task* 




    	   
**DatabaseProviders**
2. TaskDatabaseProvider
	1. create/delete/update task 



**Models**

2. TaskPreviewModel 
	1. id 
	2. name
	3. status
	4. priority
	5. dueDate
	6. lastUpdatedDate
3. TaskModel 
	1. Load all fields of the Task Row 