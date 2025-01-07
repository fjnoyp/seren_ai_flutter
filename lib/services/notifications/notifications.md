1. For custom notification icons (recommended), you should add them as drawable resources in:
```android/app/src/main/res/drawable/```

> **XML vector drawables**
>
> Android's vector format
> Must be white and transparent
> Example filename: notification_icon.xml

2. If you plan to use custom notification sounds, add them as raw resources in:
```android/app/src/main/res/raw/```

# About mapping notifications on SharedPreferences
> AI generated text:

Here are the key reasons why cancelling and rescheduling all notifications is better than trying to selectively update them:

1. **Data Consistency**
   - Ensures notifications perfectly match the current state of tasks
   - Eliminates the risk of "ghost notifications" for deleted or modified tasks
   - Prevents duplicate notifications for the same task
2. **Error Prevention**
   - Avoids complex synchronization issues between task data and notification system
   - Eliminates edge cases where notification updates might fail partially
   - Prevents scenarios where notification mappings become corrupted
3. **State Management Simplicity**
   - No need to track which notifications need updating vs. which are still valid
   - Removes the complexity of maintaining a reliable mapping between tasks and notifications
   - Simpler code is less prone to bugs and easier to maintain
4. **Handling Edge Cases**
   - Better handles bulk updates to tasks
   - Properly manages scenarios where task reminder times are modified
   - Cleanly handles app data resets or migrations
5. **System Resource Management**
   - Modern devices can easily handle rescheduling notifications
   - The performance impact is negligible compared to the complexity cost of maintaining perfect sync
   - Prevents potential memory leaks from orphaned notification references

While it might seem less efficient at first glance, the reliability and simplicity benefits far outweigh any minor performance considerations.

> But as we may use the notification service in other places, we shouldn't cancel all notifications in the task schedule notifications service, because it would reschedule only task related notifications and lose other notifications.

> So we're using the notification service in a way that it's not the best practice, but it's the best solution for our use case. We're saving the notification id and scheduled date in SharedPreferences (like `'[notificationType]_notification_[id]'` as the key and a json encoded string `{'element_id': [elementId], 'scheduled_date': [scheduledDate]}` as the value), so we can cancel and reschedule notifications when needed.

> Another solution would be to implement a cancel notification method in the notification service, that would take the notification type and cancel all notifications of that type instead of the current cancelAllNotifications method.
