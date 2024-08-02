
### Backend 
- (P1) queries 
    - centralize into single file as constants/functions 
    - existing system makes db schema changes risky as we have to search for all the queries that use the db in the code 
    - existing system does not allow logic reuse client -> backend 






1. Get inserts to work for create task page 
2. Refactor create task page to have a centralized notifier provider that provides entire state from selectable options etc. - this way we can easily send the page context to the ai even if the createPage is not shown as well... 

Issue choosing a project requires choosing a team ...
Issue there could be 100s of projects to choose from ... 