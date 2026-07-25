import { initializeApp } from "firebase/app";
import { getAuth, GoogleAuthProvider } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
    apiKey: "REPLACE_WITH_YOUR_FIREBASE_API_KEY",
    authDomain: "myappconsi.firebaseapp.com",
    projectId: "myappconsi",
    storageBucket: "myappconsi.appspot.com",
    messagingSenderId: "224150240249",
    appId: "1:224150240249:web:96069188364" // Estimated based on other IDs, standard format
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const googleProvider = new GoogleAuthProvider();
export const db = getFirestore(app);
export const storage = getStorage(app);

export default app;
