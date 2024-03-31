;; This "manifest" file can be passed to 'guix package -m' to reproduce
;; the content of your profile.  This is "symbolic": it only specifies
;; package names.  To reproduce the exact same profile, you also need to
;; capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(specifications->manifest
  (list "telegram-desktop"
        "node"
        "firefox"
        "lld-wrapper"
        "clang"
        "llvm"
        "fzf"
        "gcc-toolchain@11"
        "ninja"
        "htop"
        "python-nose"
        "python-pytest"
        "python-isort"
        "python-lsp-server"
        "poetry"
        "python"
        "guile-colorized"
        "guile-readline"
        "guile"
        "python-lit"
        "cmake"))
