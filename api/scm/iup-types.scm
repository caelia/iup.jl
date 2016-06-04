;; -*- mode: Scheme; tab-width: 2; -*- ;;

(define-foreign-type ihandle (c-pointer "Ihandle")
	(ihandle->pointer #f)
	(pointer->ihandle #f))

(define-foreign-type ihandle-list nonnull-pointer-vector
	ihandle-list->pointer-vector)

(define-foreign-type nonnull-ihandle (nonnull-c-pointer "Ihandle")
	(ihandle->pointer #t)
	(pointer->ihandle #t))

(define-foreign-type istatus int
	istatus->integer
	integer->istatus)

(define-foreign-type iname/upcase c-string
	(iname->string 'upcase)
	(string->iname 'upcase))

(define-foreign-type iname/downcase c-string
	(iname->string 'downcase)
	(iname->string 'downcase))
