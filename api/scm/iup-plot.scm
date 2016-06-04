;; -*- mode: Scheme; tab-width: 2; -*- ;;

;; {{{ Data types

(foreign-declare
	"#include <iup.h>\n"
	"#include <iup_plot.h>\n")
	
(include "iup-types.scm")

;; }}}

;; {{{ Plot control

(define plot
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupPlot")))

;; }}}

;; {{{ Plotting functions

(define call-with-plot
  (letrec ([plot-begin (foreign-lambda void "IupPlotBegin" nonnull-ihandle bool)]
           [plot-end (foreign-lambda void "IupPlotEnd" nonnull-ihandle)])
    (lambda (handle proc #!key [x-string? #f])
      (dynamic-wind
       (lambda ()
         (plot-begin handle x-string?))
       (lambda ()
         (proc handle))
       (lambda ()
         (plot-end handle))))))

(define plot-add!
  (letrec ([append/real (foreign-lambda void "IupPlotAdd" nonnull-ihandle double double)]
           [append/string (foreign-lambda void "IupPlotAddStr" nonnull-ihandle c-string double)]
           [insert/real (foreign-lambda void "IupPlotInsert" nonnull-ihandle int int double double)]
           [insert/string (foreign-lambda void "IupPlotInsertStr" nonnull-ihandle int int c-string double)]
           [current-index (lambda (handle) (string->number (attribute handle 'current)))])
    (lambda (handle x y #!optional [sample-index #f] [index #f])
      (if (string? x)
          (if sample-index
              (insert/string handle (or index (current-index handle)) sample-index x y)
              (append/string handle x y))
          (if sample-index
              (insert/real handle (or index (current-index handle)) sample-index x y)
              (append/real handle x y))))))

(define plot-x/y->pixel-x/y
	(letrec ([transform (foreign-lambda void "IupPlotTransform" nonnull-ihandle double double (c-pointer double) (c-pointer double))])
		(lambda (handle plot-x plot-y)
			(let-location ([pixel-x int 0] [pixel-y int 0])
				(transform handle plot-x plot-y (location pixel-x) (location pixel-y))
				(values pixel-x pixel-y)))))

(define plot-paint-to
	(foreign-lambda void "IupPlotPaintTo" nonnull-ihandle nonnull-c-pointer))

;; }}}

;; {{{ Library setup

(foreign-code "IupPlotOpen();")

;; }}}
