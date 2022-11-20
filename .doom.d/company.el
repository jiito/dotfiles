;;; company.el -*- lexical-binding: t; -*-

(use-package company
  :custom
  (company-idle-delay 0.25))

(use-package yasnippet
  :ensure
  :config
  (yas-reload-all)
  (add-hook 'rpog))
