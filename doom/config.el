;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

;; for dark mode
;;(setq doom-theme 'doom-solarized-dark-high-contrast)

;; for light mode
;;(setq doom-theme 'dichromacy)
;(custom-set-faces! `(default :background ,"#F7EDD3"))
;(setq doom-theme 'tsdh-light)
;(setq doom-theme 'doom-solarized-light)

(setq doom-font (font-spec :size 12 :family "Ubuntu Mono"))

(setq doom-theme 'spacemacs-light)

(custom-set-faces!
  '(doom-dashboard-banner :inherit default)
  '(doom-dashboard-loaded :inherit default))

;(custom-set-faces! `(font-lock-comment-face :foreground ,(doom-darken (doom-color 'red) 0.2)))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type nil)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq which-key-idle-delay 0.3)
(setq doom-localleader-key (kbd ",")
      doom-localleader-alt-key (kbd "M-,"))

(setq default-input-method "russian-computer")

(setq-default js-indent-level 2)
(setq-default typescript-indent-level 2)
(add-load-path! "~/proj/languages-experimental-tooling/personal/arseniy-zaostrovnykh/elisp/")

(setq lsp-clients-clangd-args '("-j=8"
                                "--background-index"
                                "--clang-tidy"
                                "--completion-style=detailed"))

;; Enable strict code formatter
(setq lsp-pylsp-plugins-black-enabled t)
(setq lsp-pylsp-plugins-flake8-max-line-length 88) ;; for compatibility with black

(after! lsp-clangd (set-lsp-priority! 'clangd 2)
  (setq lsp-headerline-breadcrumb-enable t))

(map! :leader :desc "Lisp eval any expression" ":" #'pp-eval-expression)
(map! :leader :desc "Choose an interactive command" ";" #'execute-extended-command)
(map! :leader :desc "Switch to the previously shown buffer" "TAB" #'mode-line-other-buffer)
(map! :leader :desc "Switch to the previously shown buffer" "<tab>" #'mode-line-other-buffer)

(defun my-org-capture-cleanup ()
  "Clean up the frame created while capturing via org-protocol."
  (-when-let ((&alist 'name name) (frame-parameters))
    (when (equal name "org-protocol-capture")
      (delete-frame))))

(defun my-org-agenda-cached ()
  (let ((buffer (get-buffer "*Org Agenda*")))
    (if buffer
        (switch-to-buffer buffer)
      (org-agenda-list))))

(after! org
  (setq org-agenda-files '("~/notes/gtd/general.org"
                           "~/notes/gtd/inbox.org"
                           "~/notes/gtd/projects.org"
                           "~/notes/gtd/tickler.org")
        org-capture-templates
        '(("n" "Add a note" entry
           (file "~/notes/gtd/inbox.org")
           "* %?
  OPEN: %U" :jump-to-captured t :empty-lines 1)
          ("t" "Add a todo item" entry
           (file "~/notes/gtd/inbox.org")
           "* TODO [#B] %?
  OPEN: %U" :jump-to-captured t :empty-lines 1))
        org-refile-targets
        '(("~/notes/gtd/projects.org" :maxlevel . 2)
          ("~/notes/gtd/someday.org" :level . 1)
          ("~/notes/gtd/tickler.org" :maxlevel . 2))
        org-todo-keywords
        '((sequence "TODO(t)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
  (setq org-log-done t
        org-log-into-drawer t)
  (add-hook 'org-capture-after-finalize-hook 'my-org-capture-cleanup)
  (setq org-agenda-custom-commands
        '(("c" . "My Custom Agendas")
          ("cu" "Unscheduled TODO"
           ((todo ""
                  ((org-agenda-overriding-header "\nUnscheduled TODO")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'timestamp)))))
           nil
           nil))))


(setq c-basic-offset 2
      js-indent-level 2)

(setq auto-save-default t
      make-backup-files t)

(after! lit
  (map! :leader :desc "Delete lit-tester spec comment" :mode lit-mode "l d" #'lit-delete-spec)
  (map! :leader :desc "Insert issue spec comments" :mode lit-mode "l i" #'lit-insert-issues)
  (map! :leader :desc "Run current lit test" :mode lit-mode "l r" #'lit-run-tester)
  (map! :leader :desc "Insert issues from last run" :mode lit-mode "l e" #'lit-insert-issues-from-run))

(map! :mode (cpp-mode c-mode c++-mode) "C-l" #'recenter-top-bottom)

(after! magit
  (setq git-commit-summary-max-length 72))

(after! lsp-mode
  (setq lsp-headerline-breadcrumb-enable t)
  (setq lsp-headerline-breadcrumb-segments '(symbols))
  (setq lsp-log-io nil)
  ;; Build output is never worth a file watcher.
  (dolist (re '("[/\\\\]build\\'" "[/\\\\]llvm-project\\'"
                "[/\\\\]toolchain\\'" "[/\\\\]its\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories re)))

;; The per-repo lsp settings (disabled file watchers in the huge trees, jdtls
;; import tuning for sonar-cpp) live in untracked `.dir-locals.el' files in the
;; repos themselves; `.dir-locals.el' is in ~/.config/git/ignore and
;; ~/config/exe/spawn-worktree copies it into new worktrees.  Only the safety
;; marks have to be here: `hack-local-variables-filter' would otherwise prompt
;; on every visit.  lsp-mode marks `lsp-enable-file-watchers' itself; lsp-java
;; marks nothing.  `lsp-java-vmargs' is `:risky t' and can never be set from a
;; dir-local, hence the global `setq' below.
(put 'lsp-java-import-gradle-enabled 'safe-local-variable #'booleanp)
(put 'lsp-java-import-exclusions 'safe-local-variable #'vectorp)
(put 'lsp-java-project-resource-filters 'safe-local-variable #'vectorp)

(after! lsp-java
  ;; The 1G default heap is not enough for any non-toy workspace, and autobuild
  ;; rebuilds the whole project on every save.
  (setq lsp-java-vmargs '("-XX:+UseParallelGC" "-XX:GCTimeRatio=4"
                          "-XX:AdaptiveSizePolicyWeight=90"
                          "-Dsun.zip.disableMemoryMapping=true"
                          "-Xmx4G" "-Xms512m")
        lsp-java-autobuild-enabled nil))

(defun my/lsp-prune-stale-session-folders ()
  "Drop workspace folders and blocklist entries that no longer exist on disk.
Stale roots make `lsp--server-register-capability' fail with `file-missing'
while registering the file watchers, which aborts processing of that message."
  (interactive)
  (require 'lsp-mode)
  (let* ((session (lsp-session))
         (folders (-filter #'file-directory-p (lsp-session-folders session)))
         (blocklist (-uniq (-filter #'file-directory-p
                                    (lsp-session-folders-blocklist session)))))
    ;; `lsp-session' is a cl-defstruct, so `setf' on its accessors is a
    ;; macro expansion, not a function call -- and lsp-mode is not loaded when
    ;; this file is read, so a literal `setf' here expands into a call to the
    ;; non-existent function `(setf lsp-session-folders)'.  Expand at run time.
    (eval `(setf (lsp-session-folders ',session) ',folders
                 (lsp-session-folders-blocklist ',session) ',blocklist)
          t)
    ;; The `folders' list is not where the dead roots hurt: a workspace's roots
    ;; come from `folder->servers' (`lsp-find-roots-for-workspace'), which is
    ;; rebuilt on every start from the persisted `server-id->folders'.  Clean
    ;; both, or ~/proj/sonar-cpp-master keeps coming back.
    (let ((id->folders (lsp-session-server-id->folders session)))
      (ht-aeach (puthash key (-filter #'file-directory-p value) id->folders)
                id->folders))
    (let ((folder->servers (lsp-session-folder->servers session)))
      (dolist (folder (ht-keys folder->servers))
        (unless (file-directory-p folder)
          (remhash folder folder->servers))))
    (lsp--persist-session session)
    (when (called-interactively-p 'interactive)
      (message "lsp session: %d folders, %d blocklisted"
               (length folders) (length blocklist)))))

(defun my/lsp-root-watchable-p (dir)
  "Return non-nil if DIR should get lsp-mode file watchers.
`lsp--server-register-capability' tests the *global* value of
`lsp-enable-file-watchers': it runs while handling a server message, not in a
project buffer, so the nil in a repo's .dir-locals.el never reaches it.  Read
it at DIR the way lsp-mode reads its own ignore lists, and treat a root that
no longer exists as unwatchable -- `directory-files' on it would otherwise
escape and abort processing of the whole LSP message."
  (and (file-directory-p dir)
       (with-temp-buffer
         (setq-local buffer-file-name (expand-file-name "lsp-mode-temp" dir))
         (hack-local-variables)
         lsp-enable-file-watchers)))

(define-advice lsp-watch-root-folder
    (:around (fn dir &rest args) my/honour-dir-locals)
  "Skip watching roots that are gone or that opted out via .dir-locals.el."
  (if (my/lsp-root-watchable-p dir)
      (apply fn dir args)
    (lsp-log "Not watching %s: missing, or disabled by dir-locals" dir)
    (or (nth 3 args) (make-lsp-watch :root-directory dir))))

;; Can be kept clean like this:
;; Probably not worth risking having another hook, it grows slowly and the
;; dangling sessions aren't too expensive.
;; (add-hook 'lsp-before-initialize-hook #'my/lsp-prune-stale-session-folders)

(after! lsp-sonarlint
  (setq lsp-sonarlint-auto-download t
        lsp-sonarlint-show-analyzer-logs t
        lsp-sonarlint-verbose-logs t))

;; To display line numbers on the side:
;; M-x linum-mode

; add google-translate package?

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)
              ("C-n" . 'copilot-next-completion)
              ("C-p" . 'copilot-previous-completion))

  :config
  (add-to-list 'copilot-indentation-alist '(prog-mode 2))
  ; emacs-lisp-mode is already present in copilot-indentation-alist,
  ; but it is set to lisp-indent-offset, which is nil,
  ; and setting it to non-nil makes the lisp formatting less readable
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2))
  (add-to-list 'copilot-indentation-alist '(scheme-mode 2)))

(after! copilot
  (setq copilot-idle-delay 0)
  (add-to-list 'warning-suppress-types '(copilot copilot-exceeds-max-char))
  (add-to-list 'warning-suppress-types '(copilot copilot-no-mode-ident)))

;; Enable frames-only-mode immediately on startup
(after! frames-only-mode
  (frames-only-mode))

(use-package! telega
  :defer t
  :custom
  (telega-directory (expand-file-name "telega" doom-cache-dir))
  (telega-video-player-command '(concat "mpv"
                                        (when telega-ffplay-media-timestamp
                                          (format " --start=%f" telega-ffplay-media-timestamp))))
  (telega-completing-read-function completing-read-function))

(after! gptel
  (setq gptel-backend (gptel-make-gemini "Gemini" :key "XXX" :stream t))
  (setq gptel-model 'gemini-1.5-flash)
  (setq gptel-default-mode 'org-mode))

(after! cov
  (setq cov-coverage-mode t))

;; Start calendar on Monday
(setq calendar-week-start-day 1)

(after! mermaid-mode
  (setq mermaid-mmdc-location "docker")
  (setq mermaid-flags "run -u 1000 --rm -v /tmp:/tmp ghcr.io/mermaid-js/mermaid-cli/mermaid-cli"))

;; Simple presentation mode for org-mode:
;; present one heading at a time, with big fond
(defun org-advance ()
  (interactive)
  (when (buffer-narrowed-p)
  (beginning-of-buffer)
  (widen)
  (org-forward-heading-same-level 1))
    (org-narrow-to-subtree))

(defun org-retreat ()
  (interactive)
  (when (buffer-narrowed-p)
    (beginning-of-buffer)
    (widen)
   (org-backward-heading-same-level 1))
   (org-narrow-to-subtree))

(defun org-start-present ()
  (interactive)
  (org-narrow-to-subtree)
  (doom-big-font-mode 1))

(defun org-end-present ()
  (interactive)
  (widen)
  (doom-big-font-mode -1))

(map! :after org
       :mode org-mode
       :localleader
       :desc "Start presentation" "p s" #'org-start-present
       :desc "End presentation" "p e" #'org-end-present
       :desc "Narrow to next heading" "p n" #'org-advance
       :desc "Narrow to previous heading" "p p" #'org-retreat)

(use-package! auto-dark
  :defer t
  :init
  ;; Configure themes
  (setq! auto-dark-themes '((doom-one) (spacemacs-light)))
  ;; Disable doom's theme loading mechanism (just to make sure)
  (setq! doom-theme nil)
  ;; Enable auto-dark-mode at the right point in time.
  ;; This is inspired by doom-ui.el. Using server-after-make-frame-hook avoids
  ;; issues with an early start of the emacs daemon using systemd, which causes
  ;; problems with the DBus connection that auto-dark mode relies upon.
  (defun my-auto-dark-init-h ()
    (auto-dark-mode)
    (remove-hook 'server-after-make-frame-hook #'my-auto-dark-init-h)
    (remove-hook 'after-init-hook #'my-auto-dark-init-h))
  (let ((hook (if (daemonp)
                  'server-after-make-frame-hook
                'after-init-hook)))
    ;; Depth -95 puts this before doom-init-theme-h, which sounds like a good
    ;; idea, if only for performance reasons.
    (add-hook hook #'my-auto-dark-init-h -95)))

(defun disable-company-mode-in-buffer ()
  (company-mode -1))

(after! org
  ;; Company mode pop-up slows Emacs down in org mode, also it is almost never useful
  (add-hook 'org-mode-hook #'disable-company-mode-in-buffer))
