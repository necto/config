;; This "manifest" file can be passed to 'guix package -m' to reproduce
;; the content of your profile.  This is "symbolic": it only specifies
;; package names.  To reproduce the exact same profile, you also need to
;; capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (guix packages)
             (guix profiles)
             (gnu packages)
             (gnu packages llvm)
             (guix utils)
             (guix gexp))

;;; Not installing gcc-toolchain on purpose to avoid conflicts with clang-toolchain
;;; Skip git package as it should be installed with guix home already
(packages->manifest
  (list
        (specification->package "asciinema")
        (specification->package "clang-with-lld-toolchain")
        (specification->package "cmake")
        (specification->package "cloc")
        (specification->package "curl")
        (specification->package "evince")
        (specification->package "firefox")
        (specification->package "findutils")
        (specification->package "jq")
        (specification->package "gimp")
        (specification->package "graphviz")
        (specification->package "gnuplot")
        (specification->package "guile")
        (specification->package "guile-colorized")
        (specification->package "guile-readline")
        (specification->package "gzip")
        (specification->package "help2man")
        ; (specification->package "hotspot") ;; temporarily remove because it fails to compile on 18.08.2025
        (specification->package "htop")
        (specification->package "imagemagick")
        (specification->package "kcachegrind")
        (specification->package "less")
        (specification->package "libunwind")
        (make-lld-wrapper lld-20)
        (specification->package "moreutils")
        (specification->package "mpv")
        (specification->package "ncdu") ;; Disk usage analyzer
        (specification->package "ninja")
        (specification->package "node")
        (specification->package "patchelf")
        (specification->package "perf")
        (specification->package "perf-tools")
        (specification->package "poetry")
        (specification->package "python")
        (specification->package "python-lsp-server")
        (specification->package "rust-analyzer")
        (specification->package "rust")
        (specification->package "rbw")
        (specification->package "telegram-desktop")
        (specification->package "valgrind")
        (specification->package "wdisplays") ;; arandr replacement, graphical arrangement of multiple screens
        (specification->package "qtwayland") ;; for crisp rendering of kcachegrind, hotspot and other Qt apps
        ; (specification->package "ungoogled-chromium-wayland") ;; temporarily remove because it fails to compile on 19.08.2025
        (specification->package "xdot")))
