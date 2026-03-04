;; -*- lexical-binding: t; coding: utf-8 -*-

(use-package emacs
  :ensure t ; ensure use-package-ensure is loaded
  :hook
  ((prog-mode . display-fill-column-indicator-mode)
   (before-save . delete-trailing-whitespace))
  :custom
  ;; install ttf-symbola for emojis
  (face-font-rescale-alist '(("Unifont" . 1.2) ("Symbola" . 1.3)))
  (custom-file (locate-user-emacs-file "custom.el"))
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
  (frame-title-format '(:eval (or (buffer-file-name) default-directory)))
  (backup-directory-alist '(("." . (locate-user-emacs-file "backups"))))
  (backup-by-copying t)
  (kept-new-versions 10)
  (kept-old-versions 2)
  (delete-old-versions t)
  (version-control t)
  (fill-column 80)
  (compilation-scroll-output t)
  (compilation-max-output-line-length nil)
  (flymake-mode-line-lighter nil)
  :bind
  ("C-x C-b" . #'ibuffer)
  :init
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (add-to-list 'initial-frame-alist '(fullscreen . maximized))
  (set-frame-font (format "JetBrainsMonoNerdFontMono %d"
                          (/ (display-pixel-width) 140)))
  (dolist (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font (frame-parameter nil 'font) charset
                      (font-spec :family "Unifont")))
  (set-fontset-font (frame-parameter nil 'font) 'emoji
                    (font-spec :family "Symbola"))
  (connection-local-set-profile-variables 'remote-direct-async-process
                                          '((tramp-direct-async-process . t)))
  (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
  (setopt use-short-answers t))

(use-package ls-lisp
  :ensure nil
  :custom
  (ls-lisp-use-insert-directory-program nil)
  (ls-lisp-dirs-first t))

(use-package delight
  :delight
  (eldoc-mode))

;; TODO: remove indicator in modeline
(use-package hideshow
  :delight
  :ensure nil
  :hook (lisp-mode . hs-minor-mode)
  :bind
  (:map hs-minor-mode-map
        ("<backtab>" . #'hs-toggle-hiding)))

;; TODO: remove indicator in modeline
(use-package cursor-undo
  :delight cursor-undo
  :config
  (cursor-undo 1)
  (disable-cursor-tracking move-beginning-of-line)
  (disable-cursor-tracking move-end-of-line))
(use-package paredit
  :delight
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

(use-package swagg)

(defun apifox-upload ()
  "Upload API definitions to Apifox."
  (interactive)
  (if-let* ((definition (swagg--select-definition))
            (name (plist-get definition :name))
            (json (plist-get definition :json))
            (url (format "https://api.apifox.com/v1/projects/%s/import-openapi"
                         apifox-project-id))
            (folder (plist-get definition :apifox-folder))
            (api-key (getenv "APIFOX_API_KEY"))
            (docs (shell-command-to-string (format "curl -s %s" json)))
            (command (format
                      "curl -s %s \\
                           -H 'X-Apifox-Api-Version: 2024-03-28' \\
                           -H 'Authorization: Bearer %s' \\
                           -H 'Content-Type: application/json' \\
                           -d '{
                               \"input\": %s,
                               \"options\": {
                                   \"targetEndpointFolderId\": %s,
                                   \"endpointOverwriteBehavior\": \"AUTO_MERGE\"
                               }
                           }'"
                      url api-key (json-encode-string docs) folder))
            (output (shell-command-to-string command)))
      (message "%s" output)))

(defun save-buffer-without-newline ()
  "Save the current buffer without adding a newline at the end."
  (interactive)
  (let ((require-final-newline nil))
    (save-buffer)))

(use-package magit
  :custom
  (magit-display-buffer-function
   #'magit-display-buffer-same-window-except-diff-v1)
  :bind
  ("C-x g g" . #'magit-status)
  ("C-x g b" . #'magit-blame-addition)
  ;; TODO: add margin settings in magit log "Other" section use shortcut "S"
  ;; :config
  ;; (transient-append-suffix 'magit-log "b"
  ;;   '("F" "Margin Settings" magit-margin-settings))
)

(use-package magit-todos
  :after magit
  :config (magit-todos-mode 1))

(use-package magit-todos
  :after magit
  :config (magit-todos-mode 1))

(use-package git-timemachine
  :bind
  ("C-x g t" . #'git-timemachine))

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
  (:map corfu-map
        ("SPC" . #'corfu-insert-separator)
        ("TAB" . #'corfu-complete))
  :init
  (global-corfu-mode))

(use-package cape
  :bind ("M-+" . cape-prefix-map)
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
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
        ("<backtab>" . #'treesit-fold-toggle)))

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

(defun custom-eglot-java-init-opts (server eglot-java-eclipse-jdt)
  '(:settings
    (:java
     (:format
      (:settings
       (:url "https://gist.githubusercontent.com/rsooio/ce8695ae1c3959e3c7d562399b376ae5/raw/1bfb8e437d64f83e32530dcda3db0ecf3b188eae/eclipse-java-google-style.xml")
       :enabled t)))))

(defun find-file-recursively-upward (filename &optional start-dir)
  "Search for FILENAME recursively upward from START-DIR or current directory."
  (let ((dir (file-name-as-directory (or start-dir default-directory))))
    (cond ((file-exists-p (expand-file-name filename dir))
           (expand-file-name filename dir))
          ((equal dir "/") nil)
          (t (find-file-recursively-upward filename (file-name-directory (directory-file-name dir)))))))

(defun buffer-regex-search (regex &optional num)
  "Search for REGEX in the current buffer and return the match string."
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward regex nil t)
      (substring-no-properties (match-string (or num 0))))))

(defun which-java-package ()
  "Get the current Java package name based on buffer content."
  (buffer-regex-search
   "package\\s-+\\([a-zA-Z0-9_.]+\\)\\s-*;" 1))

(defun current-filename ()
  (if (derived-mode-p 'dired-mode)
      (dired-get-filename)
    (buffer-file-name)))

(defun which-java-class (&optional filename)
  "Get the current Java class name based on file name"
  (let ((filename (or filename (current-filename))))
    (when (string-suffix-p ".java" filename)
      (file-name-base filename))))

(defun which-java-function ()
  "Get the current Java function name based on cursor position."
  (let ((func (which-function)))
    (when func
      (car (last (split-string func "\\."))))))

(defun java-current-class-name ()
  "Get the current Java class name based on buffer content."
  (let ((package-name (buffer-regex-search
                       "package\\s-+\\([a-zA-Z0-9_.]+\\)\\s-*;" 1))
        (class-name (buffer-regex-search
                     "class\\s-+\\([A-Za-z0-9_]+\\)" 1)))
    (when (and class-name package-name)
      (concat package-name "." class-name))))

(defun named-compile (cmd &optional name)
  "Run a compile command CMD with an optional NAME for the compilation buffer."
  (let ((compilation-buffer-name-function
         (lambda (mode)
           (format "*%s: %s*" mode
                   (or name (project-root (project-current)))))))
    (compile cmd)))

(defun maven-artifact-id (pom-path)
  "Extract the artifactId from the nearest pom.xml file."
  (let ((pom-path (or pom-path (find-file-recursively-upward "pom.xml"))))
    (when pom-path
      (with-temp-buffer
        (insert-file-contents pom-path)
        (buffer-regex-search "<artifactId>\\([^<]+\\)</artifactId>" 1)))))

(defun java-run (cmd)
  "Run a Java command CMD in the context of the current project."
  (if-let* ((project (project-current))
            (root (project-root project))
            (cfg (cond ((file-exists-p (file-name-concat root "build.gradle"))
                        "build.gradle")
                       ((file-exists-p (file-name-concat root "pom.xml"))
                        "pom.xml"))))
      (cond ((string= cfg "pom.xml")
             (let ((mvn-cmd (if (file-exists-p (file-name-concat root "mvnw"))
                                (file-name-concat root "mvnw")  "mvn"))
                   (path (find-file-recursively-upward cfg))
                   (default-directory root))
               (named-compile (format "%s -f %s %s" mvn-cmd path cmd)
                              (format "%s(%s)" (maven-artifact-id path)
                                      (car (split-string cmd " "))))))
            ((string= cfg "build.gradle")
             (message "Not implemented yet.")))
    (message "No project found.")))

(defun java-run-class ()
  "Run java application for current class."
  (interactive)
  (let ((class-name (java-current-class-name)))
    (if class-name
        (java-run (format "compile exec:java -Dexec.mainClass=%s" class-name))
      (message "Cannot determine class name"))))

(defun java-test-package ()
  "Run java test for current package."
  (interactive)
  (java-run "test"))

(defun java-test-class ()
  "Run java test for current class."
  (interactive)
  (let ((class-name (java-current-class-name)))
    (if class-name
        (java-run (format "test -Dtest=%s" class-name))
      (message "Cannot determine class name"))))

(defun java-test-function ()
  "Run java test for current function."
  (interactive)
  (let ((class-name (java-current-class-name))
        (function-name (which-java-function)))
    (if (and class-name function-name)
        (java-run (format "test -Dtest=%s#%s" class-name function-name))
      (message "Cannot determine class or function"))))

(defun java-test (arg)
  "Run java test."
  (interactive "P")
  (cond ((equal arg '(4)) (java-test-class))
        ((equal arg '(16)) (java-test-function))
        (t (java-test-package))))

(defun java-start ()
  "Start java application."
  (interactive)
  (java-run "spring-boot:run"))

(defun copy&replace-file (file replacements)
  "Copy FILE, replace content and title based on REPLACEMENTS
   and return the new file path."
  (let* ((new-file file))
    (dolist (pair replacements)
      (setq new-file (replace-regexp-in-string
                      (regexp-quote (car pair)) (cdr pair) new-file t t)))
    (with-temp-buffer
      (insert-file-contents file)
      (dolist (pair replacements)
        (goto-char (point-min))
        (while (search-forward (regexp-quote (car pair)) nil t)
          (replace-match (cdr pair) t t)))
      (write-region (point-min) (point-max) new-file nil 'silent))
    new-file))

(defun java-copy ()
  "Copy current java file, replace package and class name, and open the new file."
  (interactive)
  (if-let* ((filename (current-filename))
            (class (which-java-class filename))
            (before (read-string "Replace: " class))
            (after (read-string (format "Replace '%s' with: " before) before))
            (replacements `((,before . ,after)))
            (new-file (copy&replace-file filename replacements)))
      (when (derived-mode-p 'dired-mode)
        (revert-buffer))
      (copy&replace-file filename `((,before . ,after)))))

(use-package eglot-java
  :custom
  (eglot-java-java-program "/usr/lib/jvm/java-21-openjdk/bin/java")
  (eglot-java-user-init-opts-fn 'custom-eglot-java-init-opts)
  :hook java-ts-mode
  :bind
  (:map eglot-java-mode-map
        ("TAB" . #'indent-for-tab-command)
        ("C-c C-x x" . #'java-start)
        ("C-c C-x n" . #'eglot-java-file-new)
        ("C-c C-x N" . #'eglot-java-project-new)
        ("C-c C-x t" . #'java-test)
        ("C-c C-x T" . #'eglot-java-project-build-task)
        ("C-c C-x r" . #'java-run-class)
        ("C-c C-x R" . #'eglot-java-project-build-refresh)))

(use-package eglot-java-lombok
  :after eglot-java
  :vc (:url "https://github.com/ltylty/eglot-java-lombok"
            :rev :newest)
  :config
  (eglot-java-lombok/init))

(use-package clojure-mode
  :mode "\\.bb\\'")

(use-package cider
  :hook clojure-mode
  :custom
  (cider-jack-in-default 'babashka)
  (cider-repl-display-help-banner nil)
  (cider-allow-jack-in-without-project t)
  (cider-font-lock-dynamically '(macro core function var deprecated))
  (cider-repl-display-help-banner nil))
