(require 'package)

(setq package-user-dir (or (getenv "EMACS_PACKAGE_DIR")
                           (expand-file-name ".cache/elpa" default-directory)))
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa" . "https://melpa.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(dolist (pkg '(exec-path-from-shell package-lint flycheck-package))
  (unless (package-installed-p pkg)
    (package-install pkg)))

(require 'checkdoc)
(require 'bytecomp)
(require 'package-lint)
(require 'flycheck)
(require 'flycheck-package)

(defvar epfp--file
  (expand-file-name (or (car command-line-args-left)
                        "exec-path-from-powershell.el")
                    default-directory))

(defun epfp--fail (fmt &rest args)
  (princ (apply #'format (concat fmt "\n") args))
  (kill-emacs 1))

(defun epfp--run-checkdoc ()
  (with-current-buffer (find-file-noselect epfp--file)
    (unless (checkdoc-current-buffer t)
      (let ((buf (get-buffer "*Style Warnings*")))
        (epfp--fail "checkdoc failed:\n%s"
                    (if buf
                        (with-current-buffer buf
                          (buffer-substring-no-properties (point-min) (point-max)))
                      "unknown warning"))))))

(defun epfp--run-byte-compile ()
  (let ((byte-compile-error-on-warn t)
        (elc-file (byte-compile-dest-file epfp--file)))
    (unwind-protect
        (condition-case err
            (byte-compile-file epfp--file)
          (error
           (epfp--fail "byte-compile failed: %s" (error-message-string err))))
      (when (file-exists-p elc-file)
        (delete-file elc-file)))))

(defun epfp--run-package-lint ()
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
  (with-current-buffer (find-file-noselect epfp--file)
    (emacs-lisp-mode)
    (flycheck-package-setup)
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

(epfp--run-checkdoc)
(epfp--run-byte-compile)
(epfp--run-package-lint)
(epfp--run-flycheck-package)
(princ "All package quality checks passed.\n")
