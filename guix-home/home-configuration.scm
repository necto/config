;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
             (gnu packages)
             (gnu services)
             (guix gexp)
             (gnu home services shells)
             (gnu home services))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
  (packages (specifications->packages (list "virt-manager" "virt-viewer" "sed" "grep" "which" "vim")))

  ;; Below is the list of Home services.  To search for available
  ;; services, run 'guix home search KEYWORD' in a terminal.
  (services
   (list (service home-bash-service-type
                  (home-bash-configuration
                   (aliases '(("grep" . "grep --color=auto")
                              ("ls" . "ls --color=auto")
                              ("rehash" . "hash -r")
                              ("suspend" . "systemctl -i suspend")))
                   (bashrc (list (local-file "/home/arseniy/guix-home/.bashrc"
                                  "bashrc")))
                   (bash-logout (list (local-file
                                       "/home/arseniy/guix-home/.bash_logout"
                                       "bash_logout")))))
         (simple-service 'bash-timer
                         home-xdg-configuration-files-service-type
                         (list `("bash-command-timer.sh" ,(local-file
                                             "/home/arseniy/guix-home/bash-command-timer.sh"
                                             "bash-command-timer.sh")))))))
