
### Code Duplication 
- (P4) task_editable_field and task_meta_data_editable_field 

### Backend 
- (P1) queries 
    - centralize into single file as constants/functions 
    - existing system makes db schema changes risky as we have to search for all the queries that use the db in the code 
    - existing system does not allow logic reuse client -> backend 
    