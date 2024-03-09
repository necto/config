;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
             (gnu packages)
             (gnu services)
             (guix git)
             (guix gexp)
             (gnu home services shells)
             (gnu home services)

             (gnu packages emacs)
             (gnu packages vim)
             (gnu packages certs)
             (gnu packages version-control)
             (gnu packages base)

             ;; experimenting for doom emacs
             (guix packages)
             (guix git-download) ; for git-fetch method
             (guix build-system trivial) ; for trivial-build-system
             ((guix licenses) #:prefix license:)
             )

(define %home
  (and=> (getenv "HOME")
         (lambda (home)
           home)))

(define %emacs-config
  (string-append %home "/.config/emacs"))

;; (define doom-emacs
;;   (package
;;     (name "doom-emacs")
;;     (version "d657be1744a1481dc4646d0b62d5ee1d3e75d1d8")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/doomemacs/doomemacs")
;;              (commit version)))
;;        (sha256
;;         (base32
;;          "0clnfr5l386bn1mdli0nj8w2fjsgvzs49nw0ishpljm3jgznsvyw"))))
;;     (build-system trivial-build-system)
;;     (inputs (list emacs))
;;     (description "Prebuilt .config/emacs directory for doom emacs.
;;                   Requires copying to ~/.config/emacs to be used")
;;     (synopsis "Doom Emacs")
;;     (license license:gpl3+) ;; TODO make more permissive
;;     (home-page "localhost")
;;     (arguments
;;      (list
;;       #:modules `((guix build utils))
;;       #:builder
;;       #~(begin
;;           (use-modules (guix build utils))
;;           (format #t "=-=-=-=-=- =-=-=-=-=-=- -==-=-=- =-=-=-=-=- Hello!\n")
;;           (format #t "reflection: ~a\n" (module-uses (current-module)))
;;           (format #t "reflection: my sdir is ~a\n" (getcwd))
;;           ;; (chdir "/")
;;           ;; (format #t "reflection: files in /:  ~a\n" (ls-command))
;;           ;; (copy-recursively (assoc-ref %build-inputs "source") %output)
;;           (mkdir-p #$%emacs-config)
;;           (copy-recursively (assoc-ref %build-inputs "source") #$%emacs-config)
;;           (copy-recursively #$%emacs-config #$output)
;;           ;;   (copy-recursively (assoc-ref %build-inputs "source") %emacs-config)

;;           )))))

;; (define %doom-emacs
;;   (git-checkout
;;    (url "https://github.com/doomemacs/doomemacs ~/.config/emacs")
;;    (commit "98d753e1036f76551ccaa61f5c810782cda3b48a")))

;; (define %doom-bin
;;   (file-append %doom-emacs "/bin/doom"))
;;
;; maybe home-activation-service-type can run the checkout and install

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
  (packages (append (list emacs
                          vim
                          nss-certs ;; HTTPS sertificates for git and other CLI tools
                          git
                          binutils ;; used by `doom install`
                          sed
                          grep
                          ;doom-emacs
                          )
                    (specifications->packages (list)) ; in case I don't know which package to import,
                                                      ; use a string here e.g. "emacs"
                    ))

  ;; Then do:
  ;; git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  ;; bash ~/.config/emacs/bin/doom install

  ;; Below is the list of Home services.  To search for available
  ;; services, run 'guix home search KEYWORD' in a terminal.
  (services
   (list (service home-bash-service-type
                  (home-bash-configuration
                   (aliases '(("grep" . "grep --color=auto")
                              ("ls" . "ls --color=auto")
                              ("rehash" . "hash -r")
                              ("suspend" . "systemctl -i suspend")))
                   (bashrc (list (local-file ".bashrc"
                                  "bashrc")))
                   (bash-logout (list (local-file
                                       ".bash_logout"
                                       "bash_logout")))))
         (simple-service 'bash-timer
                         home-xdg-configuration-files-service-type
                         (list `("bash-command-timer.sh"
                                 ,(local-file
                                   "bash-command-timer.sh"
                                   "bash-command-timer.sh"))))
         (simple-service 'doom-checkout
                         home-activation-service-type
                         (with-imported-modules '((guix build utils))
                           #~(begin
                               (use-modules (guix build utils))
                               ; This one works:
                               ;; (system (string-append
                               ;;          "GIT_SSL_CAINFO=$HOME/.guix-home/profile/etc/ssl/certs/ca-certificates.crt "
                               ;;          #$(file-append git "/bin/git")
                               ;;          " clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs"))

                               ; This one works too
                               ;; (system* "cp" "-r" #$(git-checkout (url "https://github.com/doomemacs/doomemacs"))
                               ;;          #$(string-append %home "/.config/emacs"))

                               (mkdir-p #$%emacs-config)
                               (copy-recursively #$(git-checkout (url "https://github.com/doomemacs/doomemacs"))
                                                 #$%emacs-config
                                                 #:log #f)
                               (system (string-append "echo $'\\n\\n' Don\\'t forget to run bash "
                                                      #$%emacs-config "/bin/doom install $'\\n\\n'"))))))))
