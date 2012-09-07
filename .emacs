(add-to-list 'load-path "~/.emacs.d/")

(ido-mode)
(setq ido-enable-flex-matching t)
(global-auto-revert-mode)

(setq indent-tabs-mode nil)
(setq-default py-indent-offset 4)

;; smarter buffer switching
(iswitchb-mode t)

(require  'paren) (show-paren-mode t)
(setq query-replace-highlight t)

(modify-syntax-entry ?_ "w") ;; _ not a word delimiter

(add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m) ;; strips ctrl-m from shell out

(autoload 'css-mode "css-mode" "Mode for CSS files" t)

;; velocity syntax hilighting
(autoload 'turn-on-vtl-mode "vtl" "Velocity syntax hilighting" t)
(add-hook 'html-mode-hook 'turn-on-vtl-mode t t)
(add-hook 'xml-mode-hook 'turn-on-vtl-mode t t)
(add-hook 'text-mode-hook 'turn-on-vtl-mode t t)

;; flymake error highlighting for CSS/JS

(when (load "flymake" t)
  (defun flymake-closure-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "~/software/google-closure/closure.sh" (list local-file))))

  (defun flymake-css-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "cssparse" (list local-file))))

  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.js\\'" flymake-closure-init)
               '("\\.css\\'" flymake-css-init))

  (add-to-list 'flymake-err-line-patterns
               '("\\(.*\\) \\[\\([0-9]+\\):\\([0-9]+\\): \\(.*\\)\\]"
                 nil 2 3 1))
)

;; lambda mode
(require 'lambda-mode)
(setq lambda-symbol (string (make-char 'greek-iso8859-7 107)))

;; autopair - enabled in all buffers
(add-to-list 'load-path "~/.emacs.d/autopair")
(require 'autopair)
(autopair-global-mode)

;; python magic

(setq py-install-directory "~/.emacs.d/python-mode")
(add-to-list 'load-path py-install-directory)
(require 'python-mode)
(require 'ipython)

;; add pylookup to your loadpath, ex) "~/.lisp/addons/pylookup"
(setq pylookup-dir "~/.emacs.d/pylookup")
(add-to-list 'load-path pylookup-dir)
;; load pylookup when compile time
(eval-when-compile (require 'pylookup))

(add-hook 'python-mode-hook
          #'(lambda () (push '(?' . ?')
                             (getf autopair-extra-pairs :code))
              (setq autopair-handle-action-fns
                    (list #'autopair-default-handle-action
                          #'autopair-python-triple-quote-action))))

;; set executable file and db file
(setq pylookup-program (concat pylookup-dir "/pylookup.py"))
(setq pylookup-db-file (concat pylookup-dir "/pylookup.db"))

;; to speedup, just load it on demand
(autoload 'pylookup-lookup "pylookup"
  "Lookup SEARCH-TERM in the Python HTML indexes." t)
(autoload 'pylookup-update "pylookup"
  "Run pylookup-update and create the database at `pylookup-db-file'." t)

(global-set-key "\C-cp" 'pylookup-lookup)

;;; Custom mode definitions

(defun robocup-c++-mode ()
  "C++ mode made to fit the way I like it."
  (interactive)
  (c++-mode)
  (c-set-style "K&R")
  (which-func-mode 1)
  (setq indent-tabs-mode nil))

(defun robocup-c-mode ()
  "C mode made to fit the way I like it."
  (interactive)
  (c-mode)
  (c-set-style "K&R")
  (setq indent-tabs-mode nil))

(defun robocup-python-mode ()
  (interactive)
  (python-mode)
  (lambda-mode 1)
  (py-load-pymacs-p t)
;;  (flymake-mode t) TODO!
  (setq indent-tabs-mode nil))

(defun robocup-java-mode ()
  (setq indent-tabs-mode nil)
  (interactive)
  (java-mode))

(defun trip-js-mode()
  (interactive)
  (js-mode)
  (flymake-mode t)
  (setq c-basic-offset 4)
  (setq indent-tabs-mode nil))

(defun trip-css-mode()
  (interactive)
  (css-mode)
  (flymake-mode t))

;; TODO: generify so it can flush css/js/features too
(defun vm-save-hook()
  (interactive)
  (start-process "async-flush-velocity" "*Messages*" "tweak" "FLUSH_VELOCITY")
  (message "Flushed velocity"))

(defun trip-vm-mode()
  (interactive)
  (turn-on-vtl-mode)
  (auto-complete-mode t) ;; velocity doesn't have a major mode, so enable ac manually
  (message "* --[ Loading VTL syntax hilighting ]--")
  (setq c-basic-offset 2)
  (setq indent-tabs-mode nil)
  (add-hook 'after-save-hook 'vm-save-hook nil 'true))

;; keeps whitespace clean when it is already
(add-to-list 'load-path (expand-file-name "~/.emacs.d/ethan-wspace/lisp"))
(require 'ethan-wspace)
(global-ethan-wspace-mode 1)

;; vm-mode doesn't seem to do colors automatically even though it loads...
(global-set-key (kbd "C-x y") 'trip-vm-mode)

;; window navigation key bindings
(global-set-key "\C-xa" 'windmove-left)
(global-set-key "\C-xs" 'windmove-down)
(global-set-key "\C-xw" 'windmove-up)
(global-set-key "\C-xd" 'windmove-right)

(global-unset-key "\C-c\C-c")
(global-set-key "\C-c\C-c" 'comment-or-uncomment-region)

;; Set up home/end keys
(global-set-key [end] 'end-of-buffer)
(global-set-key [home] 'beginning-of-buffer)

;; git emacs package
;;(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/")
;;(autoload 'magit-status "magit" nil t)

;;; We set the robocup modes as default for the appropraite files
;;;
;;; To make this apply only in robocup directories add a path to the settings
;;; i.e. ("~/src/robocup/.*\\.cpp$" . robocup-c++-mode)
(setq auto-mode-alist (append '(("\\.cpp\\'" . robocup-c++-mode)
                                ("\\.cc\\'" . robocup-c++-mode)
                                ("\\.hpp\\'" . robocup-c++-mode)
                                ("\\.h\\'" . robocup-c++-mode)
                                ("\\.c\\'" . robocup-c-mode)
                                ("\\.py\\'" . robocup-python-mode)
                                ("\\.java\\'" . robocup-java-mode)
                                ("\\.css\\'" . css-mode)
                                ("\\.vm\\'" . trip-vm-mode)
                                ("\\.js\\'" . trip-js-mode)
                                ("\\.css\\'" . trip-css-mode)
                                ) auto-mode-alist))

;; Put autosave files (ie #foo#) in one place, *not*
;; scattered all over the file system!
(defvar autosave-dir
 (concat "/tmp/emacs_autosaves/" (user-login-name) "/"))

(make-directory autosave-dir t)

(defun auto-save-file-name-p (filename)
  (string-match "^#.*#$" (file-name-nondirectory filename)))

(defun make-auto-save-file-name ()
  (concat autosave-dir
   (if buffer-file-name
      (concat "#" (file-name-nondirectory buffer-file-name) "#")
    (expand-file-name
     (concat "#%" (buffer-name) "#")))))

;; Put backup files (ie foo~) in one place too. (The backup-directory-alist
;; list contains regexp=>directory mappings; filenames matching a regexp are
;; backed up in the corresponding directory. Emacs will mkdir it if necessary.)
(defvar backup-dir (concat "/tmp/emacs_backups/" (user-login-name) "/"))
(setq backup-directory-alist (list (cons "." backup-dir)))

(require 'auto-complete)
(global-auto-complete-mode t)
'(global-semantic-idle-completions-mode)

(define-key ac-complete-mode-map "\C-n" 'ac-next)
(define-key ac-complete-mode-map "\C-p" 'ac-previous)
(define-key ac-complete-mode-map "\t" 'ac-complete)
(define-key ac-complete-mode-map "\r" nil)
(setq ac-dwim t) ;; do what I mean mode

(require 'yasnippet-bundle)
(yas/initialize)
(yas/load-directory "~/.emacs.d/yasnippet/snippets")

(require 'desktop)
(desktop-save-mode 1) ;; auto saving
(setq desktop-restore-eager 4) ;; load the first 4 buffers at startup, lazy load rest

(defun my-desktop-save ()
    (interactive)
    ;; Don't call desktop-save-in-desktop-dir, as it prints a message.
    (if (eq (desktop-owner) (emacs-pid))
        (desktop-save desktop-dirname)))
(add-hook 'auto-save-hook 'my-desktop-save)

; sort ido filelist by mtime instead of alphabetically
  (add-hook 'ido-make-file-list-hook 'ido-sort-mtime)
  (add-hook 'ido-make-dir-list-hook 'ido-sort-mtime)
  (defun ido-sort-mtime ()
    (setq ido-temp-list
          (sort ido-temp-list
                (lambda (a b)
                  (time-less-p
                   (sixth (file-attributes (concat ido-current-directory b)))
                   (sixth (file-attributes (concat ido-current-directory a)))))))
    (ido-to-end  ;; move . files to end (again)
     (delq nil (mapcar
                (lambda (x) (and (string-match-p "^\\.." x) x))
                ido-temp-list))))

;; make option key meta
(setq mac-option-modifier 'meta)

(put 'upcase-region 'disabled nil)

;; disables menu bar and tool bart
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(desktop-load-locked-desktop (quote ask))
 '(desktop-path (quote ("." "~/.emacs.d/desktop" "~"))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

;; Load CEDET. Do this last so it screws the least amount of other things up when it barfs
;; See cedet/common/cedet.info for configuration details.
(setq semantic-load-turn-useful-things-on t)
(load-file "~/.emacs.d/cedet/common/cedet.el")

;; Enable EDE (Project Management) features
(global-ede-mode 1)

;; * This enables even more coding tools such as intellisense mode
;;   decoration mode, and stickyfunc mode (plus regular code helpers)
(semantic-load-enable-gaudy-code-helpers)
(global-semantic-idle-completions-mode)

;; * This enables the use of Exuberent ctags if you have it installed.
;;   If you use C++ templates or boost, you should NOT enable it.
;; (semantic-load-enable-all-exuberent-ctags-support)
;;   Or, use one of these two types of support.
;;   Add support for new languges only via ctags.
;; (semantic-load-enable-primary-exuberent-ctags-support)
;;   Add support for using ctags as a backup parser.
(semantic-load-enable-secondary-exuberent-ctags-support)

;; Enable SRecode (Template management) minor-mode.
;; (global-srecode-minor-mode 1)

;;(define-key (kbd <backtab>) 'semantic-ia-complete-symbol)

(defun my-cedet-hook ()
  (local-set-key [(control return)] 'semantic-ia-complete-symbol)
  (local-set-key "\C-c?" 'semantic-ia-complete-symbol-menu)
  (local-set-key "\C-c>" 'semantic-complete-analyze-inline)
  (local-set-key "\C-cp" 'semantic-analyze-proto-impl-toggle)
  (local-set-key "\C-c f" 'semantic-complete-jump)
  (local-set-key "\C-c b" 'semantic-mrub-switch-tag)
  (local-set-key "." 'semantic-complete-self-insert)
  (local-set-key ">" 'semantic-complete-self-insert)
  )
(add-hook 'c-mode-common-hook 'my-cedet-hook)

(require 'semantic-ia)
(require 'semantic-gcc)
(semantic-mru-bookmark-mode)
