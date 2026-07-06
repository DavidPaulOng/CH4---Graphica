# 🎨 Drawn to Deception

An iOS-based multiplayer drawing game that tests how well you know your friends' drawing styles and how good you are at fooling them! And hey, if you just want to draw a pretty picture, you can do that too 😉.

## 🧑‍💻 Brought to you by Team Graphica
* **Runi**
* **Dori**
* **David**
* **Belva**
* **Aulia**

---

## 🚀 Starting Assumptions
We built this app with one primary goal: to have fun. We all enjoy drawing (even if some of us aren't exactly Picassos), so we decided to explore Apple's native graphics frameworks. We figured a framework with "graphics" in the name would let us draw *something* and fortunately, we were right! 😄

We assumed that we would be able to make an multiplayer app with GameKit where people can join with codes. We also assumed that people can draw in separate canvasses, submit their drawings, and see each others drawings in a voting phase and also editing each other's drawings, including erasing some parts of the drawing. We expected that GameKit and PencilKit has all the feeatures that we need to create this app.

## 🔍 What We Found
Coming at this from a fresh technical perspective, we had to do some digging into the frameworks. Here is what we discovered along the way:

<img width="647" height="697" alt="Screenshot 2026-07-05 at 22 44 58" src="https://github.com/user-attachments/assets/84b141ba-ebf1-4d2b-a5a7-cd43a34f13aa" />

TL;DR => There are other frameworks with their own function that we will utilize on the other part of the app (and Metal will be used no matter what so...)

By the way, here is the family tree of the frameworks if you are curious

<img width="607" height="588" alt="Screenshot 2026-07-05 at 22 49 25" src="https://github.com/user-attachments/assets/4580d871-1e38-4b70-8a8e-58bb550bec9c" />

About the GameKit itself, we found that our assumptions aligned with what we assumed we were able to do. There is a lobby joining system using codes, canvas data can be shared through the GameKit system so that players can see each others drawings and edit other people's drawing. 

## 🔀 The Branching Path, What We Tried and Dropped
A core mechanic of any good deception game is sabotage. However, we quickly realized that letting players completely erase someone else's drawing might result in real-life, and not in-game, killing! To keep things civil, we needed a limiter. 

We considered two options: removing the eraser entirely, or creating an algorithm to track and limit how much of the canvas could be erased. Naturally, we wanted the second option—but it proved to be a massive technical challenge. We also initially wanted to fully customize our drawing tools, but due to the inherent constraints of Apple's PencilKit framework, we decided to pivot and utilize the built-in toolset instead.

## 🧱 The Roadblock
*Drawn to Deception* is designed to be a lightweight, native SwiftUI app with absolutely no third-party game engines. Everything, from lobby creation to drawing and voting, is handled purely through Apple's official frameworks, namely **PencilKit** and **GameKit**. 

This native approach came with customization constraints:
* **UI Limitations:** PencilKit's built-in UI is rigid, meaning we couldn't heavily alter the look of the drawing tools.
* **Eraser Tracking:** Implementing an "eraser limit" meant stitching together some sketchy (ba dum tss) and unreliable methods. The solutions we brainstormed either clashed with how the PencilKit eraser natively functions or were far too resource-heavy, risking severe optimization issues.

## 🎯 The Decision
At the end of the day, we aren't just making this to prove we can build cool tech; we genuinely want a game that you can play with your friends to ~~ruin your friendships~~ really engage with them!

Ultimately, we decided to lean into making the game fast-paced and impulsive. We completely removed the eraser tool and provided a single, fixed pen where players can only change the ink color. The sabotage mechanic is still very much alive, but instead of deleting your friend's masterpiece, you'll just have to get creative and *add* small details to mess them up 😉.
