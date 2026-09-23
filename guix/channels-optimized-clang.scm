;; Frozen channel state for `install-optimized-clang'.
;;
;; optimized-clang-with-lld-toolchain takes hours to build (PGO + ThinLTO +
;; -march=native, no substitutes possible).  It therefore lives in its
;; own profile, outside ~/config/manifest.scm, so that `guix pull && guix
;; upgrade' never re-derives it.  This file pins the channels used to build
;; it, so that a reinstall resolves to the byte-identical derivation that is
;; already in the store instead of starting a fresh multi-hour build.
;;
;; Only bump these commits when you actually intend to rebuild the toolchain.
;; Regenerate from the current state with:
;;
;;   guix describe -f channels > ~/config/guix/channels-optimized-clang.scm
;;
;; guix and nonguix are at the commits current as of 2026-09-23;
;; guix-azaostro is at dc18378 ("Add optimized-clang-toolchain-with-lld"),
;; which is one commit ahead of what `guix describe' reported, because the
;; package definition was pushed after the last `guix pull'.

(list (channel
       (name 'guix-azaostro)
       (url "https://github.com/necto/guix-azaostro")
       (branch "main")
       (commit "491ba3aa4949d1471d8d4875827f42f53a86104c"))
      (channel
       (name 'nonguix)
       (url "https://gitlab.com/nonguix/nonguix")
       (branch "master")
       (commit "f9171dd0d0a58d63c0811d61e51493a3fa4ae4f3")
       (introduction
        (make-channel-introduction
         "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
         (openpgp-fingerprint
          "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
      (channel
       (name 'guix)
       (url "https://codeberg.org/guix/guix.git")
       (branch "master")
       (commit "90d978cb9a60a3ea5bf676c9637ae2f718304a31")
       (introduction
        (make-channel-introduction
         "9edb3f66fd807b096b48283debdcddccfea34bad"
         (openpgp-fingerprint
          "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))))
