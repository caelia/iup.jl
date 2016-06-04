;; -*- mode: Scheme; tab-width: 2; -*- ;;

(module iup-dynamic
	(iup-available? iup-dynamic-require)
	(import scheme chicken)

(define (iup-dynamic-require sym)
	(eval `(begin (require-extension iup) ,sym)))

(define (iup-available?)
	(condition-case ((iup-dynamic-require 'iup-version))
		[(exn) #f]))

)
