;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; refresh' after modifying this file!

;; These are used for a number of things, particularly for GPG configuration,
;; some email clients, file templates and snippets.
(setq user-full-name "Oliver Frank"
      user-mail-address "oliverfrank321@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; test
(setq doom-font (font-spec :family "Hack Nerd Font" :size 16)
      doom-variable-pitch-font (font-spec :family "Source Sans Pro" :size 16 :height 160))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. These are the defaults.
(setq doom-theme 'doom-gruvbox)

;; Set Omnisharp-Roslyn Executable

;; Here are some additional functions/macros that could help you configure Doom: ;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', where Emacs
;;   looks when you load packages with `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

;; Custom stuff
(setq gdscript-flycheck-linter t)
(require 'gdscript-mode)

(require 'graphql-mode)
(require 'mmm-mode)

(mmm-add-classes
    '((js-graphql
          :submode graphql-mode
          :face mmm-declaration-submode-face
          :front "[^a-zA-Z]graphql`" ;; regex to find the opening tag
          :back "`"))) ;; regex to find the closing tag
(mmm-add-mode-ext-class 'rjsx-mode nil 'js-graphql)
(setq mmm-global-mode 'maybe)
;; Optional configuration that hides the background color for a highlighted block
;; I find it useful for debugging emacs, but when actually coding I dont want so much emphasis on submodes
(setq mmm-submode-decoration-level 1)

;; Org Config
;; If you intend to use org, it is recommended you change this!
(setq org-directory "~/org/")
(setq org-hide-emphasis-markers t)
(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

(defun nolinum()
  (setq display-line-numbers nil))
(add-hook 'org-mode-hook 'nolinum)

;; pitch
(custom-theme-set-faces
 'user
 `(variable-pitch            ((t (:family "Source Sans Pro" :size 16 :height 160))))
 `(fixed-pitch               ((t (:family "Hack Nerd Font" :size 16))))
 `(org-level-8               ((t (:family "Source Sans Pro" :inherit default :weight bold :height 1))))
 `(org-level-7               ((t (:family "Source Sans Pro" :inherit default :weight bold :height 1))))
 `(org-level-6               ((t (:family "Source Sans Pro" :inherit default :weight bold :height 1))))
 `(org-level-5               ((t (:family "Source Sans Pro" :inherit default :weight bold :height 1))))
 `(org-level-4               ((t (:family "Source Sans Pro" :inherit default :weight bold :height 1.1))))
 `(org-level-3               ((t (:family "Source Sans Pro" :inherit default :weight bold :height 1.25))))
 `(org-level-2               ((t (:family "Source Sans Pro" :inherit default :weight bold :height 1.5))))
 `(org-level-1               ((t (:family "Source Sans Pro" :inherit default :weight bold :height 1.75))))
 `(org-document-title        ((t (:family "Source Sans Pro" :inherit default :weight bold :height 2.0))))
 `(org-block                 ((t (:inherit fixed-pitch))))
 `(org-code                  ((t (:inherit (shadow fixed-pitch)))))
 `(org-document-info         ((t (:foreground "dark orange"))))
 `(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
 `(org-indent                ((t (:inherit (org-hide fixed-pitch)))))
 `(org-link                  ((t (:foreground "royal blue" :underline t))))
 `(org-meta-line             ((t (:inherit (font-lock-comment-face fixed-pitch)))))
 `(org-property-value        ((t (:inherit fixed-pitch))) t)
 `(org-special-keyword       ((t (:inherit (font-lock-comment-face fixed-pitch)))))
 `(org-table                 ((t (:inherit fixed-pitch :foreground "#83a598"))))
 `(org-tag                   ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
 `(org-verbatim              ((t (:inherit (shadow fixed-pitch))))))

(add-hook 'org-mode-hook 'visual-line-mode)
(add-hook 'org-mode-hook 'variable-pitch-mode)



(after! company-lsp
  (add-to-list 'company-lsp-filter-candidates '(gdscript . t))
  (setq company-lsp-cache-candidates 'auto)

  (defun company-lsp--on-completion (response prefix)
    "Handle completion RESPONSE.

PREFIX is a string of the prefix when the completion is requested.

Return a list of strings as the completion candidates."
    (let* ((incomplete (and (hash-table-p response) (gethash "isIncomplete" response)))
           (items (cond ((hash-table-p response) (gethash "items" response))
                        ((sequencep response) response)))
           (candidates (mapcar (lambda (item)
                                 (company-lsp--make-candidate item prefix))
                               (lsp--sort-completions items)))
           (server-id (lsp--client-server-id (lsp--workspace-client lsp--cur-workspace)))
           (should-filter (or (eq company-lsp-cache-candidates 'auto)
                              (and (null company-lsp-cache-candidates)
                                   (company-lsp--get-config company-lsp-filter-candidates server-id)))))
      (when (null company-lsp--completion-cache)
        (add-hook 'company-completion-cancelled-hook #'company-lsp--cleanup-cache nil t)
        (add-hook 'company-completion-finished-hook #'company-lsp--cleanup-cache nil t))
      (when (eq company-lsp-cache-candidates 'auto)
        ;; Only cache candidates on auto mode. If it's t company caches the
        ;; candidates for us.
        (company-lsp--cache-put prefix (company-lsp--cache-item-new candidates incomplete)))
      (if should-filter
          (company-lsp--filter-candidates candidates prefix)
        candidates))))


;; If you want to change the style of line numbers, change this to `relative' or
;; `nil' to disable it:
(setq display-line-numbers-type t)

(after! omnisharp
  (setq omnisharp-server-executable-path "~/.doom.d/omnisharp-mono/omnisharp.sh"))

(after! gradle-mode
  (gradle-mode 1))

;; (after! lsp-mode
;;   (setq lsp-log-io t))
