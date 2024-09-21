
### Backend 
- (P2) queries 
    - centralize into single file as constants/functions 
    - existing system makes db schema changes risky as we have to search for all the queries that use the db in the code 
    - existing system does not allow logic reuse client -> backend 


- Remove the readProviders - we should just read directly snad save SQl query templates that can be reused between backend, frontend, and whatever code ... 
    - Typing the SQL calls hardcodes functionality to Flutter 


- TODO p3: missing multiday shift support + local timezone support


- throw exception if provider that needs curUser has a null curUser ... we shouldn't hide misuse like that. - though check if this breaks existing curUser behavior - because it might go null then not null briefly and break everything ... but the guards should resolve that too ... needs investigation 

For Task AI : 

Issue choosing a project requires choosing a team ...
Issue there could be 100s of projects to choose from ... 