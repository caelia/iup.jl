;; -*- mode: Scheme; tab-width: 2; -*- ;;

;; {{{ Data types

(foreign-declare
	"#include <iup.h>\n"
	"#include <iupcontrols.h>\n")

(cond-expand
 [disable-iup-matrixex]
 [else
	(foreign-declare
	 "#include <iupmatrixex.h>\n")])
	
(include "iup-types.scm")

;; }}}

;; {{{ Standard controls

(define canvas
	(make-constructor-procedure
		(foreign-lambda nonnull-ihandle "IupCanvas" iname/upcase)
		#:apply-args (optional-args [action #f])))

(define frame
	(make-constructor-procedure
		(foreign-lambda nonnull-ihandle "IupFrame" ihandle)
		#:apply-args (optional-args [child #f])))

(define tabs
  (make-constructor-procedure
  	(foreign-lambda* nonnull-ihandle ([ihandle-list handles])
  		"C_return(IupTabsv((Ihandle **)handles));")
  	#:apply-args list))

(define label
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupLabel" c-string)
  	#:apply-args (optional-args [title #f])))

(define link
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupLink" c-string c-string)
  	#:apply-args (optional-args [url #f] [title #f])))

(define button
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupButton" c-string iname/upcase)
  	#:apply-args (optional-args [title #f] [action #f])))

(define toggle
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupToggle" c-string iname/upcase)
  	#:apply-args (optional-args [title #f] [action #f])))

(define spin
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupSpin")))

(define spinbox
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupSpinbox" ihandle)))

(define valuator
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupVal" c-string)
  	#:apply-args (optional-args [type "HORIZONTAL"])))

(define textbox
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupText" iname/upcase)
  	#:apply-args (optional-args [action #f])))

(define listbox
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupList" iname/upcase)
  	#:apply-args (optional-args [action #f])))

(define treebox
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupTree")))

(define progress-bar
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupProgressBar")))

;; }}}

;; {{{ Extended controls

(define matrix
  (make-constructor-procedure
	  (lambda (action extended?)
			(let ([handle ((foreign-lambda nonnull-ihandle "IupMatrix" iname/upcase) action)])
				(cond-expand
				 [disable-iup-matrixex
					handle]
				 [else
					(when extended?
						((foreign-lambda void "IupMatrixExInit" nonnull-ihandle) handle))
					handle])))
  	#:apply-args (optional-args [action #f] [extended? #t])))

(define matrix-listbox
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupMatrixList")))

(define cells
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupCells")))

(define color-bar
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupColorbar")))

(define color-browser
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupColorBrowser")))

(define dial
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupDial" c-string)
  	#:apply-args (optional-args [type "HORIZONTAL"])))

;; }}}

;; {{{ Library setup

(let ([status (foreign-value "IupControlsOpen()" istatus)])
	(case status
		[(#t ignore) (void)]
		[else        (error 'iup "failed to initialize library (~s)" status)]))

(cond-expand
 [disable-iup-matrixex]
 [else
	(foreign-code "IupMatrixExOpen();")])

;; }}}
