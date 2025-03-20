

# TODO March 16 2025 

- Split out the filter state to be enum based to avoid filter shared state issue s

- Update the task tool method for find task to use the modal logic and re-add the showOnly logic for the ai ... 

- Improve UI for showing ai response in mobile ... we should have a card by card view instead of a confusing scroll view showing multiple messages ... 


- Ensure existing task search and complex filter search is working for user to ask interesting questions to ai 

- Support multi step reasoning, like if a task for X doesn't exist, create it (expecting a find then create) 
- Summarization of comments for multiple tasks - ie. give me the status of these tasks (and auto read comments into them) 

- Consider ui methods to allow ai to show different screens to the user ...
    like open task, open note, etc.  

- Consider supporting a note based dictation system as well 


# TODO Feb 26 2025 

Enhancing notes experience to be a viable tool for tracking daily work notes or any other notes by voice 


1. Default project should be auto selected 








Auto-Generated End-of-Day Reports:
Receive a concise daily summary of your project’s progress, including completed tasks, delays, and pending tasks. Delivered via push notifications and email (TBD), these reports will prompt users to interact with the AI Chat for insights or explore a visual project overview. (Note: The AI Chat integration is prioritized, while the project screen visualization may require additional development.)

ISSUE: we don't know what was actually changed today ... we only have the changed_at timestamp ... 
So we can get all tasks that were changed today ... but not what was changed ... 

We could know from the push notifications table that Renata will create though ... 










### Shifts - Broken Multiday Support 
- TODO p3: missing multiday shift support + local timezone support
    - If a shift stretches accross midnight it can be ignored 


### Considerations for Task AI - Choosing a Project 
Issue choosing a project requires choosing a team ...
Issue there could be 100s of projects to choose from ... 


# Mattheus Comments
- The AI voice feature creates tasks in the wrong project. Specify the project name for accurate task creation.
- Enable task creation directly on the Gantt chart.

Top priorities:
1. A main panel showing today's tasks and upcoming ones, accessible with a few clicks for efficient time management.
2. The homepage should list all tasks to complete, followed by projects. Clicking a project reveals all related tasks.
3. Display two interfaces on the same page: one for tasks to complete and another for project details.