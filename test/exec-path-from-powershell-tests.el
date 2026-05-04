;;; exec-path-from-powershell-tests.el --- Tests for exec-path-from-powershell  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Tim Felgentreff
;;
;; Author: Tim Felgentreff <timfelgentreff@gmail.com>
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; ERT coverage for PowerShell dispatch and helper functions.

;;; Code:

(require 'ert)
(require 'cl-lib)
(require 'exec-path-from-powershell)

(defmacro epfp-tests--with-shell (shell-name &rest body)
  "Evaluate BODY with `exec-path-from-shell-shell-name' set to SHELL-NAME."
  (declare (indent 1))
  `(let ((exec-path-from-shell-shell-name ,shell-name))
     ,@body))

(ert-deftest exec-path-from-powershell-ps-quote-escapes-apostrophes ()
  (should (equal (exec-path-from-powershell--ps-quote "O'Hare")
                 "'O''Hare'")))

(ert-deftest exec-path-from-powershell-decode-escapes-handles-common-cases ()
  (should (equal (exec-path-from-powershell--decode-escapes "a\\nb\\x21\\041")
                 "a\nb!!")))

(ert-deftest exec-path-from-powershell-printf-delegates-for-non-powershell ()
  (epfp-tests--with-shell "bash"
    (should (equal (exec-path-from-powershell--printf
                    (lambda (str args)
                      (list :delegated str args))
                    "ignored"
                    '("$env:HOME"))
                   '(:delegated "ignored" ("$env:HOME"))))))

(ert-deftest exec-path-from-powershell-printf-formats-powershell-values ()
  (cl-letf (((symbol-function 'exec-path-from-powershell--evaluate-expressions)
             (lambda (_args) '("Alice" "!"))))
    (epfp-tests--with-shell "pwsh.exe"
      (should (equal (exec-path-from-powershell--printf
                      (lambda (&rest _args)
                        (ert-fail "unexpected fallback"))
                      "Hello %s%s")
                     "Hello Alice!")))))

(ert-deftest exec-path-from-powershell-evaluate-expressions-parses-json-output ()
  (cl-letf (((symbol-function 'exec-path-from-powershell--call-powershell)
             (lambda (_script) "[\"one\",null,\"three\"]")))
    (should (equal (exec-path-from-powershell--evaluate-expressions '("1" "$null" "3"))
                   '("one" nil "three")))))

(ert-deftest exec-path-from-powershell-getenvs-delegates-for-non-powershell ()
  (epfp-tests--with-shell "bash"
    (should (equal (exec-path-from-powershell--getenvs
                    (lambda (names) (cons :delegated names))
                    '("PATH"))
                   '(:delegated "PATH")))))

(ert-deftest exec-path-from-powershell-getenvs-reads-json-output ()
  (cl-letf (((symbol-function 'exec-path-from-powershell--call-powershell)
             (lambda (_script) "{\"PATH\":\"C:/Windows\",\"HOME\":null}"))
            ((symbol-function 'exec-path-from-powershell--maybe-extend-names-with-visual-studio-env)
             (lambda (names) names)))
    (epfp-tests--with-shell "pwsh.exe"
      (let ((default-directory temporary-file-directory))
        (should (equal (exec-path-from-powershell--getenvs
                        (lambda (&rest _args)
                          (ert-fail "unexpected fallback"))
                        '("PATH" "HOME"))
                       '(("PATH" . "C:/Windows")
                         ("HOME"))))))))

(ert-deftest exec-path-from-powershell-maybe-extends-visual-studio-variable-list ()
  (let ((exec-path-from-powershell-includes-visual-studio-environment t)
        (exec-path-from-shell-variables '("PATH")))
    (cl-letf (((symbol-function 'exec-path-from-powershell--visual-studio-variable-names)
               (lambda () '("PATH" "INCLUDE" "LIB"))))
      (should (equal (exec-path-from-powershell--maybe-extend-names-with-visual-studio-env
                      '("PATH"))
                     '("PATH" "INCLUDE" "LIB"))))))

(ert-deftest exec-path-from-powershell-load-installs-advice ()
  (unwind-protect
      (progn
        (exec-path-from-powershell-disable)
        (exec-path-from-powershell--enable)
        (exec-path-from-powershell--enable)
        (should (advice-member-p #'exec-path-from-powershell--getenvs
                                 #'exec-path-from-shell-getenvs))
        (should (advice-member-p #'exec-path-from-powershell--printf
                                 #'exec-path-from-shell-printf))
        (exec-path-from-powershell-disable)
        (should-not (advice-member-p #'exec-path-from-powershell--getenvs
                                     #'exec-path-from-shell-getenvs))
        (should-not (advice-member-p #'exec-path-from-powershell--printf
                                     #'exec-path-from-shell-printf)))
    (exec-path-from-powershell-disable)))

(provide 'exec-path-from-powershell-tests)
;;; exec-path-from-powershell-tests.el ends here
