;; This "manifest" file can be passed to 'guix package -m' to reproduce
;; the content of your profile.  This is "symbolic": it only specifies
;; package names.  To reproduce the exact same profile, you also need to
;; capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (guix packages)
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
(define clang-with-lld
  (package
    (inherit (package-with-configure-flags clang-18 #~(list "-DCLANG_DEFAULT_LINKER=lld")))
    (name "clang-with-lld")))

(concatenate-manifests
 (list (specifications->manifest
        (list "telegram-desktop"
              "node"
              "firefox"
              "lld-wrapper"
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
       (packages->manifest
        (list clang-with-lld))))
