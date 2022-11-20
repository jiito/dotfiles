;;; git.el -*- lexical-binding: t; -*-


(defun get-jira-prefix (iden)
  "Get the JIRA branch identifier from IDEN."
  (let ((prefix (string-match "[A-Za-z]+-[0-9]+" iden)))
    (if (not prefix)
        (message iden) (substring iden prefix  (match-end 0))
        )
    )
  )

(defun current-git-branch ()
  "Get the current git branch."
  (vc-git--symbolic-ref (buffer-file-name)))

(defun insert-branch-id()
  "Insert the ticket identifier at point"
  (interactive)
  (insert (format "[%s]: "  (get-jira-prefix (current-git-branch)) ))
  (evil-insert-state)
  (forward-char)
  )
