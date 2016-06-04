;; -*- mode: Scheme; tab-width: 2; -*- ;;

;; {{{ Data types

(foreign-declare
	"#include <iup.h>\n"
	"#include <iup_pplot.h>\n")
	
(include "iup-types.scm")

;; }}}

;; {{{ PPlot control

(define pplot
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupPPlot")))

;; }}}

;; {{{ Plotting functions

(define call-with-pplot
  (letrec ([pplot-begin (foreign-lambda void "IupPPlotBegin" nonnull-ihandle bool)]
           [pplot-end (foreign-lambda void "IupPPlotEnd" nonnull-ihandle)])
    (lambda (handle proc #!key [x-string? #f])
      (dynamic-wind
       (lambda ()
         (pplot-begin handle x-string?))
       (lambda ()
         (proc handle))
       (lambda ()
         (pplot-end handle))))))

(define pplot-add!
  (letrec ([append/real (foreign-lambda void "IupPPlotAdd" nonnull-ihandle float float)]
           [append/string (foreign-lambda void "IupPPlotAddStr" nonnull-ihandle c-string float)]
           [insert/real (foreign-lambda void "IupPPlotInsert" nonnull-ihandle int int float float)]
           [insert/string (foreign-lambda void "IupPPlotInsertStr" nonnull-ihandle int int c-string float)]
           [current-index (lambda (handle) (string->number (attribute handle 'current)))])
    (lambda (handle x y #!optional [sample-index #f] [index #f])
      (if (string? x)
          (if sample-index
              (insert/string handle (or index (current-index handle)) sample-index x y)
              (append/string handle x y))
          (if sample-index
              (insert/real handle (or index (current-index handle)) sample-index x y)
              (append/real handle x y))))))

(define pplot-x/y->pixel-x/y
	(letrec ([transform (foreign-lambda void "IupPPlotTransform" nonnull-ihandle float float (c-pointer int) (c-pointer int))])
		(lambda (handle pplot-x pplot-y)
			(let-location ([pixel-x int 0] [pixel-y int 0])
				(transform handle pplot-x pplot-y (location pixel-x) (location pixel-y))
				(values pixel-x pixel-y)))))

(define pplot-paint-to
	(foreign-lambda void "IupPPlotPaintTo" nonnull-ihandle nonnull-c-pointer))

;; }}}

;; {{{ Library setup

(foreign-code "IupPPlotOpen();")

;; }}}
