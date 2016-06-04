;; -*- mode: Scheme; tab-width: 2; -*- ;;

(require-library
  lolevel data-structures extras srfi-1 srfi-13 srfi-42 srfi-69 irregex posix)

(module iup-base
	(ihandle->pointer pointer->ihandle ihandle-list->pointer-vector ihandle?
	 istatus->integer integer->istatus
	 iname->string string->iname
	 thread-watchdog iup-version load/led
	 attribute attributes attribute-set! attribute-reset!
	 handle-name handle-name-set! handle-ref
	 main-loop main-loop-step main-loop-level main-loop-exit main-loop-flush
	 callback callback-set!
	 make-constructor-procedure optional-args
	 create destroy! map-peer! unmap-peer!
	 class-name class-type save-attributes!
	 parent parent-dialog sibling
	 child-add! child-remove! child-move!
	 child-ref child-pos child-count
	 :children children
	 refresh redraw
	 child-x/y->pos
	 show hide
	 dialog
	 fill gridbox hbox vbox zbox cbox sbox
	 radio normalizer backgroundbox detachbox expandbox scrollbox split
	 image/palette image/rgb image/rgba image/file image/blob image-save
	 current-focus focus-next focus-previous
	 menu menu-item menu-separator
	 clipboard timer send-url)
	(import
		scheme chicken foreign
		lolevel data-structures extras srfi-1 srfi-13 srfi-42 srfi-69 irregex
		(only posix setenv))
	(include "iup-base.scm"))

(module iup-controls
	(canvas
	 frame tabs
	 label link button toggle
	 spin spinbox valuator
	 textbox listbox treebox
	 progress-bar
	 matrix matrix-listbox cells
	 color-bar color-browser
	 dial)
	(import
		scheme chicken foreign
		iup-base)
	(include "iup-controls.scm"))

(module iup-dialogs
	(file-dialog message-dialog color-dialog font-dialog progress-dialog
   layout-dialog element-properties-dialog)
	(import
		scheme chicken foreign
		iup-base)
	(include "iup-dialogs.scm"))

(cond-expand
 [disable-iup-glcanvas]
 [else
	(module iup-glcanvas
		(glcanvas
		 call-with-glcanvas glcanvas-is-current?
		 glcanvas-palette-set! glcanvas-font-set!)
		(import
		  scheme chicken foreign
			iup-base)
		(include "iup-glcanvas.scm"))])

(cond-expand
 [(or disable-iup-glcanvas disable-iup-glcontrols)]
 [else
	(module iup-glcontrols
		(glcanvasbox glsubcanvas
		 call-with-glcanvas glcanvas-is-current?
		 glcanvas-palette-set! glcanvas-font-set!
		 glframe glexpander glscrollbox glsizebox
		 glseparator gllabel gllink glbutton gltoggle
		 glvaluator glprogress-bar)
		(import
		  scheme chicken foreign
			iup-base iup-glcanvas)
		(include "iup-glcontrols.scm"))])

(cond-expand
 [disable-iup-plot]
 [else
	(module iup-plot
		(plot
		 call-with-plot plot-add!
		 plot-x/y->pixel-x/y
		 plot-paint-to)
		(import
		  scheme chicken foreign
			iup-base)
		(include "iup-plot.scm"))])

(cond-expand
 [disable-iup-mglplot]
 [else
	(module iup-mglplot
		(mglplot mgllabel
		 call-with-mglplot mglplot-add!
		 mglplot-x/y/z->pixel-x/y
		 mglplot-paint-to)
		(import
		  scheme chicken foreign
			iup-base)
		(include "iup-mglplot.scm"))])

(cond-expand
 [disable-iup-pplot]
 [else
	(module iup-pplot
		(pplot
		 call-with-pplot pplot-add!
		 pplot-x/y->pixel-x/y
		 pplot-paint-to)
		(import
		  scheme chicken foreign
			iup-base)
		(include "iup-pplot.scm"))])

(cond-expand
 [disable-iup-scintilla]
 [else
	(module iup-scintilla
		(scintilla)
		(import
		  scheme chicken foreign
			iup-base)
		(include "iup-scintilla.scm"))])

(cond-expand
 [disable-iup-web]
 [else
	(module iup-web
		(web-browser)
		(import
		  scheme chicken foreign
			iup-base)
		(include "iup-web.scm"))])

(cond-expand
 [enable-iup-ole
	(module iup-ole
		(ole-control)
		(import
		  scheme chicken foreign
			iup-base)
		(include "iup-ole.scm"))]
 [else])

(cond-expand
 [disable-iup-config]
 [else
	(module iup-config
		(config
		 config-load! config-save!
		 config-recent-menu config-recent-update!
		 config-dialog-show config-dialog-update!)
		(import
		  scheme chicken foreign
			iup-base (only srfi-18 raise))
		(include "iup-config.scm"))])

(module iup
	()
	(import scheme chicken)
	(reexport
		(except iup-base
			ihandle->pointer pointer->ihandle ihandle-list->pointer-vector
			istatus->integer integer->istatus
			iname->string string->iname
			make-constructor-procedure optional-args)
		iup-controls
		iup-dialogs))
