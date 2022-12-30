# AE BDSLauncher

AE BDSLauncher allows you to set up rules to automatically decide which version and which instance of Delphi you want to open a Delphi source file with.

If started without any parameters, the rule editor main window will show up.
Here a list of file masks can be provided. If the file which is about to be open matches any of these, it will be opened in the version selected under.
There are situations when a project has to be open for a .pas (.dfm more likely) to appear correctly.
To support this, you can set a string which has to be contained in the IDE caption for it to be selected. An empty value means any (the first) available instance.
If there were no instances found with this criteria, a new instance will be launched with the parameters you specify (should be the main project .dproj / .dpk).

If a parameter is specified (and the file indeed exists) two things can happen. Either a rule will decide which version / instance the selected file
should be started in, or if there's none a selector will appear. 

If more rules would apply to the source file but the specified instance is not found, the last will be selected alphabetically.
In case any rule was selected, no window is shown, only the IDE is launched and / or the source file is opened and the launcher will close shortly after.

In theory, the new launcher should support all Delphi versions from 6 and up, however the DDE component used (to do the heavy lifting) was only tested
with 7 and 10, 10.1, 10.2, 10.4 and 11.

Settings are stored in AppData, so each user with access to the same PC can have different rules set up.

Initial thoughts, birth of the application can be checked on [DelphiPraxis](https://en.delphipraxis.net/topic/8086-ae-bdslauncher/).

This codebase is using AEFramework, which is also hosted on [GitHub](https://github.com/aehimself/AEFramework)

© 2022 by Akos Eigler, licensed under [Creative Commons Attribution 4.0 International](http://creativecommons.org/licenses/by/4.0/)
