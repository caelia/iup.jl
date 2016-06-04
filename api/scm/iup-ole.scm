;; -*- mode: Scheme; tab-width: 2; -*- ;;

;; {{{ Data types

(foreign-declare
	"#include <iup.h>\n"
	"#include <iupole.h>\n")
	
(include "iup-types.scm")

;; }}}

;; {{{ Windows OLE control

(define ole-control
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupOleControl" nonnull-c-string)))

;; }}}

;; {{{ Library setup

(let ([status (foreign-value "IupOleControlOpen()" istatus)])
	(case status
		[(#t ignore) (void)]
		[else        (error 'iup "failed to initialize library (~s)" status)]))

;; }}}
