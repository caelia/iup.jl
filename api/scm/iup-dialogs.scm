;; -*- mode: Scheme; tab-width: 2; -*- ;;

;; {{{ Data types

(foreign-declare
	"#include <iup.h>\n")
	
(include "iup-types.scm")

;; }}}

;; {{{ Standard dialogs

(define file-dialog
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupFileDlg")))

(define message-dialog
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupMessageDlg")))

(define color-dialog
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupColorDlg")))

(define font-dialog
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupFontDlg")))

(define progress-dialog
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupProgressDlg")))

(define layout-dialog
	(make-constructor-procedure
	  (foreign-lambda nonnull-ihandle "IupLayoutDialog" ihandle)
		#:apply-args (optional-args [dialog #f])))

(define element-properties-dialog
	(make-constructor-procedure
	  (foreign-lambda nonnull-ihandle "IupElementPropertiesDialog" nonnull-ihandle)))

;; }}}
