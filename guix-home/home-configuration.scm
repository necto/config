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

             ;; experimenting for doom emacs
             (gnu packages base)
             (gnu packages version-control)
             )

(define %home
  (and=> (getenv "HOME")
         (lambda (home)
           home)))

(define %emacs-config
  (string-append %home "/.config/emacs"))

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
