
### Centralize SQL Queries
- (P2) queries - all sql queries should be centralized into a single file instead of sprinkled everywhere in the codebase. 
    - centralize into single file as constants/functions 
    - existing system makes db schema changes risky as we have to search for all the queries that use the db in the code 
    - existing system does not allow logic reuse client -> backend 

### Shifts - Broken Multiday Support 
- TODO p3: missing multiday shift support + local timezone support
    - If a shift stretches accross midnight it can be ignored 

### Provider Exceptions - Reliance on CurUser and CurOrg ID Providers 
- throw exception if provider that needs curUser has a null curUser ... we shouldn't hide misuse like that. - though check if this breaks existing curUser behavior - because it might go null then not null briefly and break everything ... but the guards should resolve that too ... needs investigation 

### Considerations for Task AI - Choosing a Project 
Issue choosing a project requires choosing a team ...
Issue there could be 100s of projects to choose from ... 