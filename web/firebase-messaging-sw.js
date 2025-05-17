importScripts("https://www.gstatic.com/firebasejs/7.16.1/firebase-app.js");
importScripts(
    "https://www.gstatic.com/firebasejs/7.16.1/firebase-messaging.js",
);
// For an optimal experience using Cloud Messaging, also add the Firebase SDK for Analytics.
importScripts(
    "https://www.gstatic.com/firebasejs/7.16.1/firebase-analytics.js",
);

// Initialize the Firebase app in the service worker by passing in the
// messagingSenderId.
firebase.initializeApp({
    apiKey: "AIzaSyCeuJe7RNmfU6-mNLf6McA5QElAsH_kjqw",
    authDomain: "bookingapp-5bc4d.firebaseapp.com",
    projectId: "bookingapp-5bc4d",
    storageBucket: "bookingapp-5bc4d.firebasestorage.app",
    messagingSenderId: "756529764904",
    appId: "1:756529764904:web:4addfcabbf4c4e7d26331d",
    measurementId: "G-7M6516JVJQ"
  }
);

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function(payload) {
    console.log(
        "[firebase-messaging-sw.js] Received background message ",
        payload,
    );
    // Customize notification here
    const notificationTitle = "Background Message Title";
    const notificationOptions = {
        body: "Background Message body.",
        icon: "/favicon.png",
    };

    return self.registration.showNotification(

        notificationTitle,
        notificationOptions,
    );

    
});
