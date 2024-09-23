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
        (specification->package "firefox")
        (specification->package "fzf")
        (specification->package "gimp")
        (specification->package "gnuplot")
        (specification->package "guile")
        (specification->package "guile-colorized")
        (specification->package "guile-readline")
        (specification->package "hotspot")
        (specification->package "htop")
        (specification->package "kcachegrind")
        (specification->package "libunwind")
        (make-lld-wrapper lld-18)
        (specification->package "moreutils")
        (specification->package "ncdu") ;; Disk usage analyzer
        (specification->package "ninja")
        (specification->package "node")
        (specification->package "patchelf")
        (specification->package "perf")
        (specification->package "perf-tools")
        (specification->package "poetry")
        (specification->package "python")
        (specification->package "python-lsp-server")
        (specification->package "telegram-desktop")))
