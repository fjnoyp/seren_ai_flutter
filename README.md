# seren_ai_flutter

A new Flutter project.

## Structure

We adopt a service gropuing architecture, whereby services group the full stack functionality for a given feature. 

For example, the data/ai_chats folder contains the data models, frontend widgets, and db service providers for accessing the data of ai_chats. 

If needed, each service folder should ideally be able to become its own standalone flutter module. 

Powersync is used to sync the data between the client and the Supabase database. Thus raw SQL can be used to query the data and with proper sync rules setup in Powersync, users will not be able to see unauthed data. 

Miro Board: 
- diagrams for logical user flows 
https://miro.com/app/board/uXjVKCs7dtw=/?utm_source=notification&utm_medium=email&utm_campaign=daily-updates&utm_content=view-board-cta

Figma Board: 
- ui screens / basic flows 
https://www.figma.com/design/WD79K7Z9YAXc8SwoTU5r0n/Figma-basics?node-id=1669-162202&t=VU4uBrXEwiZMR5nD-0

Basic AI Flows: 
https://docs.google.com/document/d/1MAOogPCurlaLiia1DLNlKJt969z6Xy0RG4gjaaeKM1g/edit?usp=sharing


## Listen vs Watch in Riverpod

listen does not rebuild the provider, it just calls the callback when the data changes. 

watch rebuilds the provider and all its dependents. This can cause issues with too many rebuilds triggering each other etc. 