;; -*- mode: Scheme; tab-width: 2; -*- ;;

;; {{{ Data types

(foreign-declare
	"#include <iup.h>\n"
	"#include <iupgl.h>\n")
	
(include "iup-types.scm")

;; }}}

;; {{{ GLCanvas control

(define glcanvas
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupGLCanvas" iname/upcase)
  	#:apply-args (optional-args [action #f])))

;; }}}

;; {{{ OpenGL context functions

(define call-with-glcanvas
  (letrec ([glcanvas-make-current (foreign-lambda void "IupGLMakeCurrent" nonnull-ihandle)]
           [glcanvas-swap-buffers (foreign-lambda void "IupGLSwapBuffers" nonnull-ihandle)]
           [glcanvas-wait (foreign-lambda void "IupGLWait" bool)])
    (lambda (handle proc #!key [swap? #f] [sync? #f])
      (dynamic-wind
       (lambda ()
         (glcanvas-make-current handle)
         (when sync? (glcanvas-wait #f)))
       (lambda ()
         (proc handle))
       (lambda ()
         (when swap? (glcanvas-swap-buffers handle))
         (when sync? (glcanvas-wait #t)))))))

(define glcanvas-is-current?
	(foreign-lambda bool "IupGLIsCurrent" nonnull-ihandle))

(define glcanvas-palette-set!
	(foreign-lambda void "IupGLPalette" nonnull-ihandle int float float float))

(define glcanvas-font-set!
	(foreign-lambda void "IupGLUseFont" nonnull-ihandle int int int))

;; }}}

;; {{{ Library setup

(foreign-code "IupGLCanvasOpen();")

;; }}}
