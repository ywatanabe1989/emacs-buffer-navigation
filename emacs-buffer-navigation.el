;;; -*- coding: utf-8; lexical-binding: t -*-
;;; Author: ywatanabe
;;; Timestamp: <2025-04-17 06:08:09>
;;; File: /home/ywatanabe/.emacs.d/lisp/emacs-buffer-navigation/emacs-buffer-navigation.el

;;; Copyright (C) 2025 Yusuke Watanabe (ywatanabe@alumni.u-tokyo.ac.jp)
(defvar emacs-buffer-navigation-history nil
  "List of buffers in order of most recently visited.")

(defvar emacs-buffer-navigation-index 0
  "Current index in the buffer history list for navigation.")

(defvar emacs-buffer-navigation-in-progress nil
  "Flag to indicate if user is currently navigating through buffer history.")

(defcustom emacs-buffer-navigation-enabled t
  "Whether buffer navigation tracking is enabled by default."
  :type 'boolean
  :group 'emacs-buffer-navigation)

(defgroup emacs-buffer-navigation nil
  "Enhanced buffer navigation with history tracking."
  :group 'convenience)

(defun --emacs-buffer-navigation-clean-history ()
  "Remove dead buffers from the history."
  (setq emacs-buffer-navigation-history
        (cl-remove-if-not #'buffer-live-p
                          emacs-buffer-navigation-history)))

(defun --emacs-buffer-navigation-update-history (buffer)
  "Add BUFFER to history, remove any older duplicates."
  (unless (or emacs-buffer-navigation-in-progress
              (minibufferp buffer)
              (string-match-p "^ " (buffer-name buffer))
              (string= (buffer-name buffer) "*Buffer History*"))
    (--emacs-buffer-navigation-clean-history)
    (setq emacs-buffer-navigation-history
          (cons buffer
                (delq buffer emacs-buffer-navigation-history)))
    (setq emacs-buffer-navigation-index 0)))

(defun emacs-buffer-navigation-previous ()
  "Switch to previous buffer in history."
  (interactive)
  (--emacs-buffer-navigation-clean-history)
  (when (and emacs-buffer-navigation-history
             (< (1+ emacs-buffer-navigation-index)
                (length emacs-buffer-navigation-history)))
    (setq emacs-buffer-navigation-in-progress t)
    (setq emacs-buffer-navigation-index
          (1+ emacs-buffer-navigation-index))
    (let ((target-buffer
           (nth emacs-buffer-navigation-index
                emacs-buffer-navigation-history)))
      (when (buffer-live-p target-buffer)
        (switch-to-buffer target-buffer t))))

  ;; Update buffer history display if it exists
  (when (get-buffer "*Buffer History*")
    (emacs-buffer-navigation-show-history)))

(defun emacs-buffer-navigation-next ()
  "Switch to next buffer in history."
  (interactive)
  (--emacs-buffer-navigation-clean-history)
  (when
      (and emacs-buffer-navigation-history
           (> emacs-buffer-navigation-index 0))
    (setq emacs-buffer-navigation-in-progress t)
    (setq emacs-buffer-navigation-index
          (1- emacs-buffer-navigation-index))
    (let ((target-buffer
           (nth emacs-buffer-navigation-index
                emacs-buffer-navigation-history)))
      (when (buffer-live-p target-buffer)
        (switch-to-buffer target-buffer t))))

  ;; Update buffer history display if it exists
  (when (get-buffer "*Buffer History*")
    (emacs-buffer-navigation-show-history)))

(defun --emacs-buffer-navigation-commit ()
  "Commit current navigation state, making current buffer the most recent."
  (interactive)
  (setq emacs-buffer-navigation-in-progress nil)
  (--emacs-buffer-navigation-update-history (current-buffer)))

(defun emacs-buffer-navigation-show-history ()
  "Show the buffer history in a temporary buffer."
  (interactive)
  (--emacs-buffer-navigation-clean-history)
  (with-current-buffer (get-buffer-create "*Buffer History*")
    (let ((inhibit-read-only t))
      (erase-buffer)
      (insert "Buffer History (most recent last):\n\n")

      ;; Get the total count of buffers for index calculation
      (let* ((total-buffers (length emacs-buffer-navigation-history))
             (current-buffer-name (buffer-name (current-buffer))))

        ;; Loop through history in reverse to display oldest first
        (cl-loop for buffer in
                 (reverse emacs-buffer-navigation-history)
                 for count from (1- total-buffers) downto 0
                 do
                 (let ((buffer-name (buffer-name buffer)))
                   (insert (format "%3d: %s%s%s\n"
                                   count
                                   (if
                                       (= count
                                          emacs-buffer-navigation-index)
                                       "→ "
                                     "  ")
                                   buffer-name
                                   (if (and
                                        (not
                                         (string= buffer-name
                                                  "*Buffer History*"))
                                        (string= buffer-name
                                                 current-buffer-name))
                                       " (current)"
                                     ""))))))

      ;; Enable Buffer History mode
      (emacs-buffer-navigation-history-mode)
      (goto-char (point-min))))
  (display-buffer "*Buffer History*"
                  '(display-buffer-same-window . nil)))

(defun emacs-buffer-navigation-goto-buffer ()
  "Jump to buffer on current line in history list."
  (interactive)
  (let ((line (line-number-at-pos))
        (first-buffer-line 3))
                                        ; First buffer entry is at line 3
    (when (>= line first-buffer-line)
      (let* ((line-index (- line first-buffer-line))
             ;; Calculate the actual buffer index from the displayed line
             ;; (since we're showing oldest first)
             (total-buffers (length emacs-buffer-navigation-history))
             (index (- (1- total-buffers) line-index))
             (buffer (nth index emacs-buffer-navigation-history)))
        (when (and buffer (buffer-live-p buffer))
          (setq emacs-buffer-navigation-in-progress t)
          (setq emacs-buffer-navigation-index index)
          (pop-to-buffer buffer)
          (when (get-buffer "*Buffer History*")
            (emacs-buffer-navigation-show-history)))))))

(defun emacs-buffer-navigation-display-buffer ()
  "Display buffer on current line in history list but don't select it."
  (interactive)
  (let ((line (line-number-at-pos))
        (first-buffer-line 3))
                                        ; First buffer entry is at line 3
    (when (>= line first-buffer-line)
      (let* ((line-index (- line first-buffer-line))
             ;; Calculate the actual buffer index from the displayed line
             ;; (since we're showing oldest first)
             (total-buffers (length emacs-buffer-navigation-history))
             (index (- (1- total-buffers) line-index))
             (buffer (nth index emacs-buffer-navigation-history)))
        (when (and buffer (buffer-live-p buffer))
          (setq emacs-buffer-navigation-in-progress t)
          (setq emacs-buffer-navigation-index index)
          (display-buffer buffer)
          (when (get-buffer "*Buffer History*")
            (emacs-buffer-navigation-show-history)))))))

(define-derived-mode emacs-buffer-navigation-history-mode special-mode
  "Buffer History"
  "Major mode for displaying and interacting with buffer history."
  :group 'emacs-buffer-navigation
  (use-local-map emacs-buffer-navigation-history-mode-map)
  (setq truncate-lines t)
  (setq buffer-read-only t))

(defvar emacs-buffer-navigation-history-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") 'emacs-buffer-navigation-goto-buffer)
    (define-key map (kbd "C-m")
                'emacs-buffer-navigation-display-buffer)
    (define-key map (kbd "C-o")
                'emacs-buffer-navigation-display-buffer)
    (define-key map (kbd "p") 'previous-line)
    (define-key map (kbd "n") 'next-line)
    (define-key map (kbd "q") 'quit-window)
    map)
  "Keymap for Buffer History mode.")

;; Track buffer switching

(defun --emacs-buffer-navigation-track-change ()
  "Update buffer history when buffer changes."
  (let ((current (current-buffer)))
    (--emacs-buffer-navigation-update-history current)))

;; Add buffer change tracking

(defun emacs-buffer-navigation-enable ()
  "Enable buffer navigation tracking."
  (interactive)
  (add-hook 'window-buffer-change-functions
            (lambda (_) (--emacs-buffer-navigation-track-change)))
  (add-hook 'after-init-hook '--emacs-buffer-navigation-track-change)

  ;; Watch keyboard input to detect when navigation ends
  (add-hook 'pre-command-hook
            (lambda ()
              (unless (or
                       (eq this-command
                           'emacs-buffer-navigation-previous)
                       (eq this-command 'emacs-buffer-navigation-next)
                       (eq this-command
                           'emacs-buffer-navigation-show-history)
                       (eq this-command
                           'emacs-buffer-navigation-goto-buffer)
                       (eq this-command
                           'emacs-buffer-navigation-display-buffer))
                (when emacs-buffer-navigation-in-progress
                  (--emacs-buffer-navigation-commit)))))
  (message "Buffer navigation enabled"))

(defun emacs-buffer-navigation-disable ()
  "Disable buffer navigation tracking."
  (interactive)
  (remove-hook 'window-buffer-change-functions
               (lambda (_) (--emacs-buffer-navigation-track-change)))
  (remove-hook 'after-init-hook
               '--emacs-buffer-navigation-track-change)
  (remove-hook 'pre-command-hook
               (lambda ()
                 (unless (or
                          (eq this-command
                              'emacs-buffer-navigation-previous)
                          (eq this-command
                              'emacs-buffer-navigation-next)
                          (eq this-command
                              'emacs-buffer-navigation-show-history)
                          (eq this-command
                              'emacs-buffer-navigation-goto-buffer)
                          (eq this-command
                              'emacs-buffer-navigation-display-buffer))
                   (when emacs-buffer-navigation-in-progress
                     (--emacs-buffer-navigation-commit)))))
  (message "Buffer navigation disabled"))

;; Automatically enable on startup if custom variable is set
(when emacs-buffer-navigation-enabled
  (emacs-buffer-navigation-enable))

(provide 'emacs-buffer-navigation)

(when
    (not load-file-name)
  (message "emacs-buffer-navigation.el loaded."
           (file-name-nondirectory
            (or load-file-name buffer-file-name))))