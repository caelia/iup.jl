# ;; -*- mode: Scheme; tab-width: 2; -*- ;;
#
# ;; {{{ Data types
#
# (foreign-declare
# 	"#include <callback.h>\n"
# 	"#include <locale.h>\n"
# 	"#include <im.h>\n"
# 	"#include <im_binfile.h>\n"
# 	"#include <iup.h>\n"
# 	"#include <iupim.h>\n"
# 	"typedef struct Iclass_ Iclass;\n"
# 	"struct Ihandle_ { char sig[4]; Iclass *iclass; /* ... */ } ;\n"
# 	"extern char *iupClassCallbackGetFormat(Iclass *iclass, const char *name);\n")
#
# (define *ihandle-tag* "Ihandle")
# (define ihandle? (cut tagged-pointer? <> *ihandle-tag*))
#
# (define (ihandle->pointer nonnull?)
# 	(if nonnull?
# 		(lambda (handle)
# 			(ensure ihandle? handle)
# 			handle)
# 		(lambda (handle)
# 			(ensure (disjoin not ihandle?) handle)
# 			handle)))
#
# (define (pointer->ihandle nonnull?)
# 	(if nonnull?
# 		(lambda (handle)
# 			(ensure pointer? handle)
# 			(tag-pointer handle *ihandle-tag*))
# 		(lambda (handle)
# 			(and handle (tag-pointer handle *ihandle-tag*)))))
#
# # (define (ihandle-list->pointer-vector lst)
# # 	(let ([ptrs (make-pointer-vector (add1 (length lst)) #f)])
# # 		(do-ec (:list handle (index i) lst)
# # 			(begin
# # 				(ensure ihandle? handle)
# # 				(pointer-vector-set! ptrs i handle)))
# # 		ptrs))
#
# (define (istatus->integer status)
# 	(case status
# 		[(error)                 +1]
# 		[(opened invalid ignore) -1]
# 		[(default)               -2]
# 		[(close #f)              -3]
# 		[(continue)              -4]
# 		[else                    (if (integer? status) status 0)]))
#
# (define (integer->istatus status)
# 	(case status
# 		[(+1) 'error]
# 		[( 0) #t]
# 		[(-1) 'ignore]
# 		[(-2) 'default]
# 		[(-3) #f]
# 		[(-4) 'continue]
# 		[else status]))
#
# (define (iname->string default-case)
# 	(let ([change-case
# 	       (case default-case
# 	       	 [(upcase)   string-upcase]
# 	       	 [(downcase) string-downcase]
# 	       	 [else       (error 'iname->string "unsupported default case" default-case)])])
# 		(lambda (name)
# 			(cond
# 				[(or (not name) (string? name))
# 				 name]
# 				[(symbol? name)
# 				 (change-case (string-translate (symbol->string name) #\- #\_))]
# 				[else
# 				 (error 'iname->string "bad name" name)]))))
#
# (define (string->iname default-case)
# 	(let ([specials
# 	       (irregex
# 	       	 (case default-case
# 	       	 	 [(upcase)   "[-a-z]"]
# 	       	 	 [(downcase) "[-A-Z]"]
# 	       	 	 [else       (error 'string->iname "unsupported default case" default-case)]))])
# 		(lambda (name)
# 			(cond
# 				[(or (not name) (irregex-search specials name))
# 				 name]
# 				[else
# 				 (string->symbol (string-downcase (string-translate name #\_ #\-)))]))))
#
# (include "iup-types.scm")
#
# ;; }}}
#
# ;; {{{ Support macros and functions
#
# (define-syntax :children
# 	(syntax-rules ()
# 		[(:children cc child handle)
# 		 (:do cc ([child (child-ref handle 0)]) child ((sibling child)))]))
#
# (define-syntax optional-args
# 	(syntax-rules ()
# 		[(optional-args [name default] ...)
# 		 (lambda (args) (let-optionals args ([name default] ...) (list name ...)))]))
#
# (define ((make-constructor-procedure proc #!key [apply-args values]) . args)
# 	(let more ([keys '()] [key-args '()] [pos-args '()] [rest args])
# 		(cond
# 			[(null? rest)
# 			 (let ([handle (apply proc (apply-args (reverse! pos-args)))])
# 			 	 (do-ec (:parallel (:list key keys) (:list arg key-args))
# 			 	 	 ((if (procedure? arg) callback-set! attribute-set!) handle key arg))
# 			 	 handle)]
# 			[(keyword? (car rest))
# 			 (more
# 			 	 (cons (car rest) keys) (cons (cadr rest) key-args) pos-args
# 			 	 (cddr rest))]
# 			[else
# 			 (more
# 			 	 keys key-args (cons (car rest) pos-args)
# 			 	 (cdr rest))])))
#
# ;; }}}
#
# ;; {{{ System functions
#
# (define iup-version
# 	(foreign-lambda c-string "IupVersion"))
function version()
	ccall((:IupVersion, "libiup"), AbstractString, ())
end

# (define load/led
# 	(letrec ([load/raw (foreign-lambda c-string "IupLoad" c-string)])
# 		(lambda (file)
# 			(and-let* ([status (load/raw file)])
# 				(error 'load/led status))
	# 			(void)))
# 	(letrec ([load/raw (foreign-lambda c-string "IupLoad" c-string)])
# 		(lambda (file)
# 			(and-let* ([status (load/raw file)])
# 				(error 'load/led status))
# 			(void))))

function load_led(filename::AbstractString)
	ccall((:IupLoad, "libiup"), AbstractString, (AbstractString,), filename)
end

# ;; }}}
#
# ;; {{{ Attribute functions

# (define attribute-set!
#   (letrec ([set/string! (foreign-safe-lambda void "IupStoreAttribute" ihandle iname/upcase c-string)]
#            [set/handle! (foreign-safe-lambda void "IupSetAttributeHandle" ihandle iname/upcase ihandle)])
#     (lambda (handle name value)
#     	(cond
#     		[(or (not value) (string? value))
#          (set/string! handle name value)]
#         [(ihandle? value)
#          (set/handle! handle name value)]
#         [(boolean? value)
#          (set/string! handle name (if value "YES" "NO"))]
#         [else
#          (set/string! handle name (->string value))]))))

# name is supposed to be of type iname/upcase - however, that seems to be an alias for c-string
function attribute_set(handle::IHandle, name::AbstractString, value::AbstractString)
	ccall((:IupStoreAttribute), Void, (IHandle, IName, AbstractString), handle, name, value)
end

function attribute_set(handle::IHandle, name::AbstractString)
	attribute_set(handle, name, "")
end

function attribute_set(handle::IHandle, name::AbstractString, value::IHandle)
	ccall((:IupSetAttributeHandle), Void, (IHandle, IName, IHandle), handle, name, value)
end

function attribute_set(handle::IHandle, name::AbstractString, value::Boolean)
	if value
		attribute_set(handle, name, "YES")
	else
		attribute_set(handle, name, "NO")
	end
end

function attribute_set(handle::IHandle, name::AbstractString, value)
	attribute_set(handle, name, string(value))
end

#(define attribute-reset!
# 	(foreign-safe-lambda void "IupResetAttribute" ihandle iname/upcase))

function attribute_reset(handle::IHandle, name::AbstractString)
	ccall((:IupResetAttribute, "libiup"), Void, (IHandle, AbstractString), handle, name)
end

(define attribute
  (getter-with-setter
  	(foreign-safe-lambda c-string "IupGetAttribute" ihandle iname/upcase)
  	attribute-set!))

(define attributes
	(foreign-primitive scheme-object ([ihandle handle])
		"int n = IupGetAllAttributes(handle, NULL, 0);"
		"if (n > 0) {"
		"  char **buf = (char **) alloca(n * sizeof(char *));"
		"  if (IupGetAllAttributes(handle, buf, n) == n) {"
		"    int i, m = C_SIZEOF_LIST(n);"
		"    for (i = 0; i < n; ++i) m += C_SIZEOF_STRING(strlen(buf[i]));"
		"    C_word *mrk = C_alloc(m), lst = C_SCHEME_END_OF_LIST;"
		"    for (i = n-1; i >= 0; --i) lst = C_pair(&mrk, C_string2(&mrk, buf[i]), lst);"
		"    C_return(lst);"
		"  }"
		"}"
		"C_return(C_SCHEME_END_OF_LIST);"))

(define handle-name-set!
	(letrec ([handle-set! (foreign-lambda ihandle "IupSetHandle" iname/downcase ihandle)])
		(lambda (handle name)
			(handle-set! (or name (handle-name handle)) (and name handle)))))

(define handle-name
  (getter-with-setter
  	(foreign-lambda iname/downcase "IupGetName" nonnull-ihandle)
  	handle-name-set!))

(define handle-ref
	(foreign-lambda ihandle "IupGetHandle" iname/downcase))

;; }}}

;; {{{ Event functions

(define main-loop
	(letrec ([loop (foreign-safe-lambda istatus "IupMainLoop")])
		(lambda ()
			(let ([status (loop)])
				(case status
					[(#t) (void)]
					[else (error 'main-loop (format "error in IUP main loop (~s)" status))])))))

(define main-loop-step
  (letrec ([loop-step (foreign-safe-lambda istatus "IupLoopStep")]
           [loop-step/wait (foreign-safe-lambda istatus "IupLoopStepWait")])
    (lambda (poll?)
      (let ([status ((if poll? loop-step loop-step/wait))])
        (case status
          [(error) (error 'main-loop-step "error in IUP main loop")]
          [else    status])))))

(define main-loop-level
	(foreign-lambda int "IupMainLoopLevel"))

(define main-loop-exit
	(foreign-lambda void "IupExitLoop"))

(define main-loop-flush
	(foreign-safe-lambda void "IupFlush"))

(define make-wrapper
	(let ([make-wrapper/data
				 (foreign-lambda* c-pointer ([c-pointer data])
					 "C_return(alloc_callback(&callback_entry, data));")])
		(lambda (id)
			(make-wrapper/data (address->pointer id)))))

(define wrapper-id
	(let ([wrapper-data
				 (foreign-lambda* c-pointer ([c-pointer proc])
					 "C_return((proc && is_callback(proc) ? callback_data(proc) : NULL));")])
		(lambda (proc)
			(cond
			 [(wrapper-data proc) => pointer->address]
			 [else #f]))))

(define wrapper-destroy!
	(foreign-lambda void "free_callback" c-pointer))

(define-values (registry-ref registry-add! registry-remove! registry-clear!)
	(let ([registry (make-hash-table = number-hash)]
				[id-range (fxshr most-positive-fixnum 1)])
		(values
		 (lambda (id)
			 (cdr (hash-table-ref registry id)))
		 (lambda (handle data)
			 (let retry ()
				 (let ([id (fxior (fxshl (random id-range) 1) 1)])
					 (if (hash-table-exists? registry id)
							 (retry)
							 (let ([proc (make-wrapper id)])
								 (hash-table-set!
									registry id
									(cons proc data))
								 (hash-table-update!/default
									registry (pointer->address handle)
									(cut cons id <>) '())
								 proc)))))
		 (lambda (handle proc)
			 (cond
				[(wrapper-id proc)
				 => (lambda (id)
							(hash-table-update!/default
							 registry (pointer->address handle)
							 (cut delete id <> =) '())
							(hash-table-delete! registry id)
							(wrapper-destroy! proc))]))
		 (lambda (handle)
			 (let* ([key (pointer->address handle)]
							[ids (hash-table-ref/default registry key '())])
				 (hash-table-delete! registry key)
				 (do-ec (:list id ids)
					 (let ([proc (car (hash-table-ref registry id))])
						 (hash-table-delete! registry id)
						 (wrapper-destroy! proc))))))))

(define-external (callback_entry [c-pointer cid] [c-pointer frame]) void
	(define frame-start/ubyte!
		(foreign-lambda* void ([c-pointer frame]) "va_start_uchar((va_alist)frame);"))
	(define frame-start/int!
		(foreign-lambda* void ([c-pointer frame]) "va_start_int((va_alist)frame);"))
	(define frame-start/float!
		(foreign-lambda* void ([c-pointer frame]) "va_start_float((va_alist)frame);"))
	(define frame-start/double!
		(foreign-lambda* void ([c-pointer frame]) "va_start_double((va_alist)frame);"))
	(define frame-start/pointer!
		(foreign-lambda* void ([c-pointer frame]) "va_start_ptr((va_alist)frame, void *);"))

	(define frame-arg/ubyte!
		(foreign-lambda* unsigned-byte ([c-pointer frame]) "C_return(va_arg_uchar((va_alist)frame));"))
	(define frame-arg/int!
		(foreign-lambda* int ([c-pointer frame]) "C_return(va_arg_int((va_alist)frame));"))
	(define frame-arg/float!
		(foreign-lambda* float ([c-pointer frame]) "C_return(va_arg_float((va_alist)frame));"))
	(define frame-arg/double!
		(foreign-lambda* double ([c-pointer frame]) "C_return(va_arg_double((va_alist)frame));"))
	(define frame-arg/string!
		(foreign-lambda* c-string ([c-pointer frame]) "C_return(va_arg_ptr((va_alist)frame, char *));"))
	(define frame-arg/pointer!
		(foreign-lambda* c-pointer ([c-pointer frame]) "C_return(va_arg_ptr((va_alist)frame, void *));"))
	(define frame-arg/handle!
		(foreign-lambda* ihandle ([c-pointer frame]) "C_return(va_arg_ptr((va_alist)frame, Ihandle *));"))

	(define frame-return/ubyte!
		(foreign-lambda* void ([c-pointer frame] [unsigned-byte ret]) "va_return_uchar((va_alist)frame, ret);"))
	;(define frame-return/int!
	;	(foreign-lambda* void ([c-pointer frame] [int ret]) "va_return_int((va_alist)frame, ret);"))
	(define frame-return/status!
		(foreign-lambda* void ([c-pointer frame] [istatus ret]) "va_return_int((va_alist)frame, ret);"))
	(define frame-return/float!
		(foreign-lambda* void ([c-pointer frame] [float ret]) "va_return_float((va_alist)frame, ret);"))
	(define frame-return/double!
		(foreign-lambda* void ([c-pointer frame] [double ret]) "va_return_double((va_alist)frame, ret);"))
	(define frame-return/pointer!
		(foreign-lambda* void ([c-pointer frame] [c-pointer ret]) "va_return_ptr((va_alist)frame, void *, ret);"))
	(define frame-return/handle!
		(foreign-lambda* void ([c-pointer frame] [ihandle ret]) "va_return_ptr((va_alist)frame, Ihandle *, ret);"))

	(call-with-current-continuation
	 (lambda (return)
		 (let ([sig "i"] [ret? #f])
			 (dynamic-wind
				 void
				 (lambda ()
					 (let* ([data (registry-ref (pointer->address cid))]
									[proc (cdr data)])
						 (set! sig (car data))
						 (case (string-ref sig 0)
							 [(#\b)         (frame-start/ubyte! frame)]
							 [(#\i)         (frame-start/int! frame)]
							 [(#\f)         (frame-start/float! frame)]
							 [(#\d)         (frame-start/double! frame)]
							 [(#\v #\C #\h) (frame-start/pointer! frame)])
						 (let ([args (list-ec (:string chr "h" (string-drop sig 1))
													 (case chr
														 [(#\b)     (frame-arg/ubyte! frame)]
														 [(#\i)     (frame-arg/int! frame)]
														 [(#\f)     (frame-arg/float! frame)]
														 [(#\d)     (frame-arg/double! frame)]
														 [(#\s)     (frame-arg/string! frame)]
														 [(#\v #\C) (frame-arg/pointer! frame)]
														 [(#\h)     (frame-arg/handle! frame)]))])
							 (handle-exceptions exn
								 (print-error-message exn (current-error-port) "Error: in callback")
								 (let ([ret (apply proc args)])
									 (case (string-ref sig 0)
										 [(#\b)     (frame-return/ubyte! frame ret)]
										 [(#\i)     (frame-return/status! frame ret)]
										 [(#\f)     (frame-return/float! frame ret)]
										 [(#\d)     (frame-return/double! frame ret)]
										 [(#\v #\C) (frame-return/pointer! frame ret)]
										 [(#\h)     (frame-return/handle! frame ret)])
									 (set! ret? #t))))))
				 (lambda ()
					 (unless ret?
						 (case (string-ref sig 0)
							 [(#\b)         (frame-return/ubyte! frame 0)]
							 [(#\i)         (frame-return/status! frame 'continue)]
							 [(#\f)         (frame-return/float! frame 0.0)]
							 [(#\d)         (frame-return/double! frame 0.0)]
							 [(#\v #\C #\h) (frame-return/pointer! frame #f)]))
					 (return (void))))))))

(define-values (callback-set! callback)
	(letrec ([signature/raw
						(foreign-lambda* c-string ([nonnull-ihandle handle] [iname/upcase name])
							"C_return(iupClassCallbackGetFormat(handle->iclass, name));")]
					 [set/pointer!
					  (foreign-lambda c-pointer "IupSetCallback" nonnull-ihandle iname/upcase c-pointer)]
					 [get/pointer
					  (foreign-lambda c-pointer "IupGetCallback" nonnull-ihandle iname/upcase)]
					 [sigils
					  (irregex "([bifdsvCh]*)(?:=([bifdvCh]))?")]
					 [callback-set!
					  (lambda (handle name proc)
					  	(let* ([sig
					  	        (cond
												[(irregex-match sigils (or (signature/raw handle name) ""))
												 => (lambda (groups)
															(string-append
																(or (irregex-match-substring groups 2) "i")
																(irregex-match-substring groups 1)))]
												[else
												 (error 'callback-set! "callback has bad signature" handle name)])]
					  			   [new
					  	        (cond
					  	        	[(or (not proc) (pointer? proc)) proc]
					  	        	[else (registry-add! handle (cons sig proc))])])
								(cond
								 [(set/pointer! handle name new) =>
									(cut registry-remove! handle <>)])))]
					 [callback
					  (lambda (handle name)
					  	(let ([proc (get/pointer handle name)])
					  		(cond
					  			[(wrapper-id proc)
									 => (lambda (id)
												(cdr (registry-ref id)))]
					  			[else proc])))])
		(values
			callback-set!
			(getter-with-setter callback callback-set!))))

;; }}}

;; {{{ Layout functions

(define create
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupCreate" iname/downcase)))

(define destroy!
  (letrec ([collect-handles
            (lambda (handle acc)
							(cons
							 handle
							 (fold-ec acc (:children child handle)
								 child collect-handles)))]
           [handle-destroy!
            (foreign-safe-lambda void "IupDestroy" nonnull-ihandle)])
    (lambda (handle)
			(let ([handles (collect-handles handle '())])
				(handle-destroy! handle)
				(main-loop-flush)
				(for-each registry-clear! handles)))))

(define map-peer!
	(letrec ([map-peer/raw! (foreign-safe-lambda istatus "IupMap" nonnull-ihandle)])
		(lambda (handle)
			(let ([status (map-peer/raw! handle)])
				(case status
					[(#t) (void)]
					[else (error 'map-peer! (format "failed to map peer (~s)" status) handle)])))))

(define unmap-peer!
	(foreign-safe-lambda void "IupUnmap" nonnull-ihandle))

(define class-name
	(foreign-lambda iname/downcase "IupGetClassName" nonnull-ihandle))

(define class-type
	(foreign-lambda iname/downcase "IupGetClassType" nonnull-ihandle))

(define save-attributes!
	(foreign-lambda void "IupSaveClassAttributes" nonnull-ihandle))

(define parent
	(foreign-lambda ihandle "IupGetParent" nonnull-ihandle))

(define parent-dialog
	(foreign-lambda ihandle "IupGetDialog" nonnull-ihandle))

(define sibling
	(foreign-lambda ihandle "IupGetBrother" nonnull-ihandle))

(define child-add!
  (letrec ([append! (foreign-safe-lambda ihandle "IupAppend" nonnull-ihandle nonnull-ihandle)]
           [insert! (foreign-safe-lambda ihandle "IupInsert" nonnull-ihandle nonnull-ihandle nonnull-ihandle)])
    (lambda (child container #!optional [anchor #f])
      (or (if anchor
              (insert! container anchor child)
              (append! container child))
					(error 'child-add! "failed to add child" child container anchor)))))

(define child-remove!
	(foreign-safe-lambda void "IupDetach" nonnull-ihandle))

(define child-move!
	(letrec ([move! (foreign-safe-lambda istatus "IupReparent" nonnull-ihandle nonnull-ihandle ihandle)])
		(lambda (child parent #!optional ref-child)
			(let ([status (move! child parent ref-child)])
				(case status
					[(#t) (void)]
					[else (error 'child-move! (format "failed to move child (~s)" status) child parent)])))))

(define child-ref
  (letrec ([ref/position (foreign-lambda ihandle "IupGetChild" nonnull-ihandle int)]
           [ref/name (foreign-lambda ihandle "IupGetDialogChild" nonnull-ihandle iname/upcase)])
    (lambda (container id)
      ((if (integer? id) ref/position ref/name) container id))))

(define child-pos
	(letrec ([pos/raw (foreign-lambda int "IupGetChildPos" nonnull-ihandle nonnull-ihandle)])
		(lambda (parent child)
			(let ([pos (pos/raw parent child)])
				(and (not (negative? pos)) pos)))))

(define child-count
	(foreign-lambda int "IupGetChildCount" nonnull-ihandle))

(define (children handle)
	(list-ec (:children child handle) child))

(define refresh
	(foreign-safe-lambda void "IupRefresh" nonnull-ihandle))

(define redraw
	(letrec ([update
	          (foreign-safe-lambda* void ([nonnull-ihandle handle] [bool children])
	          	"IupUpdate(handle); if (children) IupUpdateChildren(handle);")]
	         [update/sync
	          (foreign-safe-lambda void "IupRedraw" nonnull-ihandle bool)])
	  (lambda (handle #!key [children? #f] [sync? #f])
	  	((if sync? update/sync update) handle children?))))

(define child-x/y->pos
	(letrec ([x/y->pos/raw (foreign-lambda int "IupConvertXYToPos" nonnull-ihandle int int)])
		(lambda (parent x y)
			(let ([pos (x/y->pos/raw parent x y)])
				(and (not (negative? pos)) pos)))))

;; }}}

;; {{{ Dialog functions

(define show
  (letrec ([position
            (lambda (v)
              (case v
                [(center)           #xffff]
                [(start top left)   #xfffe]
                [(end bottom right) #xfffd]
                [(mouse)            #xfffc]
                [(parent-center)    #xfffa]
                [(current)          #xfffb]
                [else               v]))]
           [popup (foreign-safe-lambda istatus "IupPopup" nonnull-ihandle int int)]
           [show/x/y (foreign-safe-lambda istatus "IupShowXY" nonnull-ihandle int int)])
    (lambda (handle #!key [x 'current] [y 'current] [modal? #f])
      (let ([status ((if modal? popup show/x/y) handle (position x) (position y))])
        (case status
          [(error) (error 'show "failed to show" handle)]
          [else    status])))))

(define hide
	(letrec ([hide/raw (foreign-safe-lambda istatus "IupHide" nonnull-ihandle)])
		(lambda (handle)
			(let ([status (hide/raw handle)])
				(case status
					[(#t) (void)]
					[else (error 'hide (format "failed to hide (~s)" status) handle)])))))

;; }}}

;; {{{ Composition functions

(define dialog
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupDialog" ihandle)))

(define fill
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupFill")))

(define gridbox
  (make-constructor-procedure
  	(foreign-lambda* nonnull-ihandle ([ihandle-list handles]) "C_return(IupGridBoxv((Ihandle **)handles));")
  	#:apply-args list))

(define hbox
  (make-constructor-procedure
  	(foreign-lambda* nonnull-ihandle ([ihandle-list handles]) "C_return(IupHboxv((Ihandle **)handles));")
  	#:apply-args list))

(define vbox
  (make-constructor-procedure
  	(foreign-lambda* nonnull-ihandle ([ihandle-list handles]) "C_return(IupVboxv((Ihandle **)handles));")
  	#:apply-args list))

(define zbox
  (make-constructor-procedure
  	(foreign-lambda* nonnull-ihandle ([ihandle-list handles]) "C_return(IupZboxv((Ihandle **)handles));")
  	#:apply-args list))

(define cbox
  (make-constructor-procedure
  	(foreign-lambda* nonnull-ihandle ([ihandle-list handles]) "C_return(IupCboxv((Ihandle **)handles));")
  	#:apply-args list))

(define sbox
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupSbox" ihandle)))

(define radio
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupRadio" ihandle)))

(define normalizer
  (make-constructor-procedure
  	(foreign-lambda* nonnull-ihandle ([ihandle-list handles]) "C_return(IupNormalizerv((Ihandle **)handles));")
  	#:apply-args list))

(define backgroundbox
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupBackgroundBox" ihandle)))

(define detachbox
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupDetachBox" ihandle)))

(define expandbox
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupExpander" ihandle)))

(define scrollbox
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupScrollBox" ihandle)))

(define split
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupSplit" ihandle ihandle)))

;; }}}

;; {{{ Image resource functions

(define image/palette
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupImage" int int blob)))

(define image/rgb
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupImageRGB" int int blob)))

(define image/rgba
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupImageRGBA" int int blob)))

(define image/file
	(letrec ([load-image (foreign-lambda ihandle "IupLoadImage" c-string)])
		(make-constructor-procedure
			(lambda (file)
				(or (load-image file) (error 'image/file (attribute #f 'iupim-lasterror)))))))

(define image/blob
	(letrec ([load-image
						(foreign-lambda* ihandle ([scheme-pointer data] [int size])
							"Ihandle *image;"
							"imBinMemoryFileName file;"
							"int oldModule = imBinFileSetCurrentModule(IM_MEMFILE);"
							"file.buffer = data;"
							"file.size = size;"
							"file.reallocate = 0;"
							"image = IupLoadImage((const char *)&file);"
							"imBinFileSetCurrentModule(oldModule);"
							"C_return(image);")])
		(make-constructor-procedure
			(lambda (data)
				(or (load-image
						 data
						 (cond
							[(blob? data) (blob-size data)]
							[(string? data) (string-length data)]
							[else (error 'image/blob "unknown argument type")]))
						(error 'image/blob (attribute #f 'iupim-lasterror)))))))

(define image-save
	(letrec ([save-image (foreign-lambda bool "IupSaveImage" nonnull-ihandle c-string iname/upcase)])
		(lambda (handle file format)
			(unless (save-image handle file format)
				(error 'image-save (attribute #f 'iupim-lasterror))))))

;; }}}

;; {{{ Focus functions

(define current-focus
  (letrec ([focus (foreign-safe-lambda ihandle "IupGetFocus")]
           [focus-set! (foreign-safe-lambda ihandle "IupSetFocus" ihandle)]
           [current-focus
            (case-lambda
              [()       (focus)]
              [(handle) (focus-set! handle)])])
    (getter-with-setter current-focus current-focus)))

(define focus-next
	(letrec ([focus-next/raw (foreign-safe-lambda ihandle "IupNextField" ihandle)])
		(lambda (#!optional [handle (current-focus)])
			(focus-next/raw handle))))

(define focus-previous
	(letrec ([focus-previous/raw (foreign-safe-lambda ihandle "IupPreviousField" ihandle)])
		(lambda (#!optional [handle (current-focus)])
			(focus-previous/raw handle))))

;; }}}

;; {{{ Menu functions

(define menu
  (make-constructor-procedure
  	(foreign-lambda* nonnull-ihandle ([ihandle-list handles]) "C_return(IupMenuv((Ihandle **)handles));")
  	#:apply-args list))

(define menu-item
  (letrec ([action-item (foreign-lambda nonnull-ihandle "IupItem" c-string iname/upcase)]
           [submenu-item (foreign-lambda nonnull-ihandle "IupSubmenu" c-string ihandle)])
    (make-constructor-procedure
     (lambda (#!optional [title #f] [action/menu #f])
       ((if (ihandle? action/menu) submenu-item action-item) title action/menu)))))

(define menu-separator
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupSeparator")))

;; }}}

;; {{{ Miscellaneous resource functions

(define clipboard
	(make-constructor-procedure
		(foreign-lambda nonnull-ihandle "IupClipboard")))

(define timer
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupTimer")))

(define send-url
	(letrec ([send-url/raw (foreign-lambda int "IupHelp" c-string)])
		(lambda (url)
			(and-let* ([status (send-url/raw url)]
			           [(not (= status 1))])
			  (error 'send-url (format "failed to open URL (~s)" status) url))
			(void))))

;; }}}

;; {{{ The library watchdog

(define thread-watchdog
  (letrec ([open (foreign-lambda* istatus () "C_return(IupOpen(NULL, NULL));")]
					 [setlocale (foreign-lambda* void () "setlocale(LC_NUMERIC, \"C\");")]
           [open-imglib (foreign-lambda void "IupImageLibOpen")]
           [close (foreign-lambda void "IupClose")]
           [chicken-yield (foreign-value "&CHICKEN_yield" c-pointer)])
		(and-let* ([(let ([status (dynamic-wind void open setlocale)])
    			        (case status
										[(#t)     #t]
										[(ignore) #f]
										[else     (error 'iup (format "failed to initialize library (~s)" status))]))]
      	       [(open-imglib)]
               [watchdog (timer)])
      (set-finalizer!
       watchdog
       (lambda (watchdog)
         (destroy! watchdog)
         (close)))
      (callback-set! watchdog 'action-cb chicken-yield)
      (attribute-set! watchdog 'time 500)
      (attribute-set! watchdog 'run #t)
      watchdog)))

;; }}}
