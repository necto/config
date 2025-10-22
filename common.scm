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

             (guix packages) ; for home-scripts
             (guix build-system copy)
             ((guix licenses) #:prefix license:)

             (gnu packages admin) ; For btop

             (gnu packages emacs)
             (gnu packages vim)
             (gnu packages certs)
             (gnu packages base)
             (gnu packages version-control)
             (gnu packages rust-apps) ; For ripgrep, bat, git-delta
             (gnu packages fontutils) ; For fontconfig

             (gnu packages guile)
             (gnu packages guile-xyz)
             (gnu packages package-management)

             (gnu packages wm) ; for waybar, kanshi, niri
             (gnu packages xdisorg) ; for gammastep, fuzzel
             (gnu packages xorg) ; for xwayland-satellite
             (gnu packages image) ; for slurp
             (gnu packages terminals) ; for foot, fzf
             (gnu packages pulseaudio) ; for pactl
             (gnu packages freedesktop) ; for xdg-desktop-portal-wlr
             (gnu packages gnome-xyz) ; for bibata-cursor-theme

             (gnu packages nss) ; for nss-certs

             (gnu packages syncthing)

             (gnu packages emacs-xyz) ; for emacs-telega-server
             (azaostro home services)
             )

;; chromium 140.* triggers a bug in wlroots which leads to an annoying Sway crash:
;; sway: render/pass.c:23: wlr_render_pass_add_texture: Assertion `box->x >= 0 && box->y >= 0 && box->x + box->width <= options->texture->width && box->y + box->height <= options->texture->height' failed.
(define wlroots-patched
  (package
   (inherit (@@ (gnu packages wm) wlroots))
   (source
    (origin
     (inherit (package-source (@@ (gnu packages wm) wlroots)))
     (patches
      (list (search-patch "/home/arseniy/tmp/wlroots.patch")))))))

(define sway-patched
  (package
   (inherit (@@ (gnu packages wm) sway))
   (inputs
    (modify-inputs (package-inputs (@@ (gnu packages wm) sway))
                   (replace "wlroots" wlroots-patched)))))


(define %home
  (and=> (getenv "HOME")
         (lambda (home)
           home)))

(define %emacs-config
  (string-append %home "/.config/emacs"))

(define %cursor-theme
  "Bibata-Modern-Ice")

(define %cursor-size
  "24")

(define (glib2-settings-keyfile cursor-size cursor-theme)
  (plain-file
   "glib-2.0-settings"
   (string-append "[org/gnome/desktop/interface]\ncursor-size=" cursor-size "\n"
                  "cursor-theme=\"" cursor-theme "\"\n"
                  "\n"
                  "[org/gtk/settings/file-chooser]\n"
                  "window-position=(26, 23)\n"
                  "window-size=(1231, 902)\n"
                  "date-format='regular'\n"
                  "location-mode='path-bar'\n"
                  "show-hidden=false\n"
                  "show-size-column=true\n"
                  "show-type-column=true\n"
                  "sidebar-width=163\n"
                  "sort-column='name'\n"
                  "sort-directories-first=false\n"
                  "sort-order='ascending'\n"
                  "type-format='category'\n")))

(define home-scripts
  (package
   (name "home-scripts")
   (version "0.1")
   (source (local-file "exe"
                       #:recursive? #t))
   (build-system copy-build-system)
   (arguments
    `(#:install-plan
      '(("slackw.sh" "bin/slackw")
        ("islandw.sh" "bin/islandw")
        ("stdin-to-emacsclient.sh" "bin/stdin-to-emacsclient.sh"))))
   (home-page "https://github.com/necto/config")
   (synopsis "My personal scripts.")
   (description "My personal scripts.")
   (license license:expat)))

(define %guix-config-dir
  (dirname (current-filename)))

(define bash-profile-file
  (plain-file
   "bash-profile"
   (string-append
    "\n" ;; ssh agent daemon
    "eval \"$(ssh-agent -s)\"\n")))

(define (home-env %custom-dir %extra-path)
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
                           eza ;; Alternative to `ls`

                           niri ;; scrolling tiling wayland compositor
                           sway-patched
                           swaybg
                           swayidle ; lock and suspend on inactivity or lid close
                           waybar
                           kanshi ;; dynamic display configuration
                           ;; swaylock -- can't install as a user, it doesn't collaborate with pam_authenticate
                           gammastep ;; control screen color temperature according to time of the day
                           grimshot ;; take screenshots
                           slurp ;; select area for a screenshot
                           foot ;; sway default terminal emulator
                           fzf ;; command-line fuzzy finder
                           fuzzel ;; keyboard-centered app launcher
                           xwayland-satellite ;; needed for X11 apps to run in niri/wayland
                           pulseaudio ;; for pactl
                           pavucontrol
                           dunst ;; display notifications
                           xdg-desktop-portal-wlr ;; for screencast (screen sharing)

                           syncthing

                           emacs-telega-server ;; telegram client for emacs, server part. emacs-telega is installed by doom emacs

                           home-scripts

                           bat ;; cat with wings (syntax highlighting)
                           git-delta ;; git diff viewer
                           btop ;; beautiful and versatile resource monitor

                           bibata-cursor-theme ;; this is where apps will look for cursor themes
                           )
                     (specifications->packages (list)) ; in case I don't know which package to import,
                                        ; use a string here e.g. "emacs"
                     ))

   ;; Below is the list of Home services.  To search for available
   ;; services, run 'guix home search KEYWORD' in a terminal.
   (services
    (list (service home-bash-service-type
                   (home-bash-configuration
                    (aliases '(("ls" . "eza")
                               ("rehash" . "hash -r")
                               ("vi" . "vim")
                               ("python" . "python3")
                               ("suspend" . "systemctl -i suspend")
                               ("cat" . "bat")
                               ("e" . "emacsclient -a vim -n")))
                    (bashrc (list (local-file ".bashrc"
                                              "bashrc")
                                  (local-file "fzf.key-bindings.bash"
                                              "fzf.key-bindings.bash")))
                    (bash-profile (list bash-profile-file))
                    (bash-logout (list (local-file
                                        ".bash_logout"
                                        "bash_logout")))))

          (simple-service 'mimeapps
                          home-xdg-configuration-files-service-type
                          (list `("mimeapps.list"
                                  ,(local-file (string-append %guix-config-dir "/" %custom-dir "/mimeapps.list")))))

          (simple-service 'clangd-config
                          home-xdg-configuration-files-service-type
                          (list `("clangd/config.yaml"
                                  ,(local-file (string-append %guix-config-dir "/" %custom-dir "/clangd/config.yaml")))))

          (simple-service 'bash-timer
                          home-xdg-configuration-files-service-type
                          (list `("bash-command-timer.sh"
                                  ,(local-file "bash-command-timer.sh"))))

          (simple-service 'cmake-presets
                          home-xdg-configuration-files-service-type
                          (list `("CMakeUserPresetsGlobal.json"
                                  ,(local-file "CMakeUserPresetsGlobal.json"))))

          (simple-service 'cursor-config
                          home-xdg-configuration-files-service-type
                          (list `("gtk-2.0/gtkrc" ,(plain-file "gtkrc" (string-append "gtk-cursor-theme-size=" %cursor-size "\ngtk-cursor-theme-name=\"" %cursor-theme "\"\n")))
                                `("gtk-3.0/settings.ini" ,(plain-file "gtk3-settings.ini" (string-append "[Settings]\ngtk-cursor-theme-size=" %cursor-size "\ngtk-cursor-theme-name=\"" %cursor-theme "\"\n")))
                                `("settings.ini" ,(plain-file "settings.ini" (string-append "gtk-cursor-theme-size=" %cursor-size "\ngtk-cursor-theme-name=\"" %cursor-theme "\"\n")))
                                `("shell/profile" ,(plain-file "shell-profile" (string-append "export XCURSOR_SIZE=\"" %cursor-size "\"\nexport XCURSOR_THEME=\"" %cursor-theme "\"\n")))
                                `("x11/xresources" ,(plain-file "Xresources" (string-append "Xcursor.size:" %cursor-size "\nXcursor.theme: " %cursor-theme "\n")))
                                `("glib-2.0/settings/keyfile" ,(glib2-settings-keyfile %cursor-size %cursor-theme))
                                `("sway/cursor.theme" ,(plain-file "sway-cursor-theme" (string-append "set $cursor_size " %cursor-size "\nset $cursor_theme " %cursor-theme "\n")))
                                ;; TODO: when niri 25.09 is available, include cursor config from a generated file:
                                ;; `("niri/cursor.theme" ,(plain-file "niri-cursor-theme" (string-append "cursor {"
                                ;;                                                                       "\n    xcursor-size " %cursor-size
                                ;;                                                                       "\n    xcursor-theme \"" %cursor-theme "\""
                                ;;                                                                       "\n}\n")))
                                ))

          (simple-service 'git-config
                          home-xdg-configuration-files-service-type
                          (list `("git/config" ,(local-file "gitconfig"))))

          (simple-service 'fuzzel-config
                          home-xdg-configuration-files-service-type
                          (list `("fuzzel/fuzzel.ini" ,(local-file "fuzzel/fuzzel.ini"))))

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
                          (list `("sway/config" ,(local-file "sway/config"))
                                `("sway/kanshi.config"
                                  ,(local-file (string-append %guix-config-dir "/" %custom-dir "/kanshi.config")))
                                `("sway/resources" ,(local-file "sway/resources" #:recursive? #t))))

          (simple-service 'niri-config
                          home-xdg-configuration-files-service-type
                          (list `("niri/config.kdl" ,(local-file "niri/config.kdl"))))

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

          ;; Used by doom emacs and waybar icons
          (simple-service 'nerd-fonts
                          home-xdg-data-files-service-type
                          (list `("fonts/NFM.ttf" ,(local-file "fonts/NFM.3.2.1.ttf"))))

          ;; Installing doom-emacs will be done by the .config/doom/install.sh after
          ;; home reconfigure.
          ;; It can not be part of it because it takes long time, and can't be cached
          ;; - it must be done in the user home directory (probably).
          ;; So after guix home reconfigure, you should invoke the produced install.sh script
          (simple-service 'doom-install-script
                          home-xdg-configuration-files-service-type
                          (list `("doom-install.sh"
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

          (simple-service 'doom-config
                          home-direct-symlink-service-type
                          (path-to-local "doom"))

          (simple-service
           'env-vars
           home-environment-variables-service-type
           `(("PATH" . ,(string-join (append %extra-path '("$PATH")) ":"))
             ;; Fix the warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8)
             ("GUIX_LOCPATH" . "$HOME/.guix-profile/lib/locale:$HOME/.guix-home/profile/lib/locale")
             ;; Make sure apps can find the ca-certificates installed by nss-certs
             ;; For some reason these variables need to be exported explicitly and
             ;; it is not done automatically upon installing nss-scripts
             ("SSL_CERT_DIR" . ,(string-append %home "/.guix-home/profile/etc/ssl/certs"))
             ("SSL_CERT_FILE" . ,(string-append %home "/.guix-home/profile/etc/ssl/certs/ca-certificates.crt"))))))))
