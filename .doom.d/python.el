;;; python.el -*- lexical-binding: t; -*-

(use-package! python-black
  :demand
  :after python
  :hook (python-mode-hook . python-black-on-save-mode))
