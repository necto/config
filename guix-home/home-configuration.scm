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

             (gnu packages guile)
             (gnu packages guile-xyz)
             (gnu packages package-management)

             (gnu packages wm) ; for waybar
             (gnu packages xdisorg) ; for gammastep
             (gnu packages image) ; for slurp
             (gnu packages terminals) ; for foot
             (gnu packages suckless) ; for dmenu
             (gnu packages pulseaudio) ; for pactl
             (gnu packages freedesktop) ; for xdg-desktop-portal-wlr

             (gnu packages syncthing)
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
  (packages (append (list emacs-pgtk ;; pgtk enables smooth rendering in wayland
                          vim
                          nss-certs ;; HTTPS sertificates for git and other CLI tools
                          glibc-locales ;; Fix the warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8)
                          git
                          binutils ;; used by `doom install`
                          sed
                          grep
                          ripgrep ;; used by doom emacs
                          fd ;; used by doom emacs
                          which
                          fontconfig ;; used by doom doctor
                          ;; guix -- must be already installed (avoid circular dep)

                          sway
                          swaybg
                          swayidle ; lock and suspend on inactivity or lid close
                          waybar
                          ;; swaylock -- can't install as a user, it doesn't collaborate with pam_authenticate
                          gammastep ;; control screen color temperature according to time of the day
                          grimshot ;; take screenshots
                          slurp ;; select area for a screenshot
                          foot ;; sway default terminal emulator
                          dmenu ;; keyboard-centered app launcher
                          pulseaudio ;; for pactl
                          pavucontrol
                          dunst ;; display notifications
                          xdg-desktop-portal-wlr ;; for screencast (screen sharing)

                          syncthing
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
                   (bash-profile (list (plain-file
                                        "bash-profile"
                                        (string-append
                                         "\n" ;; Use guix as the package manager
                                         "GUIX_PROFILE=\"" %home "/.guix-profile\"\n"
                                         "source \"$GUIX_PROFILE/etc/profile\" \n"
                                         "\n" ;; ssh agent daemon
                                         "eval \"$(ssh-agent -s)\"\n"))))
                   (bash-logout (list (local-file
                                       ".bash_logout"
                                       "bash_logout")))))
         (simple-service 'bash-timer
                         home-xdg-configuration-files-service-type
                         (list `("bash-command-timer.sh"
                                 ,(local-file "bash-command-timer.sh"))))

         (simple-service 'git-config
                         home-xdg-configuration-files-service-type
                         (list `("git/config" ,(local-file "gitconfig"))))

         (simple-service 'xmonad-config
                         home-xdg-configuration-files-service-type
                         ;; FIXME: xmonad expects the config dir to be writable
                         ;; to be able to compile itself there. this links the
                         ;; .config/xmonad to /gnu/store read-only, so it fails when
                         ;; starting xmonad.
                         ;; The problem is fixed in a later xmonad version (0.17)
                         (list `("xmonad" ,(local-file "xmonad" #:recursive? #t))))

         (simple-service 'guile-config
                         home-files-service-type
                         ;; Guile seems to not support XDG_CONFIG stuff
                         (list `(".guile" ,(local-file "guile.scm"))))

         (simple-service 'ssh-config
                         home-files-service-type
                         ;; open_ssh does not support XDG_CONFIG directory
                         (list `(".ssh/config" ,(local-file "ssh/config"))))

         (simple-service 'waybar-config
                         home-xdg-configuration-files-service-type
                         (list `("waybar" ,(local-file "waybar" #:recursive? #t))))

         (simple-service 'sway-config
                         home-xdg-configuration-files-service-type
                         (list `("sway" ,(local-file "sway" #:recursive? #t))))

         (simple-service 'foot-config
                         home-xdg-configuration-files-service-type
                         (list `("foot" ,(local-file "foot" #:recursive? #t))))

         (simple-service 'gammastep-config
                         home-xdg-configuration-files-service-type
                         (list `("gammastep" ,(local-file "gammastep" #:recursive? #t))))

         ;; Use xdg-desktop-portal-wlr for screencast (screen sharing)
         (simple-service 'desktop-portal-wlr-config
                         home-xdg-configuration-files-service-type
                         (list `("xdg-desktop-portal" ,(local-file "xdg-desktop-portal" #:recursive? #t))
                               `("xdg-desktop-portal-wlr" ,(local-file "xdg-desktop-portal-wlr" #:recursive? #t))
                               `("xdg-desktop-portal-wlr-install.sh"
                                 ,(mixed-text-file
                                   "xdg-desktop-portal-wlr-install.sh"
                                      "#!" %home "/.guix-home/profile/bin/bash\n"
                                      "set -xeuo pipefail\n"
                                      "sudo cp " (file-append xdg-desktop-portal-wlr "/share/dbus-1/services/org.freedesktop.impl.portal.desktop.wlr.service") " /usr/share/dbus-1/services/org.freedesktop.impl.portal.desktop.wlr.service\n"
                                      "sudo cp " (file-append xdg-desktop-portal-wlr "/share/xdg-desktop-portal/portals/wlr.portal") " /usr/share/xdg-desktop-portal/portals/wlr.portal\n"
                                      ))))

         (simple-service 'guix-config
                         home-xdg-configuration-files-service-type
                         (list `("guix/channels.scm" ,(local-file "guix/channels.scm"))))

         ;; Used by doom emacs and waybar icons
         (simple-service 'nerd-fonts
                         home-xdg-data-files-service-type
                         (list `("fonts/NFM.ttf" ,(local-file "fonts/NFM.ttf"))))

         ;; Installing doom-emacs will be done by the .config/doom/install.sh after
         ;; home reconfigure.
         ;; It can not be part of it because it takes long time, and can't be cached
         ;; - it must be done in the user home directory (probably).
         ;; So after guix home reconfigure, you should invoke the produced install.sh script
         (simple-service 'doom-config
                         home-xdg-configuration-files-service-type
                         (list `("doom/init.el" ,(local-file "doom/init.el"))
                               `("doom/config.el" ,(local-file "doom/config.el"))
                               `("doom/packages.el" ,(local-file "doom/packages.el"))
                               `("doom/custom.el" ,(local-file "doom/custom.el"))
                               `("doom/install.sh"
                                 ,(plain-file
                                   "doom-install.sh"
                                   (string-append
                                    "#!" (string-append %home "/.guix-home/profile/bin/bash") "\n"
                                    "set -xeuo pipefail\n"
                                    "git clone https://github.com/doomemacs/doomemacs " %emacs-config "\n"
                                    %emacs-config "/bin/doom env\n"
                                    %emacs-config "/bin/doom install\n"
                                    %emacs-config "/bin/doom sync\n"
                                    %emacs-config "/bin/doom doctor\n")))))

         (simple-service
          'env-vars
          home-environment-variables-service-type
          `(;; Fix the warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8)
            ("GUIX_LOCPATH" . "$HOME/.guix-profile/lib/locale:$HOME/.guix-home/profile/lib/locale"))))))
