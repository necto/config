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

(define (package-with-configure-flags p flags)
  "Return P with FLAGS as additional 'configure' flags."
  (package/inherit p
    (arguments
     (substitute-keyword-arguments (package-arguments p)
       ((#:configure-flags original-flags #~(list))
        #~(append #$original-flags #$flags))))))

;;; Use LLD as the default linker instead of BFD used by clang-18.
;;; LLD has the advantage of being insensitive to the order in which
;;; it has libraries listed, which is useful when compiling our work project
;;; since it injects the home-built standard library to the CMAKE_CXX_FLAGS
;;; which is expanded in the beginning of a compiler invocation.
;;; Hold off on using clang-19 as it is not yet supported by the work project z3
;;; contains a bug in template code that breaks clang-19 compilation.
(define clang-with-lld-18
  (package
    (inherit (package-with-configure-flags clang-18 #~(list "-DCLANG_DEFAULT_LINKER=lld")))
    (inputs (modify-inputs (package-inputs clang-18) (replace "gcc" "gcc-13")))
    (name "clang-with-lld")))

(define clang-toolchain-with-lld-18
  (make-clang-toolchain clang-with-lld-18 libomp-18))

;;; Not installing gcc-toolchain on purpose to avoid conflicts with clang-toolchain
;;; Skip git package as it should be installed with guix home already
(packages->manifest
  (list
        (specification->package "asciinema")
        clang-toolchain-with-lld-18
        (specification->package "cmake")
        (specification->package "cloc")
        (specification->package "curl")
        (specification->package "evince")
        (specification->package "firefox")
        (specification->package "findutils")
        (specification->package "fzf")
        (specification->package "jq")
        (specification->package "gimp")
        (specification->package "graphviz")
        (specification->package "gnuplot")
        (specification->package "guile")
        (specification->package "guile-colorized")
        (specification->package "guile-readline")
        (specification->package "gzip")
        (specification->package "help2man")
        (specification->package "hotspot")
        (specification->package "htop")
        (specification->package "imagemagick")
        (specification->package "kcachegrind")
        (specification->package "less")
        (specification->package "libunwind")
        (make-lld-wrapper lld-18)
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
        (specification->package "telegram-desktop")
        (specification->package "valgrind")
        (specification->package "wdisplays") ;; arandr replacement, graphical arrangement of multiple screens
        (specification->package "qtwayland") ;; for crisp rendering of kcachegrind, hotspot and other Qt apps
        (specification->package "ungoogled-chromium-wayland")
        (specification->package "xdot")))
