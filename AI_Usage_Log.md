- Date and AI tool used
- What was asked or generated
- How it was applied
- Reflection on what was learned

1. 12/8: ChatGPT
  - Asked for help on fixing fatal issue regarding Gradle.
  - AI helped to move flutter project to a new folder, resolving Gradle errors.
  - I learned that the Flutter app wouldn't compile due to conflicting languages. I discovered that there were different languages in these Gradle files and editing them can cause fatal errors. It is best to test changes one at a time and not remove any of those files.

2. 12/12: ChatGPT
  - When deleting the workout log, I needed help for it to also delete the post in the home feed.
  - Added logic in the delete method to remove directly from Firestore.
  - Learned about data consistency across Firestore, using concise code to use across dart files.

3. 12/13: ChatGPT
  - Asked for help flipping the weightProgress slider.
  - Updated slider logic to dynamically adjust values and change minimum value = startingWeight and maximum value = goalWeight.
  - Learned how to manipulate Flutter slider and adjust values regardless of if startingWeight was > or < goalWeight.

4. Firebase Firestore Challenge Service
  - Asked help creating the createChallenge function and adjusting challenge in Firebase.
  - Helped implementing a service class that handles challenges and all of its attributes. Helped save user data regarding challenges in Firebase.
  - Learned how to call Firebase operations and apply it to other processes within the app such as saving likes.
