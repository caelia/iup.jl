;; -*- mode: Scheme; tab-width: 2; -*- ;;

;; {{{ Data types

(foreign-declare
	"#include <iup.h>\n"
	"#include <iupweb.h>\n")
	
(include "iup-types.scm")

;; }}}

;; {{{ Web browser control

(define web-browser
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupWebBrowser")))

;; }}}

;; {{{ Library setup

(foreign-code "IupWebBrowserOpen();")

;; }}}
