;; -*- mode: Scheme; tab-width: 2; -*- ;;

;; {{{ Data types

(foreign-declare
	"#include <iup.h>\n"
	"#include <iup_scintilla.h>\n")
	
(include "iup-types.scm")

;; }}}

;; {{{ Scintilla text editor control

(define scintilla
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupScintilla")))

;; }}}

;; {{{ Library setup

(foreign-code "IupScintillaOpen();")

;; }}}
