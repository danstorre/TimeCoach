# ``TimeCoach``

TimeCoach it's an app that makes you a motiviated and discipline person by helping you dominate your time. Using well known time mananement techniques like pomodoro. You can quickly start, skip and stop your timer by using your voice or simple tap gestures.

It provides reach notifications and complications that lets you keep focus on your work, home or study activities without using your phone. It will also keep you updated in how much time you got left between work or break timeframes, and it will also provide you with how many pomodoros per category per day.

## Story: User wants to start Pomodoro timer

## Narrative #1

As a customer
I want the app to start the timer pomodoro
So that I can start tracking my time while I'm doing any task.

### Scenarios (Acceptance criteria)

Given a customer
When the customer starts a timer
Then the app should show the timer countdown.

## Start Timer Use Case

Data:
- No Data

Primary Course (happy path):

- System executes "Start timer" command.
- System executes timer start.
- System delivers time progress.

Start Timer Error Course (sad path):

- System delivers start time error.

Start Time Progress (sad path):

- System delivers time progress error. 
