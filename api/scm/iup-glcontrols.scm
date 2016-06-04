;; -*- mode: Scheme; tab-width: 2; -*- ;;

;; {{{ Data types

(foreign-declare
	"#include <iup.h>\n"
	"#include <iupglcontrols.h>\n")
	
(include "iup-types.scm")

;; }}}

;; {{{ GLCanvasBox and embedded controls

(define glcanvasbox
  (make-constructor-procedure
  	(foreign-lambda* nonnull-ihandle ([ihandle-list handles]) "C_return(IupGLCanvasBoxv((Ihandle **)handles));")
  	#:apply-args list))

(define glsubcanvas
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupGLSubCanvas")))

(define glframe
  (make-constructor-procedure
	  (foreign-lambda nonnull-ihandle "IupGLFrame" ihandle)))

(define glexpander
  (make-constructor-procedure
	  (foreign-lambda nonnull-ihandle "IupGLExpander" ihandle)))

(define glscrollbox
  (make-constructor-procedure
	  (foreign-lambda nonnull-ihandle "IupGLScrollBox" ihandle)))

(define glsizebox
  (make-constructor-procedure
	  (foreign-lambda nonnull-ihandle "IupGLSizeBox" ihandle)))

(define glseparator
  (make-constructor-procedure
	  (foreign-lambda nonnull-ihandle "IupGLSeparator")))

(define gllabel
  (make-constructor-procedure
	  (foreign-lambda nonnull-ihandle "IupGLLabel" c-string)
		#:apply-args (optional-args [title #f])))

(define gllink
  (make-constructor-procedure
	  (foreign-lambda nonnull-ihandle "IupGLLink" c-string c-string)
  	#:apply-args (optional-args [url #f] [title #f])))

(define glbutton
  (make-constructor-procedure
	  (foreign-lambda nonnull-ihandle "IupGLButton" c-string)
  	#:apply-args (optional-args [title #f])))

(define gltoggle
  (make-constructor-procedure
	  (foreign-lambda nonnull-ihandle "IupGLToggle" c-string)
  	#:apply-args (optional-args [title #f])))

(define glvaluator
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupGLVal")))

(define glprogress-bar
  (make-constructor-procedure
	  (foreign-lambda nonnull-ihandle "IupGLProgressBar")))

;; }}}

;; {{{ Library setup

(let ([status (foreign-value "IupGLControlsOpen()" istatus)])
	(case status
		[(#t ignore) (void)]
		[else        (error 'iup "failed to initialize library (~s)" status)]))

;; }}}
