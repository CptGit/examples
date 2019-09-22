### [Emacs] Configurate CC mode advanced indentation

https://stackoverflow.com/questions/1365612/how-to-i-configure-emacs-in-java-mode-so-that-it-doesnt-automatically-align-met/1365821#1365821

This comes from the Info manual for Emacs CC Mode, using GNU Emacs 23.1 on Windows:

Start building your Java class that's not indenting properly. In your case, exactly what you've typed above.

Move your cursor to the start of the line that's not indenting properly. In your case, "String two) {".

Hit C-c C-s (c-show-syntactic-information) to ask Emacs what syntax element it thinks you're looking at. In your case, it'll say something like ((arglist-cont-nonempty n m)).

Use C-c C-o (c-set-offset) to tell it you want to change the indentation level for this syntactic element.
It defaults to what it thinks that syntactic element is, e.g., arglist-cont-nonempty. Just hit RET if that default is correct.

Now it wants to know what expression to use to calculate the offset. In your case, the default is an elisp expression. Delete that, and just use a single plus sign + instead.

Test it out to make sure it's working correctly: Hit TAB a bunch on different lines, or M-x indent-region or similar.

To make it permanent, add this to your .emacs file:
```lisp
(setq c-offsets-alist '((arglist-cont-nonempty . +)))
```

### [Bash] Deal with symbolic/relative/both link when get script absolute path

```bash
_DIR="$( cd -P "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd )"
```
