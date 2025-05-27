Output vhs/demo.gif

Require nvim 

Set Shell zsh
Set Theme "tokyonight-storm"
Set Width 1800
Set Height 1000
Set Padding 20

Hide
Type "touch main.cc main.lua main.py main.java"
Enter
Type "clear"
Enter
Sleep 250ms
Show
Set TypingSpeed 250ms
Type "nvim"
Enter

Sleep 500ms
Space
Type "ff"
Type "main.cc"
Enter
Hide
Type ":LspStop"
Enter
Sleep 500ms
Show
Type@100ms ":AddHeader"
Enter

Sleep 500ms
Space
Type "ff"
Type "main.py"
Enter
Hide
Type ":LspStop"
Enter
Sleep 500ms
Show
Type@100ms ":AddHeader"
Enter

Sleep 500ms
Space
Type "ff"
Type "main.lua"
Enter
Hide
Type ":LspStop"
Enter
Sleep 500ms
Show
Type@100ms ":AddLicenseMIT"
Enter

Sleep 500ms
Space
Type "ff"
Type "main.java"
Enter
Hide
Type ":LspStop"
Enter
Sleep 500ms
Show
Type@100ms ":AddLicenseGPL3"
Enter

Sleep 500ms
Type ":wqa"
Enter
Hide
Type "rm main.cc main.lua main.py main.java"
Enter
Sleep 5s
