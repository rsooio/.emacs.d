;; -*- lexical-binding: t; coding: utf-8 -*-

(use-package emacs
  :ensure t ; ensure use-package-ensure is loaded
  :hook
  ((prog-mode . display-fill-column-indicator-mode)
   (before-save . delete-trailing-whitespace)
   ((lisp-data-mode clojure-mode) . hs-minor-mode))
  :custom
  (face-font-rescale-alist '(("Unifont" . 1.2) ("Symbola" . 1.3))) ; install ttf-symbola for emojis
  (tab-always-indent 'complete)
  (use-package-always-ensure t)
  (warning-minimum-level :error)
  (text-mode-ispell-word-completion nil) ; Corfu handles completion
  (read-extended-command-predicate #'command-completion-default-include-p)
  (inhibit-startup-screen)
  (menu-bar-mode nil)
  (tool-bar-mode nil)
  (scroll-bar-mode nil)
  (which-key-mode t)
  (savehist-mode t)
  (desktop-save-mode t)
  (column-number-mode t)
  (global-display-line-numbers-mode t)
  (display-line-numbers-type 'relative)
  (indent-tabs-mode nil)
  (kill-buffer-delete-auto-save-files t)
  (save-interprogram-paste-before-kill t)
  (tab-width 4)
  (go-ts-mode-indent-offset 4)
  (bookmark-bmenu-file-column 50)
  (frame-title-format '((:eval (if (buffer-file-name) "%f" "%F"))))
  (backup-directory-alist '(("." . (locate-user-emacs-file "backups"))))
  (backup-by-copying t)
  (kept-new-versions 10)
  (kept-old-versions 2)
  (delete-old-versions t)
  (version-control t)
  (fill-column 80)
  :bind
  ("C-x C-b" . #'ibuffer)
  (:map hs-minor-mode-map ("<backtab>" . #'hs-toggle-hiding))
  :init
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (add-to-list 'initial-frame-alist '(fullscreen . maximized))
  (set-frame-font (format "JetBrainsMonoNerdFontMono %d" (/ (display-pixel-height) 80)))
  (dolist (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font (frame-parameter nil 'font) charset (font-spec :family "Unifont")))
  (set-fontset-font (frame-parameter nil 'font) 'emoji (font-spec :family "Symbola"))
  (connection-local-set-profile-variables 'remote-direct-async-process
                                          '((tramp-direct-async-process . t)))
  (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter))

(use-package delight
  :delight
  (eldoc-mode))

(use-package paredit
  :hook (lisp-data-mode clojure-mode cider-repl-mode)
  :bind
  (:map paredit-mode-map
        ("C-<backspace>" . #'paredit-backward-kill-word)
        ("[" . #'paredit-open-square)
        ("{" . #'paredit-open-curly)
        ("]" . #'paredit-close-square)
        ("}" . #'paredit-close-curly)
        ("M-[" . #'paredit-wrap-square)
        ("M-{" . #'paredit-wrap-curly)))

(defun default-project-function-no-tramp (may-prompt)
  "Project function that ignores remote projects."
  (if (file-remote-p default-directory)
      nil
    (consult--default-project-function may-prompt)))

(use-package consult
  :custom
  (consult-project-function #'default-project-function-no-tramp)
  :bind
  (("C-x b" . #'consult-buffer)
   ("C-x r b" . #'consult-bookmark)
   ("M-g g" . #'consult-goto-line)
   ("M-g M-g" . #'consult-goto-line)
   ("M-g i" . #'consult-imenu)
   ("M-g e" . #'consult-flymake)
   ("M-y" . #'consult-yank-pop)
   ("M-s g" . #'consult-ripgrep)
   ("M-s G" . #'consult-git-grep)
   ("M-s l" . #'consult-line)
   ("M-s L" . #'consult-line-multi)
   ("M-s p g" . #'consult-project-ripgrep)
   ("C-x p b" . #'consult-project-buffer)
   :map minibuffer-local-map
   ("C-r" . #'consult-history)))

(use-package multiple-cursors
  :bind
  (("C-c m c" . #'mc/edit-lines)
   ("C-c m n" . #'mc/mark-next-like-this)
   ("C-c m p" . #'mc/mark-previous-like-this)
   ("C-c m a" . #'mc/mark-all-like-this)))

(use-package vundo
  :bind
  ("C-x u" . #'vundo))

(use-package rime
  :custom
  (default-input-method "rime")
  (rime-user-data-dir (getenv "RIME_USER_DIR")))

(use-package org
  :custom
  (org-agenda-files '("~/org/"))
  (org-agenda-prefix-format '((agenda . " %i %-12:c%?-12t%-6e% s")
                              (todo . " %i %-12:c %-6e")
                              (tags . " %i %-12:c")
                              (search . " %i %-12:c")))
  (org-startup-indented t)
  (org-indent-indentation-per-level 2)
  (org-cycle-include-plain-lists 'integrate)
  (org-log-done 'time)
  (org-special-ctrl-a/e t)
  (org-special-ctrl-k t)
  (org-duration-format '(("d") (special . 1)))
  (org-duration-units
   `(("min" . 1)
     ("h" . 60)
     ("d" . ,(* 60 8))
     ("w" . ,(* 60 8 5))
     ("m" . ,(* 60 8 5 4))
     ("y" . ,(* 60 8 5 4 12))))
  :bind
  ("C-c C-l" . #'org-store-link)
  ("C-c a" . #'org-agenda)
  ("C-c c" . #'org-capture))

(use-package eat)

(defun consult-project-ripgrep ()
  (interactive)
  (let* ((pr (project-current t))
         (root (project-root pr)))
    (consult-ripgrep root)))

(defun curl-command (url &rest args)
  "Construct a curl command string."
  (let ((curl-command (concat "curl -i -s " url)))
    (while-let ((flag (pop args)))
      (when (symbolp flag)
        (cond ((eq flag :json)
               (setq curl-command (concat curl-command " -H 'Content-Type: application/json'")))
              ((and (not (null args)) (stringp (car args)))
               (let ((value (pop args)))
                 (setq curl-command
                       (concat curl-command " " (format "-%s '%s'" (substring (symbol-name flag) 1) value))))))))
    curl-command))

(defun curl (url &rest args)
  "Make HTTP requests using curl."
  (with-output-to-temp-buffer "*curl-output*"
    (pop-to-buffer "*curl-output*")
    (let* ((command (apply #'curl-command url args))
           (response (shell-command-to-string command))
           (lines (split-string response "\r\n"))
           json?)
      (princ "Curl Command:\n")
      (princ command)
      (princ "\n\nResponse:\n")
      (while-let ((line (pop lines)))
        (when (string-match-p "^content-type:.*application/json" (downcase line))
          (setq json? t))
        (when (and (string-match-p "^{" line) json?)
          (with-temp-buffer
            (insert line)
            (json-pretty-print-buffer)
            (setq line (buffer-string))))
        (princ line)
        (princ "\n")))))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  :bind
  ("C-x g g" . #'magit-status)
  ("C-x g b" . #'magit-blame-addition))

(use-package git-timemachine
  :bind
  ("C-x g t" . (lambda () (interactive) (git-timemachine) (global-display-line-numbers-mode t))))

(use-package diff-hl
  :after magit
  :hook ((magit-post-refresh . diff-hl-magit-post-refresh)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (dired-mode . diff-hl-dired-mode))
  :custom-face
  (diff-hl-insert ((t (:background "green4" :foreground "#eeffee"))))
  (diff-hl-delete ((t (:background "red3" :foreground "#ffffff"))))
  (diff-hl-change ((t (:background "blue3" :foreground "#ddddff"))))
  :config
  (diff-hl-margin-mode 1)
  (diff-hl-flydiff-mode 1)
  (global-diff-hl-mode 1))

(use-package copilot
  :delight
  :hook prog-mode
  :bind
  (:map copilot-completion-map
        ("C-RET" . #'copilot-accept-completion)
        ("C-<return>" . #'copilot-accept-completion)
        ("M-RET" . #'copilot-accept-completion-by-word)
        ("M-<return>" . #'copilot-accept-completion-by-word))
  :custom
  (copilot-max-char 1000000)
  (copilot-clear-overlay-ignore-commands '(indent-for-tab-command))
  :config
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode . 2)))

(use-package ai-code
  :custom
  (global-auto-revert-mode t)
  (auto-revert-interval 1)
  (ai-code-backends-infra-terminal-backend 'eat)
  :bind
  ("C-c C-a" . #'ai-code-menu)
  :config
  (ai-code-set-backend 'github-copilot-cli)
  (with-eval-after-load 'magit
    (transient-append-suffix 'magit-diff "r" ; "Extra" group
      '("A" "AI Code: Review/generate diff" ai-code-pull-or-review-diff-file))
    (transient-append-suffix 'magit-blame "b" ; "Extra" group
      '("A" "AI Code: Analyze blame" ai-code-magit-blame-analyze))
    (transient-append-suffix 'magit-log "b" ; "Extra" group
      '("A" "AI Code: Analyze log" ai-code-magit-log-analyze)))
  (advice-remove 'ai-code-backends-infra--create-terminal-session
                 #'ai-code-backends-infra--create-terminal-session--filter)
  (advice-add 'ai-code-backends-infra--create-terminal-session
              :filter-args #'ai-code-backends-infra--create-terminal-session--filter))

(defun ai-code-backends-infra--create-terminal-session--filter (args)
  "Advice function to filter and modify the arguments for creating a terminal session."
  (setf (nth 2 args) (string-trim (nth 2 args))) args)

(use-package corfu
  :custom
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :bind
  (:map corfu-map)
  :init
  (global-corfu-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  ;; (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-overrides nil)
  (completion-category-defaults nil)
  (completion-pcm-leading-wildcard t))

(use-package vertico
  :custom
  (vertico-scroll-margin 0)
  (vertico-count 15)
  (vertico-resize t)
  (vertico-cycle t)
  :bind
  (:map vertico-map
        ("?" . #'minibuffer-completion-help)
        ("M-RET" . #'minibuffer-force-complete-and-exit)
        ("M-TAB" . #'minibuffer-complete))
  :init
  (vertico-mode))

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  (treesit-font-lock-level 4)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package treesit-fold
  :delight
  :after treesit-auto
  :custom
  (global-treesit-fold-indicators-mode t)
  :bind
  (:map treesit-fold-mode-map
        ("C-c f" . #'treesit-fold-toggle)))

(use-package eglot
  :commands eglot-ensure
  :hook (typescript-mode tsx-mode go-mode)
  :bind
  (:map eglot-mode-map
        ("C-c l r" . #'eglot-rename)
        ("C-c l a" . #'eglot-code-actions)
        ("C-c l f" . #'eglot-format)
        ("C-c l h" . #'eglot-help-at-point)
        ("C-c l s" . #'eglot-shutdown)
        ("C-c l i" . #'eglot-find-implementation)))

(use-package eglot-java
  :custom
  (eglot-java-java-program "/usr/lib/jvm/java-21-openjdk/bin/java")
  :hook java-mode
  :bind
  (:map eglot-java-mode-map
        ("TAB" . #'indent-for-tab-command)
        ("C-c l n" . #'eglot-java-file-new)
        ("C-c l x" . #'eglot-java-run-main)
        ("C-c l t" . #'eglot-java-run-test)
        ("C-c l N" . #'eglot-java-project-new)
        ("C-c l T" . #'eglot-java-project-build-task)
        ("C-c l R" . #'eglot-java-project-build-refresh)))

(use-package eglot-java-lombok
  :after eglot-java
  :vc (:url "https://github.com/ltylty/eglot-java-lombok"
            :rev :newest)
  :config
  (eglot-java-lombok/init))

(use-package clojure-mode
  :mode "\\.bb\\'")

(use-package cider
  :custom
  (cider-repl-display-help-banner nil))
