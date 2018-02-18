# mineos
GUI Computer Mod for Minetest

Credits:
 - Code: Tmanyo
 - Textures: Tmanyo, DI3HARD139, and Nathan Salapat
 - Models: Nathan Salapat (His textures and models were originally used in the Bank Accounts Mod.)

Note for Collaborators:

Goals:
 - Make basic application features uniform (Top right "-- Maximize X")
 - Make code as efficient as possible (My code that I have been throwing together is not very efficient, but I am going to fix that.)
 - Create realistic, neat, and user friendly applications.
 - I am going to change the structure of the files. (I am going to split the code into different files, instead of bunched up in init.lua.)
 - Each application will have it's own file. (Dofile must be added to init.lua so that the application is ran.)

To-do list:
 - Add more features to email.
 - Add a software center to make it possible/easier for third party applications.
 - Clean up code.
 
Features:
 - Notepad
   - Save .mn (minenote - equivalent to .txt) files.
   - Open saved .mn files.
 - Calculator
   - Calculate equations with buttons or more complex equations using a keyboard.
 - Email
   - Send and receive emails.
   - View inbox and sentbox.
   - Mark emails as: read or important.
   - Replying and Forwarding right from specific email.
   - Delete emails.
 - Tmusic_Player
   - Play .ogg Vorbis files from the sounds folder.
   - Help documentation in game.
   - Looping
 - Pic_Viewer
   - View pictures listed in files.Pictures.
 - Terminal
   - Use commands to complete tasks.
   - Get a list of commands by typing "commands -a".
 - File System
   - View and start desktop applications.
   - View .mn, .ogg, and .png files.
   - Search files.
   - Delete files.
 - Multitasking
   - Work in multiple applications at once.
 
 Important Notes for Testing Purposes:
  - Clock only progresses on its own when on the desktop without applications open. (Otherwise it progresses when fields are pressed.)
  - Sometimes the task icons on the taskbar take 2 clicks to operate. (Known issue)
  - Terminal is the least tested application.
