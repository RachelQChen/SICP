;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;                       Test_of_Exercise_3.35.scm
;;                       by Lawrence X. Amlord(颜序, aka 颜世敏)
;;                       informlarry@gmail.com
;;                       Oct 27th, 2013
;;                       Xi'an, China

;; Copyright (C) 2013 Lawrence X. Amlord(颜序, aka 颜世敏)
;; <informlarry@gmail.com>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   Implementing the squarer system
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (square x)
  (* x x))
;Value: square

;Value: squarer

(define (inform-about-value constraint)
  (constraint 'I-have-a-value))
;Value: inform-about-value

(define (inform-about-no-value constraint)
  (constraint 'I-lost-my-value))
;Value: inform-about-no-value

(define (probe name connector)
  (define (print-probe value)
    (newline)
    (display "Probe: ")
    (display name)
    (display " = ")
    (display value))
  (define (process-new-value)
    (print-probe (get-value connector)))
  (define (process-forget-value)
    (print-probe "?"))
  (define (me request)
    (cond ((eq? request 'I-have-a-value)
	   (process-new-value))
	  ((eq? request 'I-lost-my-value)
	   (process-forget-value))
	  (else
	   (error "Unknown request -- PROBE" request))))
  (connect connector me)
  me)
;Value: probe



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Representing connectors
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (make-connector)
  (let ((value false)
	(informant false)
	(constraints '()))
    (define (set-my-value newval setter)
      (cond ((not (has-value? me))
	     (set! value newval)
	     (set! informant setter)
	     (for-each-except setter
			      inform-about-value
			      constraints))
	    ((not (= value newval))
	     (error "Contradiction" (list value newval)))
	    (else 'ignored)))
    (define (forget-my-value retractor)
      (if (eq? retractor informant)
	  (begin (set! informant false)
		 (for-each-except retractor
				  inform-about-no-value
				  constraints))
	  'ignored))
    (define (connect new-constraint)
      (if (not (memq new-constraint constraints))
	  (set! constraints
		(cons new-constraint constraints)))
      (if (has-value? me)
	  (inform-about-value new-constraint))
      'done)
    (define (me request)
      (cond ((eq? request 'has-value?)
	     (if informant true false))
	    ((eq? request 'value) value)
	    ((eq? request 'set-value!) set-my-value)
	    ((eq? request 'forget) forget-my-value)
	    ((eq? request 'connect) connect)
	    (else
	     (error "Unknown operation -- CONNECTOR" request))))
    me))
;Value: make-connector

(define (for-each-except exception procedure list)
  (define (loop items)
    (cond ((null? items) 'done)
	  ((eq? (car items) exception) (loop (cdr items)))
	  (else
	   (procedure (car items))
	   (loop (cdr items)))))
  (loop list))
;Value: for-each-except

(define (has-value? connector)
  (connector 'has-value?))
;Value: has-value?

(define (get-value connector)
  (connector 'value))
;Value: get-value

(define (set-value! connector new-value informant)
  ((connector 'set-value!) new-value informant))
;Value: set-value!

(define (forget-value! connector retractor)
  ((connector 'forget) retractor))
;Value: forget-value!

(define (connect connector new-constraint)
  ((connector 'connect) new-constraint))
;Value: connect



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;     Testing the squarer system
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define a (make-connector))
;Value: a

(define b (make-connector))
;Value: b

(squarer a b)
;Value 18: #[compound-procedure 18 me]

(probe "a" a)
;Value 19: #[compound-procedure 19 me]

(probe "b" b)
;Value 20: #[compound-procedure 20 me]

(set-value! a 16 'user)

Probe: a = 16
Probe: b = 256
;Value: done

(set-value! b 144 'user)
;Contradiction (256 144)
;To continue, call RESTART with an option number:
; (RESTART 1) => Return to read-eval-print level 1.
;Start debugger? (y or n): n

(forget-value! a 'user)

Probe: a = ?
Probe: b = ?
;Value: done

(set-value! b 144 'user)

Probe: b = 144
Probe: a = 12
;Value: done

