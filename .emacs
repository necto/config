;; .emacs - personal emacs settings.
;; Author: Arseniy Zaostrovnykh

(global-font-lock-mode t) ; turn on syntax coloring

;; Highlight a whole comment, not only ';' sign
(when (= 23 emacs-major-version)
  (set-face-foreground 'font-lock-comment-face "red"))

;; Remove splash screen
(setq inhibit-splash-screen t)

(line-number-mode t) ; enable line numbers column (not working)

;; Highlight matched parenthesis without delay
(show-paren-mode t)
(setq show-paren-delay 0)

;; Highlight text selection
(transient-mark-mode 1)
;(require 'highlight-current-line)
;(highlight-current-line-on t)

(xterm-mouse-mode t)

(mwheel-install)

;;; (global-set-key [(control h)] 'delete-backward-char)
;; ^^^ it was needed for putty backspace -> C-h translation.
;; now i simple disabled it.
;;  Remember, that <f1> is also a help key
;;(global-set-key (kbd "C-?") 'help-command)

(defun select-next-window ()
  "Switch to the next window" 
  (interactive)
  (select-window (next-window)))

(defun select-previous-window ()
  "Switch to the previous window" 
  (interactive)
  (select-window (previous-window)))

;; Select window with Meta-arrow keys
(global-set-key (kbd "<M-right>") 'select-next-window)
(global-set-key (kbd "ESC <right>") 'select-next-window)
(global-set-key (kbd "ESC <left>")  'select-previous-window)
(global-set-key (kbd "<M-left>")  'select-previous-window)


;; select whole line
(defun select-current-line ()
  "Select the current line"
  (interactive)
  (end-of-line) ; move to end of line
  (set-mark (line-beginning-position)))

;; Plugins directory
;; Also loads default.el, which contains local configuration
(add-to-list 'load-path "~/.emacs.d/")

;; Autocompletion
;; wget http://cx4a.org/pub/auto-complete/auto-complete-1.3.1.tar.bz2
(when (file-exists-p "~/.emacs.d/auto-complete")
  (add-to-list 'load-path "~/.emacs.d/auto-complete/")
  (when (< 21 emacs-major-version)
    (require 'auto-complete-config)
    (add-to-list 'ac-dictionary-directories "~/.emacs.d//ac-dict")
    (ac-config-default)
    ;; Not autocomplete comments
    (add-to-list 'ac-ignores "//")
    ;; Suggest autocompletion after 4 characters typed
    (setq ac-auto-start 4)))

;; indentation: '{' without indentation
(c-set-offset 'substatement-open 0)
;; next statement - 4 spaces further
(setq c-basic-offset 4)

;; disable tab usage
(setq-default indent-tabs-mode nil)

;; to enable line numbers at the left side of the text
(when (< 21 emacs-major-version)
  (linum-mode 1))

;; enable column numbers at the status-bar
(column-number-mode 1)

;; Delete all trailing spaces after the point. Neccesary for kill-line advice.
(defun delete-horizontal-space-after ()
  "Delete all spaces and tabs after point."
  (let ((orig-pos (point)))
    (delete-region
     (progn
       (skip-chars-forward " \t")
       (constrain-to-field nil orig-pos t))
     orig-pos)))

;; kill all excess spaces at the next line while joining them
(defadvice kill-line (before check-position activate)   
  (when (member major-mode
                '(emacs-lisp-mode scheme-mode lisp-mode
                                  c-mode c++-mode objc-mode
                                  latex-mode plain-tex-mode))
    (delete-horizontal-space-after)
    (if (and (eolp) (not (bolp)))
        (progn (forward-char 1)
               (delete-horizontal-space)
               (backward-char 1)))))

;; Find a file in a dir or it's ancestors
(defun find-file-upwards (file-to-find)
  "Recursively searches each parent directory starting from the default-directory.
   looking for a file with name file-to-find.  Returns the path to it
   or nil if not found."
  (labels ((find-file-r (path)
                    (let* ((parent (file-name-directory path))
                           (possible-file (concat parent file-to-find)))
                      (cond
                       ((file-exists-p possible-file) possible-file) ; Found
                       ;; The parent of ~ is nil and the parent of / is itself.
                       ;; Thus the terminating condition for not finding the file
                       ;; accounts for both.
                       ((or (null parent) (equal parent (directory-file-name parent))) nil) ; Not found
                       (t (find-file-r (directory-file-name parent))))))) ; Continue
    (find-file-r default-directory)))

;; Find the most appropriate TAGS for active file
(defun find-tags-upwards ()
  (interactive)
  (let ((my-tags-file (find-file-upwards "TAGS")))
    (when my-tags-file
      (message "Loading tags file: %s" my-tags-file)
      (visit-tags-table my-tags-file)
      (message "Loaded tags tables: %s" tags-table-list))))

;; Open the appropriate TAGS table (if exist) right after opening a c file
(defadvice find-file (after find-and-visit-tags-file-after-open-file protect activate)
  "Open an appropriate TAGS table right after visiting a file"
    (if (member major-mode
              '(c-mode c++-mode objc-mode))
        (find-tags-upwards)))

;; for word-at-point function
(require 'thingatpt)

(defun nearest-symbol-at-point ()
  (let ((sym (symbol-at-point)))
    (if (null sym)
        (progn 
          (forward-char 1)
          (nearest-symbol-at-point))
      (symbol-name sym))))

;; vim-star analogous
(global-set-key [f6]
  (lambda ()
    "Reset current search to a word-mode search of the word under point."
    (interactive)
    (search-forward (nearest-symbol-at-point))))

;; vim-amp analogous
(global-set-key [f7]
  (lambda ()
    "Reset current isearch to a word-mode search of the word under point."
    (interactive)
    (search-backward (nearest-symbol-at-point))))
;    (setq isearch-word t
;          isearch-string ""
;          isearch-message "")
;    (isearch-yank-string (nearest-symbol-at-point))
;    (isearch-backward)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(compilation-scroll-output (quote first-error))
 '(multi-term-scroll-show-maximum-output t)
 '(term-scroll-show-maximum-output nil))

(when (< 21 emacs-major-version)
  (custom-set-faces
   ;; custom-set-faces was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   '(font-lock-keyword-face ((((class color) (min-colors 8)) (:foreground "blue" :weight thin))))
   '(highlight ((((class color) (min-colors 8)) (:background "gray"))))
   '(stripes-face ((t (:background "gray95"))))))

;; Stripes mode - like the one in tables
;; wget http://www.emacswiki.org/emacs/download/stripes.el
(require 'stripes nil 'noerror)

;; Ido mode: Interactively DO : autocomipletion file and 
;; buffer names by matching in any part, not only beginning
(when (< 21 emacs-major-version)
  (ido-mode 1))

;; Overcoming the xterm-256color issure with <end> => <select> key
(when (< 21 emacs-major-version)
  (define-key input-decode-map "[4~" [end]))

;; Disable menubar 
(menu-bar-mode -1)


;;; This was needed only in the default emacs. in my own emacs, it is no
;;; longer necessary

;;;; Workaround for a "mouse on menu-bar" bug
;; (defun transform-to-start-event (event)
;;   (let ((y0 (second (window-inside-edges (selected-window))))
;;         (x0 (first (window-inside-edges (selected-window)))))
;;     (let ((x (- (car (third (second event))) #x3fff00 x0))
;;           (y (- (cdr (third (second event))) y0))
;;           (time (fourth (second event))))
;;       `(down-mouse-1 ,(posn-at-x-y x y (window-at 0 0) t)))))

;; (defun tmm-menubar-mouse (event)
;;   (interactive "e")
;;   (let ((evt (transform-to-start-event event)))
;;     (push (cons 'up-mouse-1 (cdr evt)) unread-command-events)
;;     (mouse-drag-track evt t)))


;; Rectangular selection
;; wget http://emacswiki.org/emacs/download/rect-mark.el
(when (require 'rect-mark nil 'noerror) ; rebinding of C-SPC doesn't work, don't know why.
  (global-set-key (kbd "C-x r SPC") 'rm-set-mark)
  ;; More general key bindings, taking into account a
  ;; rectangular selection
  (global-set-key (kbd "C-w")  
                  '(lambda(b e) (interactive "r") 
                     (if rm-mark-active 
                         (rm-kill-region b e) (kill-region b e))))
  (global-set-key (kbd "M-w")  
                  '(lambda(b e) (interactive "r") 
                     (if rm-mark-active 
                         (rm-kill-ring-save b e) (kill-ring-save b e))))
  (global-set-key (kbd "C-x C-x")  
                  '(lambda(&optional p) (interactive "p") 
                     (if rm-mark-active 
                         (rm-exchange-point-and-mark p) (exchange-point-and-mark p))))
  
  (autoload 'rm-set-mark "rect-mark"
    "Set mark for rectangle." t)
  (autoload 'rm-exchange-point-and-mark "rect-mark"
    "Exchange point and mark for rectangle." t)
  (autoload 'rm-kill-region "rect-mark"
    "Kill a rectangular region and save it in the kill ring." t)
  (autoload 'rm-kill-ring-save "rect-mark"
    "Copy a rectangular region to the kill ring." t))
  
;; More convinient terminal emulator then the "term"
;; wget http://www.emacswiki.org/emacs/download/multi-term.el
(when (require 'multi-term nil 'noerror)
  (global-set-key (kbd "<f5>") 'multi-term)
  (global-set-key (kbd "<C-next>") 'multi-term-next)
  (global-set-key (kbd "<C-prior>") 'multi-term-prev)
  (setq multi-term-buffer-name "term"
        multi-term-program "/bin/bash"))

;; Linearize the last kill-ring entry
(defun make-single-line-in-clipboard ()
  (interactive)
  (with-temp-buffer
    (yank)
    (pop kill-ring)
    (goto-char 0)
    (while (search-forward "\n" nil t)
      (replace-match "" nil t))
    (kill-region (point-min) (point-max))))

;; Paste into terminal the linearized last killed text
(defun paste-into-term-singlelined ()
  (interactive)
  (term-line-mode)
  (make-single-line-in-clipboard)
  (end-of-buffer)
  (clipboard-yank)
  (term-char-mode))

;; some more key bindings
(when (require 'term nil 'noerror) ; only if term can be loaded..
  (setq term-bind-key-alist
        (list (cons "C-c C-c" 'term-interrupt-subjob)
              (cons "C-p" 'previous-line)
              (cons "C-n" 'next-line)
              (cons "M-f" 'term-send-forward-word)
              (cons "M-b" 'term-send-backward-word)
              (cons "C-c C-j" 'term-line-mode)
              (cons "C-c C-k" 'term-char-mode)
              (cons "M-DEL" 'term-send-backward-kill-word)
              (cons "M-d" 'term-send-forward-kill-word)
              (cons "<C-left>" 'term-send-backward-word)
              (cons "<C-right>" 'term-send-forward-word)
              (cons "C-r" 'term-send-reverse-search-history)
              (cons "M-p" 'term-send-raw-meta)
              (cons "M-y" 'term-send-raw-meta)
              (cons "C-y" 'paste-into-term-singlelined)))) ;;<- was term-send-raw


;; brief Dired mode.
;; wget http://www.emacswiki.org/emacs/download/dired-details.el
(when (require 'dired-details nil 'noerror)
  (dired-details-install))

;; Use directory name instead of a number in buffer with
;; the same named files :instead of Makefile Makefile<2>
;; it will become Makefile:sbo Makefile:rto
(require 'uniquify)
(setq 
 uniquify-buffer-name-style 'post-forward
 uniquify-separator ":")

;; Time in status bar
(setq display-time-day-and-date t
      display-time-24hr-format t)
(display-time)

;; APEL library, needed for elscreen
(add-to-list 'load-path "~/.emacs.d/APEL/")


;; Line marking:
(defun find-overlays-specifying (prop pos)
  (let ((overlays (overlays-at pos))
        found)
    (while overlays
      (let ((overlay (car overlays)))
        (if (overlay-get overlay prop)
            (setq found (cons overlay found))))
      (setq overlays (cdr overlays)))
    found))

(defun highlight-or-dehighlight-line ()
  (interactive)
  (if (find-overlays-specifying
       'line-highlight-overlay-marker
       (line-beginning-position))
      (remove-overlays (line-beginning-position) (+ 1 (line-end-position)))
    (let ((overlay-highlight (make-overlay
                              (line-beginning-position)
                              (+ 1 (line-end-position)))))
        (overlay-put overlay-highlight 'face '(:background "lightgreen"))
        (overlay-put overlay-highlight 'line-highlight-overlay-marker t))))


(global-set-key [f8] 'highlight-or-dehighlight-line)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-keyword-face ((((class color) (min-colors 8)) (:foreground "blue" :weight thin))))
 '(highlight ((((class color) (min-colors 8)) (:background "gray"))))
 '(stripes-face ((t (:background "gray95")))))
