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
             (gnu packages base)
             (gnu packages version-control)
             (gnu packages rust-apps) ; For ripgrep
             (gnu packages fontutils) ; For fontconfig

             ; python
             (gnu packages python)
             (gnu packages python-xyz) ; for poetry
             (gnu packages check) ; for pytest

             ; C++
             (gnu packages llvm)
             (gnu packages cmake)
             )

(define %home
  (and=> (getenv "HOME")
         (lambda (home)
           home)))

(define %emacs-config
  (string-append %home "/.config/emacs"))

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
                          ripgrep ;; used by doom emacs
                          fd ;; used by doom emacs
                          which
                          fontconfig ;; used by doom doctor

                          python
                          poetry
                          python-language-server
                          python-isort
                          python-pytest
                          python-nose

                          clang-17 ; Includes tools such as clangd, clang-format, clang-tidy
                          cmake
                          python-lit
                          )
                    (specifications->packages (list)) ; in case I don't know which package to import,
                                                      ; use a string here e.g. "emacs"
                    ))

  ;; Below is the list of Home services.  To search for available
  ;; services, run 'guix home search KEYWORD' in a terminal.
  (services
   (list (service home-bash-service-type
                  (home-bash-configuration
                   (aliases '(("grep" . "grep --color=auto")
                              ("ls" . "ls --color=auto")
                              ("rehash" . "hash -r")
                              ("vi" . "vim")
                              ("python" . "python3")
                              ("suspend" . "systemctl -i suspend")))
                   (bashrc (list (local-file ".bashrc"
                                  "bashrc")))
                   (bash-logout (list (local-file
                                       ".bash_logout"
                                       "bash_logout")))))
         (simple-service 'bash-timer
                         home-xdg-configuration-files-service-type
                         (list `("bash-command-timer.sh"
                                 ,(local-file "bash-command-timer.sh"))))
         (simple-service 'doom-config
                         home-xdg-configuration-files-service-type
                         (list `("doom/init.el" ,(local-file "doom/init.el"))
                               `("doom/config.el" ,(local-file "doom/config.el"))
                               `("doom/packages.el" ,(local-file "doom/packages.el"))
                               `("doom/custom.el" ,(local-file "doom/custom.el"))))
         (simple-service 'doom-checkout
                         home-activation-service-type
                         (with-imported-modules '((guix build utils))
                           #~(begin
                               (use-modules (guix build utils))
                               (mkdir-p #$%emacs-config)
                               (copy-recursively #$(git-checkout (url "https://github.com/doomemacs/doomemacs"))
                                                 #$%emacs-config
                                                 #:log #f)
                               (substitute* (string-append #$%emacs-config "/bin/doom")
                                 (("/usr/bin/env sh")
                                  #$(string-append %home "/.guix-home/profile/bin/bash")))
                               (system (string-append "echo $'\\n\\n'Don\\'t forget to run:$'\\n'"
                                                      #$%emacs-config "/bin/doom env $'\\n'"
                                                      #$%emacs-config "/bin/doom install $'\\n\\n'"))))))))
