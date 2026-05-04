;;; quality-check.el --- Batch quality checks for exec-path-from-powershell  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Tim Felgentreff
;;
;; Author: Tim Felgentreff <timfelgentreff@gmail.com>
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; Run metadata, style, and byte-compilation checks in batch mode.

;;; Code:

(load (expand-file-name "scripts/bootstrap.el" default-directory) nil 'nomessage)
(epfp-bootstrap-initialize)

(require 'checkdoc)
(require 'bytecomp)
(require 'package-lint)
(require 'flycheck)
(require 'flycheck-package)

(defvar epfp--file
  (expand-file-name (or (car command-line-args-left)
                        "exec-path-from-powershell.el")
                    default-directory))

(defconst epfp--test-file
  (expand-file-name "test/exec-path-from-powershell-tests.el" default-directory))

(defun epfp--fail (fmt &rest args)
  "Print FMT and ARGS and exit with a failure status."
  (princ (apply #'format (concat fmt "\n") args))
  (kill-emacs 1))

(defun epfp--run-checkdoc (file)
  "Run `checkdoc' for FILE."
  (with-current-buffer (find-file-noselect file)
    (unless (checkdoc-current-buffer t)
      (let ((buf (get-buffer "*Style Warnings*")))
        (epfp--fail "checkdoc failed for %s:\n%s"
                    file
                    (if buf
                        (with-current-buffer buf
                          (buffer-substring-no-properties (point-min) (point-max)))
                      "unknown warning"))))))

(defun epfp--run-byte-compile (file)
  "Byte-compile FILE and fail on warnings."
  (let ((byte-compile-error-on-warn t)
        (elc-file (byte-compile-dest-file file)))
    (unwind-protect
        (condition-case err
            (byte-compile-file file)
          (error
           (epfp--fail "byte-compile failed for %s: %s"
                       file
                       (error-message-string err))))
      (when (file-exists-p elc-file)
        (delete-file elc-file)))))

(defun epfp--run-package-lint ()
  "Run `package-lint' for the main package file."
  (with-current-buffer (find-file-noselect epfp--file)
    (let ((issues (package-lint-buffer)))
      (when issues
        (epfp--fail
         "package-lint failed:\n%s"
         (mapconcat (lambda (issue)
                      (pcase-let ((`(,line ,col ,level ,message) issue))
                        (format "%s:%s:%s: %s" line col level message)))
                    issues
                    "\n"))))))

(defun epfp--run-flycheck-package ()
  "Run `flycheck-package' for the main package file."
  (with-current-buffer (find-file-noselect epfp--file)
    (emacs-lisp-mode)
    (flycheck-package-setup)
    (setq-local flycheck-emacs-lisp-load-path 'inherit)
    (flycheck-mode 1)
    (let ((status nil))
      (add-hook 'flycheck-status-changed-functions
                (lambda (new-status)
                  (when (memq new-status
                              '(finished no-checker errored interrupted suspicious))
                    (setq status new-status)))
                nil t)
      (flycheck-buffer)
      (while (null status)
        (accept-process-output nil 0.05))
      (unless (eq status 'finished)
        (epfp--fail "flycheck-package finished with status %S" status))
      (when flycheck-current-errors
        (epfp--fail
         "flycheck-package failed:\n%s"
         (mapconcat
          (lambda (err)
            (format "%s:%s:%s: %s [%s]"
                    (or (flycheck-error-filename err) epfp--file)
                    (or (flycheck-error-line err) 0)
                    (or (flycheck-error-column err) 0)
                    (flycheck-error-message err)
                    (or (flycheck-error-id err) "unknown")))
          flycheck-current-errors
          "\n"))))))

(epfp--run-checkdoc epfp--file)
(when (file-exists-p epfp--test-file)
  (epfp--run-checkdoc epfp--test-file))
(epfp--run-byte-compile epfp--file)
(when (file-exists-p epfp--test-file)
  (epfp--run-byte-compile epfp--test-file))
(epfp--run-package-lint)
(epfp--run-flycheck-package)
(princ "All package quality checks passed.\n")
;;; quality-check.el ends here
