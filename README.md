# Structure

We adopt a service gropuing architecture, whereby services group the full stack functionality for a given feature. 

For example, the data/ai_chats folder contains the data models, frontend widgets, and db service providers for accessing the data of ai_chats. 

If needed, each service folder should ideally be able to become its own standalone flutter module. 

When separating modules, think in terms of discrete use cases and reduce amount of cross module imports. 

Powersync is used to sync the data between the client and the Supabase database. Thus raw SQL can be used to query the data and with proper sync rules setup in Powersync, users will not be able to see unauthed data. 

Miro Board: 
- diagrams for logical user flows 
https://miro.com/app/board/uXjVKCs7dtw=/?utm_source=notification&utm_medium=email&utm_campaign=daily-updates&utm_content=view-board-cta

Figma Board: 
- ui screens / basic flows 
https://www.figma.com/design/WD79K7Z9YAXc8SwoTU5r0n/Figma-basics?node-id=1669-162202&t=VU4uBrXEwiZMR5nD-0

Basic AI Flows: 
https://docs.google.com/document/d/1MAOogPCurlaLiia1DLNlKJt969z6Xy0RG4gjaaeKM1g/edit?usp=sharing

#### Organizing Widgets

Widgets that use multiple data classes should exist in the top level widgets folder. 
Ideally all likewise widgets should be grouped together in sub folders. 

Widgets that only display data of a specific table can exist in the data folder (ie. data/ai_chats/widgest/ai_chat_threads_page.dart) 

#### data/
Contains all classes for interacting with postgres data tables. 

#### ai_interaction/
Classes for interacting with LLM 

# AI Interactions

Currently TBD (Oct 8 24) 
We shifted all state from form to notifierproviders 
This was to make it easier for an ai provider to just control another provider to update the ui state, unsure of other options here. 

We can't easily use form state anymore, because we'd need to have a two way binding between form and provider state. 

Current system supports ai filling out fields, but we have no system for button clicks being triggered by ai... 
There may need to be another provider that controls the button state that can make it appear to get pressed ... 

# Considerations

## Listen vs Watch in Riverpod

listen does not rebuild the provider, it just calls the callback when the data changes. 

watch rebuilds the provider and all its dependents. This can cause issues with too many rebuilds triggering each other etc. 

## Time Zone - DateTime Issues 
For all DateTime calculations USE UTC - for any display use TOLOCAL

Postgres appears to store all datetimes in UTC. 
So any datetime received must be converted to the local timezone before displaying! 


# Questions 

How does this repository architecture differ from clean architecture and why? What are the tradeoffs? 

- General architecture goes data/service/providers. These providers are used in widgets/. Providers are composed, so future architecture may want to make a distinction between pure providers and composed providers. 

Why is the current openTaskPage code bad? 

- The entire page state is being initiated in a method outside of the Router

