<b>Hand Talk</b>

The app is inspired by my experience at Sunyi Coffee, a very nice coffee shop and great experience, but sadly i don't understand any hand language and hardly understand the waiter there. So i decided to develop this app called HandTalk, the main goals of the app is to help people who use hand language and not, to communicate to each other. There are 2 main features of the app:
1. camera detection with the help of machine learning, as for hand language users, they can use the app to communicate to people who don't understand hand language, they just need to do the hand pose towards the camera, and the app will translate it as well as speak it to people. As for people who don't understand hand language, they can use the app the same as hand language users, but put the camera towards hand language users hand pose, and the app will translate the hand pose, as well as displaying and speaking the result.
   
2. For the second feature, this one is to help people to communicate with hand language users, where of course people still need to use hand language, so the second one is to help people to learn hand language, with the help of machine learning, user can learn hand language in the app, then take some kind of quiz, where user will randomly asked to do hand pose (of hand language) of any alphabet or word, take the picture (in app), then the machine learning will verify the result, and when user is right, user can do another one, and when user is wrong, the app will show user the right hand pose, then the user can do another one again.

<br></br>
<b>App Screenshots</b>

![HandTalk_Mix_SS](https://github.com/darrenthiores/HandTalk/assets/69592810/e757c30a-6d59-4eb3-ba27-f375c5e8e814)


<br></br>
The ML Model used in app, is created using CreateML, and trained with this dataset from Kaggle:
https://www.kaggle.com/datasets/debashishsau/aslamerican-sign-language-aplhabet-dataset

<br></br>
<b>Important</b>
- The app is built as App Playground, so to run the app after download on Github, make sure to add .swiftpm extension to the folder.
- In order to use ML Model in App Playground, please make sure the MLModel folder on Package.swift is using .copy() like this:
  
<img width="211" alt="Screenshot 2024-02-21 at 14 43 27" src="https://github.com/darrenthiores/HandTalk/assets/69592810/afb76da1-93cc-4a14-85f0-41e5b828a631">


<br></br>
<b>Notes</b>
1. The ML Model used in app, is the best i can get from CreateML and might be inaccurate sometimes. I only able to train 28 classes with each around 100 photos / class, more than that and the CreateML is error. This issues also happened to some people, who already opened a thread:
   - https://forums.developer.apple.com/forums/thread/735252
   - https://forums.developer.apple.com/forums/thread/727140
     
2.  The app currently only supports basic hand language, which are alphabets (A-Z), Space, and Delete.
