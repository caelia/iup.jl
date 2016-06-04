;; -*- mode: Scheme; tab-width: 2; -*- ;;

;; {{{ Data types

(foreign-declare
	"#include <iup.h>\n"
	"#include <iup_config.h>\n")
	
(include "iup-types.scm")

;; }}}

;; {{{ Configuration component

(define config
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupConfig")))

(define (config-error location handle status)
	(let ([message
				 (case status
					 [(-1) "Error opening configuration file"]
					 [(-2) "Error accessing configuration file"]
					 [(-3) "Error locating configuration file"]
					 [else "Error concerning configuration file"])])
		(raise
		 (make-composite-condition
			(make-property-condition
			 'exn 'message message 'arguments (list handle) 'location location)
			(make-property-condition
			 'i/o)
			(make-property-condition
			 'config 'status status)))))

(define (config-load! handle)
	(let ([status ((foreign-lambda int "IupConfigLoad" nonnull-ihandle) handle)])
		(unless (zero? status) (config-error 'config-load! handle status))))

(define (config-save! handle)
	(let ([status ((foreign-lambda int "IupConfigSave" nonnull-ihandle) handle)])
		(unless (zero? status) (config-error 'config-save! handle status))))

;; }}}

;; {{{ Configured Dialog Positions

(define config-dialog-show
	(foreign-safe-lambda void "IupConfigDialogShow" nonnull-ihandle nonnull-ihandle nonnull-c-string))

(define config-dialog-update!
	(foreign-safe-lambda void "IupConfigDialogClosed" nonnull-ihandle nonnull-ihandle nonnull-c-string))

;; }}}

;; {{{ Configured Recent Files

(define-external (recent_action_entry [ihandle handle]) istatus
	(call-with-current-continuation
	 (lambda (return)
		 (let ([r 'continue])
			 (dynamic-wind
				 void
				 (lambda ()
					 (and-let* ([group (and handle (parent handle))]
											[action (callback group 'action)])
						 (handle-exceptions exn
							 (print-error-message exn (current-error-port) "Error: in recent action callback")
							 (set! r (action handle)))))
				 (lambda ()
					 (return r)))))))

(define config-recent-menu
	(make-constructor-procedure
	  (lambda (handle max-recent)
			(let ([menu (foreign-value "IupMenu(NULL)" nonnull-ihandle)])
				((foreign-lambda* void ([nonnull-ihandle handle] [nonnull-ihandle menu] [int max_recent])
					 "IupConfigRecentInit(handle, menu, recent_action_entry, max_recent);")
				 handle menu max-recent)
				menu))))

(define config-recent-update!
	(foreign-safe-lambda void "IupConfigRecentUpdate" nonnull-ihandle nonnull-c-string))

;; }}}
