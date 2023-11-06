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

(setq doom-font (font-spec :size 30 :family "Ubuntu Mono"))

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
                                "--completion-style=detailed")
      lsp-clangd-binary-path "/usr/bin/clangd-17")

(after! lsp-clangd (set-lsp-priority! 'clangd 2))

(map! :leader :desc "Lisp eval any expression" ":" #'pp-eval-expression)
(map! :leader :desc "Choose an interactive command" ";" #'execute-extended-command)
(map! :leader :desc "Switch to the previously shown buffer" "TAB" #'mode-line-other-buffer)
(map! :leader :desc "Switch to the previously shown buffer" "<tab>" #'mode-line-other-buffer)

(after! org
  (setq org-agenda-files '("~/notes/gtd/general.org"
                           "~/notes/gtd/inbox.org"
                           "~/notes/gtd/projects.org"
                           "~/notes/gtd/tickler.org")
        org-capture-templates
        '(("t" "Add a todo item" entry
           (file+headline "~/notes/gtd/inbox.org" "Todos")
           "** TODO [#B] %?
  OPEN: %U" :jump-to-captured t :empty-lines 1))
        org-refile-targets
        '(("~/notes/gtd/projects.org" :maxlevel . 2)
          ("~/notes/gtd/someday.org" :level . 1)
          ("~/notes/gtd/tickler.org" :maxlevel . 2))
        org-todo-keywords
        '((sequence "TODO(t)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
  (setq org-log-done t
        org-log-into-drawer t)
  )


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


;; To display line numbers on the side:
;; M-x linum-mode

; add google-translate package?

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))

(after! copilot
  (setq copilot-idle-delay 0))
