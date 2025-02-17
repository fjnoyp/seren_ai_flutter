importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyBHZhXWbRlQN1d2ySgk1XLTyUDc0qToMr8",
  authDomain: "seren-ai.firebaseapp.com",
  projectId: "seren-ai",
  messagingSenderId: "888730365208",
  appId: "1:888730365208:web:a43dd784069dd21009c26d"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);

  const notificationTitle = payload.notification?.title || 'New Message';
  const notificationOptions = {
    body: payload.notification?.body || 'Background Message',
    icon: '/favicon.png',
    data: payload.data,
    tag: 'background-message'
  };
  
  console.log('Showing notification:', { title: notificationTitle, options: notificationOptions });

  // TODO p2: Calling this doesn't seem to do anything 
  return self.registration.showNotification(notificationTitle, notificationOptions);
});

self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notification clicked:', event);
  event.notification.close();

  const clickData = {
    timestamp: new Date().toISOString(),
    notificationData: event.notification.data
  };
  
  const urlToOpen = new URL('/', self.location.origin).href;
  
  event.waitUntil(
    Promise.all([
      self.clients.matchAll({ type: 'window', includeUncontrolled: true })
        .then((clientList) => {
          for (const client of clientList) {
            if (client.url === urlToOpen && 'focus' in client) {
              client.focus();
              client.postMessage({
                type: 'NOTIFICATION_CLICK',
                payload: clickData
              });
              return;
            }
          }
          if (self.clients.openWindow) {
            return self.clients.openWindow(urlToOpen);
          }
        })
    ])
  );
});