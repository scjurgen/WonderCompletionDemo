

Implemented options

- App is iOS Universal binary, landscape ad portrait using Autolayout.
- Core data for persistence (Bare minimum of coredata: no relations, no fancy order [only user assigned Order]).
- Multithread for update (in simulation, see Autosync.m)
- No Storyboards used.
- Cells are custom (but not autolayout, as it disturbs the standard table edit)
- Add an existing wonder and modify or delete later (full modifications).
- Order as you like in edit mode.
- Bare minimum of graphics, only buttons have a simple png background
- Coredata stuff is NOT instantiated in the app delegate, but in StorageManager.m
- Localised in german, english and italian
- All material provided:
  + PSD's (with generation scripts for logos and splash)
  + Logic Audio file for sound effect on completion
  + parse file for world heritage list
  + template html for info

Create a wonder: 
    - When tapping "NEW": Choose from a list of world heritage items the wonder you like to complete in your world.
    - You can modify the name and location in the list, or change values in a PopOver

Complete a wonder: this will take time, every 10 seconds some days will be added to the completed work necessary, depending on the number of workers assigned.
You can complete an item by tapping on it and modify the workload, increasing the workers.

Completed wonders will be signed, signalled and appear at the end of the list.


Update is simulated on a different thread to mimick the behaviour of network access, the network is accessed (www.nerdware.net/wondercompletion/workload.php) but the result is discarded,
this simulation consists in: get current items (main thread), update items(secondary thread), store items (main thread). The operations are @synchronized(self).

Updateitems are injected into the main thread, these will update the user-interface automatic (KVO).
 There is an important issue, updates while editing a single item could be discarded because they are modified locally. This could be addressed in a future wunder demo ;-).


Issues:
- polling should be replaced with push notifications (depends)
- one crash in audio, unsure for reason.
- framework contains SenTest, but is not used (not much to test yet, no TDD)
- the version check on the sqlite database is not coupled to the core data but using sqlite directly. Though it is useful for development (recopy database on change).
- Splashscreens are in the root directory (that is ugly, needs to be sorted out)
- Rotating device while the WonderItemViewController is popped up destroys the tableview horizontal bounds (close and reopen cleans it)



