;;; ~/.config/doom/config.el -*- lexical-binding: t; -*-
;;;
;; UI
(setq doom-theme 'doom-dracula
      doom-font (font-spec :family "JetBrainsMono" :size 26 :weight 'light)
      doom-variable-pitch-font (font-spec :family "DejaVu Sans" :size 24)
      fancy-splash-image (concat doom-user-dir "splash.png"))
;;
;;; Keybinds
(map! (:after evil-org
       :map evil-org-mode-map
       :n "gk" (cmd! (if (org-at-heading-p)
                         (org-backward-element)
                       (evil-previous-visual-line)))
       :n "gj" (cmd! (if (org-at-heading-p)
                         (org-forward-element)
                       (evil-next-visual-line))))

      :o "o" #'evil-inner-symbol

      :leader
      (:prefix "f"
               "t" #'find-in-dotfiles
               "T" #'browse-dotfiles)
      (:prefix "n"
               "b" #'org-roam-buffer-toggle
               "d" #'org-roam-dailies-goto-today
               "D" #'org-roam-dailies-goto-date
               "i" #'org-roam-node-insert
               "r" #'org-roam-node-find
               "R" #'org-roam-capture))


;;; :ui modeline
;; An evil mode indicator is redundant with cursor shape
(advice-add #'doom-modeline-segment--modals :override #'ignore)


;; :completion company
;; IMO, modern editors have trained a bad habit into us all: a burning need for
;; completion all the time -- as we type, as we breathe, as we pray to the
;; ancient ones -- but how often do you *really* need that information? I say
;; rarely. So opt for manual completion:
(after! company
  (setq company-idle-delay nil))


;; :tools lsp
;; Disable invasive lsp-mode features
(after! lsp-mode
  (setq lsp-enable-symbol-highlighting nil
        ;; If an LSP server isn't present when I start a prog-mode buffer, you
        ;; don't need to tell me. I know. On some machines I don't care to have
        ;; a whole development environment for some ecosystems.
        lsp-enable-suggest-server-download nil))
(after! lsp-ui
  (setq lsp-ui-sideline-enable nil  ; no more useful than flycheck
        lsp-ui-doc-enable nil))     ; redundant with K


;; Some sensible defaults
(setq-default
 window-combination-resize t                      ; take new window space from all other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width

(setq undo-limit 80000000                         ; Raise undo-limit to 80Mb
      evil-want-fine-undo t                       ; By default while in insert all changes are one big blob. Be more granular
      auto-save-default t                         ; Nobody likes to loose work, I certainly don't
      truncate-string-ellipsis "…"                ; Unicode ellispis are nicer than "...", and also save /precious/ space
      display-line-numbers-type 'relative)
(setq evil-split-window-below t                   ; :editor evil
      evil-vsplit-window-right t)                 ; Focus new window after splitting


;; TODO Broken
;; pdf-tools dark mode
(use-package pdf-view
  :hook (pdf-tools-enabled . pdf-view-midnight-minor-mode)
  :hook (pdf-tools-enabled . hide-mode-line-mode)
  :hook (pdf-tools-enabled . hide-mode-line-mode)
  :config
  (setq pdf-view-midnight-colors '("#ABB2BF" . "#282C35")))
;; (setq! pdf-view-midnight-colors '("#ABB2BF" . "#282C35"))
;; (add-hook 'pdf-view-mode-hook
;;           #'(lambda ()
;;               ;; Making 'midnight mode' into more of 'matches my theme mode'
;;               (setq pdf-view-midnight-colors (cons
;;                                               "#ABB2BF"
;;                                               "#282C35"))

;;               ;; Actually enable midnight mode
;;               (pdf-view-midnight-minor-mode)))


;;; :tools magit
(setq magit-repository-directories '(("~/projects" . 2))
      ;; magit-save-repository-buffers nil
      ;; Don't restore the wconf after quitting magit, it's jarring
      ;; magit-inhibit-save-previous-winconf t
      transient-values '((magit-rebase "--autosquash" "--autostash")
                         (magit-pull "--rebase" "--autostash")
                         (magit-revert "--autostash")))


;;; :lang org
(setq org-directory "~/projects/org/"
      ;;       +org-roam-auto-backlinks-buffer t
      org-id-locations-file (concat org-directory ".orgids")
      org-agenda-prefix-format " %i \t %?-12t% s"
      org-roam-db-location (concat org-directory ".org-roam.db")
      org-roam-directory org-directory
      org-roam-dailies-directory "journal/"
      org-archive-location (concat org-directory ".archive/%s::")
      org-agenda-files (concat org-directory ".agenda_files"))

(after! org
  (plist-put org-format-latex-options :scale 1.10) ;properly scale latex previews
  (setq org-startup-folded 'show4levels
        org-agenda-span 'month
        org-ellipsis " [...] "
        ;; My org/org-roam capture templates
        org-capture-templates
        '(("t" "todo" entry (file+headline "todo.org" "Unsorted")
           "* [ ] %?\n%i\n%a"
           :prepend t)
          ("d" "deadline" entry (file+headline "todo.org" "Schedule")
           "* [ ] %?\nDEADLINE: <%(org-read-date)>\n\n%i\n%a"
           :prepend t)
          ("s" "schedule" entry (file+headline "todo.org" "Schedule")
           "* [ ] %?\nSCHEDULED: <%(org-read-date)>\n\n%i\n%a"
           :prepend t)
          ("c" "check out later" entry (file+headline "todo.org" "Check out later")
           "* [ ] %?\n%i\n%a"
           :prepend t)))
  (setq org-latex-classes
        '(("lecture"
           "\\documentclass[english,seminar]{lecture}"
           ("\\section*{%s}")
           ("\\subsection*{%s}")
           ("\\subsubsection*{%s}")))))

(after! org-roam
  (setq org-roam-capture-templates
        `(("n" "note" plain
           ,(format "#+title: ${title}\n%%[%s/template/note.org]" org-roam-directory)
           :target (file "note/%<%Y%m%d>-${slug}.org")
           :unnarrowed t)
          ("r" "thought" plain
           ,(format "#+title: ${title}\n%%[%s/template/thought.org]" org-roam-directory)
           :target (file "thought/%<%Y%m%d>-${slug}.org")
           :unnarrowed t)
          ("c" "coursework" plain
           ,(format "#+title: ${title}\n%%[%s/template/topic.org]" org-roam-directory)
           :target (file "coursework/%<%Y%m%d>-${slug}.org")
           :unnarrowed t)
          ("t" "topic" plain
           ,(format "#+title: ${title}\n%%[%s/template/topic.org]" org-roam-directory)
           :target (file "topic/%<%Y%m%d>-${slug}.org")
           :unnarrowed t)
          ("p" "project" plain
           ,(format "#+title: ${title}\n%%[%s/template/project.org]" org-roam-directory)
           :target (file "project/%<%Y%m%d>-${slug}.org")
           :unnarrowed t))
        ;; Use human readable dates for dailies titles
        org-roam-dailies-capture-templates
        '(("d" "default" entry "* %?"
           :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%B %d, %Y>\n\n#+BEGIN: clocktable :scope agenda :block thisweek :fileskip0 1\n#+END:")
           ))))

(after! org-roam
  ;; Offer completion for #tags and @areas separately from notes.
  (add-to-list 'org-roam-completion-functions #'org-roam-complete-tag-at-point)

  ;; Automatically update the slug in the filename when #+title: has changed.
  (add-hook 'org-roam-find-file-hook #'org-roam-update-slug-on-save-h)

  ;; Make the backlinks buffer easier to peruse by folding leaves by default.
  ;; (add-hook 'org-roam-buffer-postrender-functions #'magit-section-show-level-2)

  ;; List dailies and zettels separately in the backlinks buffer.
  (advice-add #'org-roam-backlinks-section :override #'org-roam-grouped-backlinks-section)

  ;; Open in focused buffer, despite popups
  (advice-add #'org-roam-node-visit :around #'+popup-save-a)

  ;; Make sure tags in vertico are sorted by insertion order, instead of
  ;; arbitrarily (due to the use of group_concat in the underlying SQL query).
  ;; (advice-add #'org-roam-node-list :filter-return #'org-roam-restore-insertion-order-for-tags-a)

  ;; Add ID, Type, Tags, and Aliases to top of backlinks buffer.
  (advice-add #'org-roam-buffer-set-header-line-format :after #'org-roam-add-preamble-a))

(after! (org ob-ditaa)
  (setq org-ditaa-jar-path "ditaa"))


;;
;; LSP w/ C
(load! "gendoxy.el")                                    ; Easy tags and headers for c dev

;; Configure lsp-mode with ccls
(setq ccls-executable "/etc/profiles/per-user/bh/bin/ccls")
(after! ccls
  (setq ccls-initialization-options '(:index (:comments 2) :completion (:detailedLabel t)))
  (set-lsp-priority! 'ccls 2)) ; optional as ccls is the default in Doom

(use-package platformio-mode)                           ; PlatformIO Mode for microcontrollers

(add-hook 'c-mode-hook (lambda ()
                         (lsp-deferred)
                         (platformio-conditionally-enable)))

(use-package google-c-style
  :hook ((c-mode c++-mode) . google-set-c-style)
  (c-mode-common . google-make-newline-indent))


;;
;;; :app everywhere
(after! emacs-everywhere
  ;; Easier to match with a bspwm rule:
  ;;   bspc rule -a 'Emacs:emacs-everywhere' state=floating sticky=on
  (setq emacs-everywhere-frame-name-format "emacs-anywhere")

  ;; The modeline is not useful to me in the popup window. It looks much nicer
  ;; to hide it.
  (remove-hook 'emacs-everywhere-init-hooks #'hide-mode-line-mode)

  ;; Semi-center it over the target window, rather than at the cursor position
  ;; (which could be anywhere).
  (defadvice! center-emacs-everywhere-in-origin-window (frame window-info)
    :override #'emacs-everywhere-set-frame-position
    (cl-destructuring-bind (x y width height)
        (emacs-everywhere-window-geometry window-info)
      (set-frame-position frame
                          (+ x (/ width 2) (- (/ width 2)))
                          (+ y (/ height 2))))))


;;
;;; Language customizations

(define-generic-mode sxhkd-mode
  '(?#)
  '("alt" "Escape" "super" "bspc" "ctrl" "space" "shift") nil
  '("sxhkdrc") nil
  "Simple mode for sxhkdrc files.")
