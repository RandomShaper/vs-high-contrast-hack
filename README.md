# ~Visual Studio 2017 high contrast hack~ [deprecated]

Copyright 2017 Pedro J. Estébanez (MIT-licensed)

__TL;DR: Run this and enjoy Visual Studio's dark theme even if you are using Windows with a high contrast one.__

Visual Studio 2017, as happens with earlier versions, forces its high contrast theme if Windows is under a high contrast theme as well.
Microsoft seems not to be interested in fixing it so people have to use certain registry hacks to use Visual Studio's dark theme.
Before the 2017 release, Visual Studio settings were right in the registry and you could do the hack by hand more or less easily.

A first problem with that is that under some circumstances (for instance, after updates) the theme setting switches back to high contrast
and you have to re-apply the hack. Another problem is that from the 2017 release the registry settings have been moved to a hive file
so you have first to load it into the global registry, do the hack and unload it again.

The purpose of this program is to apply the hack for Visual Studio 2017 automatically. It makes a backup of the key containing
the high contrast theme to a new key with '.backup' appended to its name and copies the dark theme key recursively over that of the high contrast one.
It first checks if the backup is already present to avoid overwriting it with the already-tampered data.

This program applies the hack on every installation of Visual Studio 2017 present in the system.

Credits to Chris Shrigley for his post on this: http://shrigley.com/visual-studio-2017-high-contrast-theme-registry-hack/

__THIS SCRIPT MUST BE RUN WITH ADMINISTRATIVE PRIVILEGES.__
