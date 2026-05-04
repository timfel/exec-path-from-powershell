;;; test-batch.el --- Batch ERT runner for exec-path-from-powershell  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Tim Felgentreff
;;
;; Author: Tim Felgentreff <timfelgentreff@gmail.com>
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; Run the package's ERT suite in batch mode.

;;; Code:

(load (expand-file-name "scripts/bootstrap.el" default-directory) nil 'nomessage)
(epfp-bootstrap-initialize)

(require 'ert)
(load-file (expand-file-name "test/exec-path-from-powershell-tests.el"
                             default-directory))

(ert-run-tests-batch-and-exit)
;;; test-batch.el ends here
