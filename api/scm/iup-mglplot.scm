;; -*- mode: Scheme; tab-width: 2; -*- ;;

;; {{{ Data types

(foreign-declare
	"#include <iup.h>\n"
	"#include <iup_mglplot.h>\n")
	
(include "iup-types.scm")

;; }}}

;; {{{ MglPlot controls

(define mglplot
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupMglPlot")))

(define mgllabel
  (make-constructor-procedure
  	(foreign-lambda nonnull-ihandle "IupMglLabel" c-string)
		#:apply-args (optional-args [title #f])))

;; }}}

;; {{{ Plotting functions

(define call-with-mglplot
  (letrec ([mglplot-begin (foreign-lambda void "IupMglPlotBegin" nonnull-ihandle int)]
           [mglplot-end (foreign-lambda void "IupMglPlotEnd" nonnull-ihandle)])
    (lambda (handle proc #!key [dimension 2])
      (dynamic-wind
       (lambda ()
         (mglplot-begin handle dimension))
       (lambda ()
         (proc handle))
       (lambda ()
         (mglplot-end handle))))))

(define mglplot-add!
  (letrec ([append/1d (foreign-lambda void "IupMglPlotAdd1D" nonnull-ihandle c-string double)]
					 [append/2d (foreign-lambda void "IupMglPlotAdd2D" nonnull-ihandle double double)]
					 [append/3d (foreign-lambda void "IupMglPlotAdd3D" nonnull-ihandle double double double)]
           [insert/1d (foreign-lambda* void ([nonnull-ihandle handle] [int index] [int sample_index] [c-string x] [double y]) "IupMglPlotInsert1D(handle, index, sample_index, (const char **) &x, &y, 1);")]
           [insert/2d (foreign-lambda* void ([nonnull-ihandle handle] [int index] [int sample_index] [double x] [double y]) "IupMglPlotInsert2D(handle, index, sample_index, &x, &y, 1);")]
           [insert/3d (foreign-lambda* void ([nonnull-ihandle handle] [int index] [int sample_index] [double x] [double y] [double z]) "IupMglPlotInsert3D(handle, index, sample_index, &x, &y, &z, 1);")]
           [current-index (lambda (handle) (string->number (attribute handle 'current)))])
    (lambda (handle x y #!optional [z #f] [sample-index #f] [index #f])
      (cond
			 [z
				(if sample-index
						(insert/3d handle (or index (current-index handle)) sample-index x y z)
						(append/3d handle x y z))]
			 [(string? x)
				(if sample-index
						(insert/1d handle (or index (current-index handle)) sample-index x y)
						(append/1d handle x y))]
			 [else
				(if sample-index
						(insert/2d handle (or index (current-index handle)) sample-index x y)
						(append/2d handle x y))]))))

(define mglplot-x/y/z->pixel-x/y
	(letrec ([transform (foreign-lambda void "IupMglPlotTransform" nonnull-ihandle double double double (c-pointer int) (c-pointer int))])
		(lambda (handle mglplot-x mglplot-y #!optional [mglplot-z 0.0])
			(let-location ([pixel-x int 0] [pixel-y int 0])
				(transform handle mglplot-x mglplot-y mglplot-z (location pixel-x) (location pixel-y))
				(values pixel-x pixel-y)))))

(define mglplot-paint-to
	(letrec ([paint-to (foreign-lambda void "IupMglPlotPaintTo" nonnull-ihandle nonnull-c-string int int double nonnull-c-string)])
		(lambda (handle format file #!optional [width 0] [height 0] [dpi 0.0])
			(paint-to handle format width height dpi file))))

;; }}}

;; {{{ Library setup

(foreign-code "IupMglPlotOpen();")

;; }}}
