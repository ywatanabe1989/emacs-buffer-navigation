<!-- ---
!-- Timestamp: 2025-04-17 06:08:54
!-- Author: ywatanabe
!-- File: /home/ywatanabe/.emacs.d/lisp/emacs-buffer-navigation/README.md
!-- --- -->

# Emacs Buffer Navigation

Enhanced buffer navigation with history tracking for Emacs.

## Features

1. Tracks buffer navigation history automatically
2. Allows navigating backward and forward through visited buffers
3. Provides a dedicated buffer history view with oldest-first ordering
4. Supports jumping to or displaying buffers from the history list
5. Integrates with standard Emacs navigation commands
6. Enabled by default - ready to use after installation

## Installation

### Manual Installation

Clone this repository and add to your load path:

```elisp
(add-to-list 'load-path "/path/to/emacs-buffer-navigation")
(require 'emacs-buffer-navigation)

;; Optional: Set up custom key bindings
(global-set-key (kbd "C-c p") 'emacs-buffer-navigation-previous)
(global-set-key (kbd "C-c n") 'emacs-buffer-navigation-next)
(global-set-key (kbd "C-c l") 'emacs-buffer-navigation-show-history)
```

### With use-package

```elisp
(use-package emacs-buffer-navigation
  :load-path "/path/to/emacs-buffer-navigation"
  :bind (("C-c p" . emacs-buffer-navigation-previous)
         ("C-c n" . emacs-buffer-navigation-next)
         ("C-c l" . emacs-buffer-navigation-show-history)))
```

## Usage

### Define Your Own Key Bindings

Set up key bindings that work for you:

```elisp
(global-set-key (kbd "C-c p") 'emacs-buffer-navigation-previous) 
(global-set-key (kbd "C-c n") 'emacs-buffer-navigation-next)
(global-set-key (kbd "C-c l") 'emacs-buffer-navigation-show-history)
```

### In Buffer History View

- `RET` - Go to buffer on current line
- `C-m` - Display buffer on current line without focusing it
- `C-o` - Display buffer on current line without focusing it
- `p/n` - Move up/down in the list
- `q` - Close history view

## Customization

```elisp
;; Disable automatic enabling on load
(setq emacs-buffer-navigation-enabled nil)

;; Enable/disable manually
(emacs-buffer-navigation-enable)
(emacs-buffer-navigation-disable)
```

## Contact
Yusuke Watanabe (ywatanabe@alumni.u-tokyo.ac.jp)

<!-- EOF -->