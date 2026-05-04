;;; bootstrap.el --- Development bootstrap for exec-path-from-powershell  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Tim Felgentreff
;;
;; Author: Tim Felgentreff <timfelgentreff@gmail.com>
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; Shared development bootstrap for local checks and CI.

;;; Code:

(require 'package)

(defconst epfp-bootstrap--package-dir
  (expand-file-name ".cache/elpa" default-directory)
  "Package installation directory used by local quality checks.")

(defconst epfp-bootstrap--package-archives
  '(("gnu" . "https://elpa.gnu.org/packages/")
    ("nongnu" . "https://elpa.nongnu.org/nongnu/")
    ("melpa" . "https://melpa.org/packages/"))
  "Package archives used by local quality checks.")

(defconst epfp-bootstrap--dependencies
  '(exec-path-from-shell package-lint flycheck-package)
  "Packages needed by local quality checks.")

(defun epfp-bootstrap-initialize ()
  "Prepare the local development environment for batch checks."
  (setq package-user-dir epfp-bootstrap--package-dir)
  (setq package-quickstart nil)
  (setq package-archives epfp-bootstrap--package-archives)
  (package-initialize)
  (unless package-archive-contents
    (package-refresh-contents))
  (dolist (pkg epfp-bootstrap--dependencies)
    (unless (package-installed-p pkg)
      (package-install pkg)))
  (add-to-list 'load-path default-directory)
  (let ((test-dir (expand-file-name "test" default-directory)))
    (when (file-directory-p test-dir)
      (add-to-list 'load-path test-dir))))

(provide 'epfp-bootstrap)
;;; bootstrap.el ends here
