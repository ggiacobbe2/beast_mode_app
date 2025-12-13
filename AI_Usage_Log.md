- Date and AI tool used
- What was asked or generated
- How it was applied
- Reflection on what was learned

 11/29: ChatGPT
	•	Asked for help integrating Firebase authorization into the login page.
	•	AI generated pseudocode connecting AuthService to the login form, handling signInWithEmailAndPassword, navigation, and error feedback.
	•	I learned the importance of centralizing authentication logic in a service while keeping UI components responsible for validation and user messaging.

2. 11/29: ChatGPT
	•	Asked how to enable photo uploads to a page.
	•	AI provided steps to pick an image, upload it to Firebase Storage, store metadata in Firestore, and stream entries back into the UI.
	•	I learned to separate storage uploads from Firestore metadata writes for more predictable data retrieval and display.

3. 12/4: ChatGPT
	•	Asked how to list active challenges and display a “Join” button for each challenge card.
	•	AI helped refactor the Challenges screen to stream Firestore data and manage join state using ChallengeService.
	•	I learned how to combine Firestore streams with optimistic local state for a more responsive UI.

4. 12/5: ChatGPT
	•	Asked about the difference between the Indexes and Data sections in Firebase Firestore.
	•	AI explained that data represents stored documents and fields, while indexes are metadata used to optimize queries.
	•	I learned to treat indexes as query infrastructure and only create composite indexes when a query explicitly requires them.

5. 12/5: ChatGPT
	•	Asked how to structure progress logging for a 7-day push-up challenge.
	•	AI helped design helper functions for tracking daily progress and integrating join/leave logic with ChallengeService.
	•	I learned how to aggregate Firestore map data into a clear, streak-style progress view.

6. 12/7: ChatGPT
	•	Asked how to format the feed index in Firestore.
	•	AI explained best practices for structuring feed documents with ownerId and createdAt, using orderBy without requiring composite indexes.
	•	I learned to verify index requirements early to avoid runtime Firestore index errors.

7. 12/8: ChatGPT
	•	Asked for help fixing a fatal Gradle issue in a Flutter project.
	•	AI helped move the Flutter project to a new folder, resolving Gradle configuration errors.
	•	I learned that conflicting Gradle language settings can break compilation and that changes should be tested incrementally.

8. 12/12: ChatGPT
	•	Asked for help deleting a workout log and ensuring the related home feed post was also removed.
	•	AI helped add delete logic to directly remove the corresponding Firestore document.
	•	I learned about maintaining data consistency across Firestore using shared, reusable logic.

9. 12/13: ChatGPT
	•	Asked for help flipping the weightProgress slider logic.
	•	AI helped update the slider to dynamically adjust minimum and maximum values based on starting and goal weights.
	•	I learned how to manipulate Flutter sliders to handle both increasing and decreasing progress ranges.

10. Firebase Firestore Challenge Service
	•	Asked for help creating the createChallenge function and updating challenge data in Firebase.
	•	AI assisted in implementing a service class to manage challenge creation, attributes, and user participation data.
	•	I learned how to centralize Firebase operations in a service and reuse them across features such as likes and progress tracking.
