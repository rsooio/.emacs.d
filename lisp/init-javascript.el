(add-to-list 'auto-mode-alist '("\\.\\(ts\\)\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.\\(tsx\\)\\'" . tsx-ts-mode))

(add-to-list'treesit-language-source-alist
 '((tsx . ("https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "tsx/src"))
   (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "typescript/src"))))

(add-hook 'typescript-ts-mode-hook 'eglot-ensure)

(provide 'init-javascript)
