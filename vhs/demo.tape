Output vhs/demo.gif

Require nvim 

Set Shell zsh
Set Theme "tokyonight-storm"
Set Width 1800
Set Height 1000
Set Padding 20

Hide
Type "touch main.sh main.cc main.py main.php"
Enter
Type "echo '<?php\n echo 'SHOWCASE';\n?>' > main.php"
Enter
Type "echo '#!/bin/bash\n echo 'SHOWCASE'\n' > main.sh"
Enter
Type "echo 'SHOWCASE APACHE LICENSE' > LICENSE-APACHE"
Enter
Type "echo 'SHOWCASE MIT LICENSE' > LICENSE-MIT"
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
Type "main.sh"
Enter
Hide
Type ":LspStop"
Enter
Sleep 500ms
Show
Type@100ms ":Header"
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
Type@100ms ":Header"
Enter

Sleep 500ms
Space
Type "ff"
Type "main.php"
Enter
Hide
Type ":LspStop"
Enter
Sleep 500ms
Show
Type@100ms ":Header MIT"
Enter

Sleep 500ms
Type ":wqa"
Enter
Hide
Type@1ms "jq '.license_from_file = true' ./vhs/.header.nvim > tmp && mv tmp ./vhs/.header.nvim"
Enter
Type@1ms "cp ./vhs/.header.nvim ."
Enter
Type "clear"
Enter
Show
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
Type@100ms ":Header"
Enter
Sleep 500ms
Type@100ms "j"
Sleep 500ms
Enter

Sleep 500ms
Type ":wqa"
Enter
Hide
Type@1ms "rm main.sh main.cc main.py main.php LICENSE-APACHE LICENSE-MIT .header.nvim"
Enter
Type@1ms "jq '.license_from_file = false' ./vhs/.header.nvim > tmp && mv tmp ./vhs/.header.nvim"
Enter
Sleep 5s
