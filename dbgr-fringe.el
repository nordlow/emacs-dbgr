;; Bitmap for breakpoint in fringe
;; (define-fringe-bitmap 'breakpoint
;;  "\x3c\x7e\xff\xff\xff\xff\x7e\x3c")

;; Bitmap for hollow overlay-arrow in fringe
;; (define-fringe-bitmap 'hollow-right-triangle
;;  "\xe0\x90\x88\x84\x84\x88\x90\xe0")

;; FIXME: Figure out how to do this as a macro.

(defface dbgr-overlay-arrow1
  '((t
     :foreground "black"
     :weight bold))
  "Fringe face for current position."
  :group 'dbgr)

(defface dbgr-overlay-arrow2
  '((t
     :foreground "gray"
     :weight bold))
  "Fringe face for position one back in fringe."
  :group 'dbgr)

(defface dbgr-overlay-arrow3
  '((t
     :foreground "gainsboro"
     :weight bold))
  "Fringe face for position two back in fringe."
  :group 'dbgr)


(defvar dbgr-overlay-arrow1 nil
  "Overlay arrow variable which contains the most recent debugger
position.")
(defvar dbgr-overlay-arrow2 nil
  "Overlay arrow variable which contains the 2nd most recent debugger
position.")
(defvar dbgr-overlay-arrow3 nil
  "Overlay arrow variable which contains the 3rd most recent debugger
position.")

(eval-when-compile (require 'cl))

;; Loop to set up fringe position markers. 

;; Here is an example of what each iteration does:
;;
;;   (make-local-variable 'dbgr-overlay-arrow1) ;; or 2, or 3
;;   (put 'dbgr-overlay-arrow1 'overlay-arrow-string "=>" ;; or "2>", or ">3"
;;   (define-fringe-bitmap 'dbgr-overlay-arrow1 "\xc0...")
;;   (add-to-list 'overlay-arrow-variable-list 'dbgr-overlay-arrow1)

(dolist (pair 
	 '( ("3" . "3>")  ("2" . "2>") ("1" . "=>")))
  (let ((arrow-symbol (intern (concat "dbgr-overlay-arrow" (car pair))))
	(arrow-bitmap (intern (concat "dbgr-right-triangle" (car pair))))
	(arrow-face (intern (concat "dbgr-overlay-arrow" (car pair)))))
    (make-local-variable arrow-symbol)
    (put arrow-symbol 'overlay-arrow-string (cdr pair))
    (if (window-system)
	(progn
	  (define-fringe-bitmap arrow-bitmap "\xc0\xf0\xf8\xfc\xfc\xf8\xf0\xc0")
	  (put arrow-symbol 'overlay-arrow-bitmap arrow-bitmap)
	  (set-fringe-bitmap-face arrow-bitmap arrow-face)))
    (add-to-list 'overlay-arrow-variable-list arrow-symbol)))

(defun dbgr-fringe-set-arrow (overlay-arrow marker)
  "Set the fringe indicator or overlay arrow to MARKER. This is done
for example to indicate a debugger position."
  (with-current-buffer (marker-buffer marker)
    (save-excursion
      (save-restriction
	(widen)
	(goto-char (marker-position marker))
	(beginning-of-line)
	(set overlay-arrow (point-marker))))))


(defun dbgr-fringe-history-set (loc-hist)
  "Set arrows on the last positions we have stopped on."
  ;; FIXME DRY somehow
  (let ((loc1 (dbgr-loc-hist-item-at loc-hist -1))
	(loc2 (dbgr-loc-hist-item-at loc-hist -2))
	(loc3 (dbgr-loc-hist-item-at loc-hist -3)))
    (if loc3
	(let ((src-marker (dbgr-loc-marker loc3)))
	  (dbgr-fringe-set-arrow 'dbgr-overlay-arrow3 src-marker)))
    (if loc2
	(let ((src-marker (dbgr-loc-marker loc2)))
	  (dbgr-fringe-set-arrow 'dbgr-overlay-arrow2 src-marker)))
    (if loc1
	(let ((src-marker (dbgr-loc-marker loc1)))
	  (dbgr-fringe-set-arrow 'dbgr-overlay-arrow1 src-marker)))))

(defun dbgr-fringe-history-unset ()
  "Unset all fringe-history arrows"
  (setq dbgr-overlay-arrow1 nil)
  (setq dbgr-overlay-arrow2 nil)
  (setq dbgr-overlay-arrow3 nil))

(provide 'dbgr-fringe)
