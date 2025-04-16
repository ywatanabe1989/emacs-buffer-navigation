#!/bin/bash
# -*- coding: utf-8 -*-
# Timestamp: "2025-02-14 06:28:24 (ywatanabe)"
# File: /home/ywatanabe/.dotfiles/.emacs.d/lisp/emacs-tab-manager/run-tests.sh

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_PATH="$0.log"
touch "$LOG_PATH"

main () {
    emacs -batch -l ert \
          -l package \
          --eval "(progn \
     (add-to-list 'load-path \".\") \
     (add-to-list 'load-path \"./etm-buffer\") \
     (add-to-list 'load-path \"./etm-close\") \
     (add-to-list 'load-path \"./etm-keys\") \
     (add-to-list 'load-path \"./etm-layout\") \
     (add-to-list 'load-path \"./tests\") \
                                (package-initialize) \
                                (require 'tab-bar))" \
                      -l etm-variables.el \
                      -l etm-buffer-checkers.el \
                      -l etm-buffer-getters.el \
                      -l etm-buffer-jumpers.el \
                      -l etm-buffer-kill-or-bury.el \
                      -l etm-buffer-setters.el \
                      -l etm-buffer.el \
                      -l etm-close-core.el \
                      -l etm-close-utils.el \
                      -l etm-close.el \
                      -l etm-init.el \
                      -l etm-keys-buffer.el \
                      -l etm-keys-command-map.el \
                      -l etm-keys-layout.el \
                      -l etm-keys-navigation.el \
                      -l etm-layout-create.el \
                      -l etm-layout-load.el \
                      -l etm-layout-save.el \
                      -l etm-layout-window.el \
                      -l etm-layout.el \
                      -l etm-navigation.el \
                      -l etm-new-and-rename.el \
                      -l test-etm-buffer-checkers.el \
                      -l test-etm-buffer-getters.el \
                      -l test-etm-buffer-jumpers.el \
                      -l test-etm-buffer-kill-or-bury.el \
                      -l test-etm-buffer-setters.el \
                      -l test-etm-close-core.el \
                      -l test-etm-close-utils.el \
                      -l test-etm-init.el \
                      -l test-etm-keys-command-map.el \
                      -l test-etm-keys-layout.el \
                      -l test-etm-keys-navigation.el \
                      -l test-etm-layout-load.el \
                      -l test-etm-layout-save.el \
                      -l test-etm-layout-window.el \
                      -l test-etm-navigation.el \
                      -l test-etm-new-and-rename.el \
                      -l test-etm-variables.el \
                      -f ert-run-tests-batch-and-exit
                      # -l test-etm-layout-create.el \
}

main "$@" 2>&1 | tee $LOG_PATH

# EOF