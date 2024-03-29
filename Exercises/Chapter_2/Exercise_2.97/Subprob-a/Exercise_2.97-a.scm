;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;                       Exercise_2.97-a.scm
;;                       by Lawrence R. Amlord(颜世敏 Shi-min Yan)
;;                       informlarry@gmail.com
;;                       Aug 26th, 2013
;;                       Xi'an, China

;; Copyright (C) 2013 Lawrence R. Amlord(颜世敏 Shi-min Yan)
;; <informlarry@gmail.com>

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;       The Polynomial Package
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (install-polynomial-package)
  ;; internal procedures
  ;; representation of poly
  (define (make-poly variable term-list)
    (cons variable term-list))
  (define (variable p) (car p))
  (define (term-list p) (cdr p))
  
  (define (variable? x) (symbol? x))
  (define (same-variable? v1 v2)
    (and (variable? v1) (variable? v2) (eq? v1 v2)))

  ;; representation of terms and term lists
  (define (adjoin-term term term-list)
    (if (=zero? (coeff term))
	term-list
	(cons term term-list)))

  (define (the-empty-termlist) '())
  (define (first-term term-list) (car term-list))
  (define (rest-terms term-list) (cdr term-list))
  (define (empty-termlist? term-list) (null? term-list))

  (define (make-term order coeff) (list order coeff))
  (define (order term) (car term))
  (define (coeff term) (cadr term))

  (define (zero-poly? p)
    (zero-terms? (term-list p)))
  (define (zero-terms? L)
      (or (empty-termlist? L)
	  (and (=zero? (coeff (first-term L)))
	       (zero-terms? (rest-terms L)))))

  (define (neg-poly p)
    (make-poly (variable p)
	       (neg-terms (term-list p))))
  (define (neg-terms L)
    (if (empty-termlist? L)
	(the-empty-termlist)
	(let ((t1 (first-term L)))
	  (adjoin-term (make-term (order t1)
				  (neg (coeff t1)))
		       (neg-terms (rest-terms L))))))

  (define (add-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
	(make-poly (variable p1)
		   (add-terms (term-list p1)
			      (term-list p2)))
	(error "Polys not in the same var --ADD-POLY"
	       (list p1 p2))))

  (define (add-terms L1 L2)
    (cond ((empty-termlist? L1) L2)
	  ((empty-termlist? L2) L1)
	  (else
	   (let ((t1 (first-term L1))
		 (t2 (first-term L2)))
	     (cond ((> (order t1) (order t2))
		    (adjoin-term t1
				 (add-terms (rest-terms L1) L2)))
		   ((< (order t1) (order t2))
		    (adjoin-term t2
				 (add-terms L1 (rest-terms L2))))
		   (else
		    (adjoin-term (make-term (order t1)
					    (add (coeff t1) (coeff t2)))
				 (add-terms (rest-terms L1)
					    (rest-terms L2)))))))))

  (define (sub-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
	(make-poly (variable p1)
		   (sub-terms (term-list p1)
			      (term-list p2)))
	(error "Polys not in the same var --SUB-POLY"
	       (list p1 p2))))

  (define (sub-terms L1 L2)
    (add-terms L1 (neg-terms L2)))

  (define (mul-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
	(make-poly (variable p1)
		   (mul-terms (term-list p1)
			      (term-list p2)))
	(error "Polys not in the same var --MUL-POLY"
	       (list p1 p2))))

  (define (mul-terms L1 L2)
    (if (empty-termlist? L1)
	(the-empty-termlist)
	(add-terms (mul-term-by-all-terms (first-term L1) L2)
		   (mul-terms (rest-terms L1) L2))))
  (define (mul-term-by-all-terms t1 L)
    (if (empty-termlist? L)
	(the-empty-termlist)
	(let ((t2 (first-term L)))
	  (adjoin-term (make-term (+ (order t1) (order t2))
				  (mul (coeff t1) (coeff t2)))
		       (mul-term-by-all-terms t1 (rest-terms L))))))

  (define (mul-terms-by-a-factor L fac)
    (if (empty-termlist? L)
	(the-empty-termlist)
	(let ((t1 (first-term L)))
	  (adjoin-term (make-term (order t1)
				  (mul (coeff t1) fac))
		       (mul-terms-by-a-factor (rest-terms L) fac)))))

  (define (div-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
	(let ((dt (div-terms (term-list p1)
			     (term-list p2))))
	  (let ((quotient-terms (car dt))
		(remainder-terms (cadr dt)))
	    (list (make-poly (variable p1) quotient-terms)
		  (make-poly (variable p2) remainder-terms))))
	(error "Polys not in the same var -- DIV-POLY"
	       (list p1 p2))))

  (define (div-terms L1 L2)
    (if (empty-termlist? L1)
	(list (the-empty-termlist) (the-empty-termlist))
	(let ((t1 (first-term L1))
	      (t2 (first-term L2)))
	  (if (> (order t2) (order t1))
	      (list (the-empty-termlist) L1)
	      (let ((new-c (div (coeff t1) (coeff t2)))
		    (new-o (- (order t1) (order t2))))
		(let ((rest-of-result    ;; compute rest of result recursively
		      (div-terms (sub-terms L1
					    (mul-term-by-all-terms (make-term new-o new-c)
								   L2))
				 L2)))
		  (list (adjoin-term (make-term new-o new-c)    ;; form complete result
				     (car rest-of-result))
			(cadr rest-of-result))))))))

  (define (div-terms-by-a-factor L fac)
    (if (empty-termlist? L)
	(the-empty-termlist)
	(let ((t1 (first-term L)))
	  (adjoin-term (make-term (order t1)
				  (div (coeff t1) fac))
		       (div-terms-by-a-factor (rest-terms L) fac)))))

  (define (gcd-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
	(make-poly (variable p1)
		   (gcd-terms (term-list p1)
			      (term-list p2)))
	(error "Polys not in the same var --GCD-POLY"
	       (list p1 p2))))

  (define (gcd-terms a b)
    (if (empty-termlist? b)
	(remove-common-factor a)
	(gcd-terms b (pseudoremainder-terms a b))))

  (define (remove-common-factor L)
    (if (empty-termlist? L)
	(the-empty-termlist)
	(let ((coeffs (map (lambda (term)
			     (coeff term))
			   L)))
	  (let ((cf (common-factor coeffs)))
	    (if (=zero? cf)
		L
		(div-terms-by-a-factor L cf))))))

  (define (common-factor items)
    (if (null? items)
	0
	(let ((t1 (car items))
	      (rest-items (cdr items)))
	  (gcd t1 (common-factor rest-items)))))

  (define (pseudoremainder-terms a b)
    (let ((t1 (first-term a))
	  (t2 (first-term b)))
      (let ((o1 (order t1))
	    (o2 (order t2))
	    (c (coeff t2)))
	(let ((integerizing-factor (expt c
					 (+ (- o1 o2) 1))))
	  (cadr (div-terms (mul-terms-by-a-factor a integerizing-factor)
			   b))))))

  (define (reduce-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
	(let ((rt (reduce-terms (term-list p1) (term-list p2))))
	  (list (make-polynomial (variable p1)
				 (car rt))
		(make-polynomial (variable p2)
				 (cadr rt))))
	(error "Polys not in the same var -- REDUCE-POLY"
	       (list p1 p2))))

  (define (reduce-terms n d)
    (let ((gt (gcd-terms n d)))
      (let ((t1 (first-term n))
	    (t2 (first-term d))
	    (tg (first-term gt)))
	(let ((o1 (max (order t1) (order t2)))
	      (c (coeff tg))
	      (o2 (order tg)))
	  (let ((integerizing-factor (expt c
					   (+ (- o1 o2) 1))))
	    (let ((integerized-n (mul-terms-by-a-factor n integerizing-factor))
		  (integerized-d (mul-terms-by-a-factor d integerizing-factor)))
	      (let ((new-n (car (div-terms integerized-n gt)))
		    (new-d (car (div-terms integerized-d gt))))
		(let ((coeffs (map (lambda (term)
				      (coeff term))
				    (append new-n new-d))))
		   (let ((cf (common-factor coeffs)))
		     (let ((nn (div-terms-by-a-factor new-n cf))
			   (dd (div-terms-by-a-factor new-d cf)))
		       (list nn dd)))))))))))
  
  ;; interface to rest of the system
  (define (tag p) (attach-tag 'polynomial p))
  (put '=zero? '(polynomial)
       (lambda (p) (zero-poly? p)))
  (put 'neg '(polynomial)
       (lambda (p) (tag (neg-poly p))))
  (put 'add '(polynomial polynomial)
       (lambda (p1 p2) (tag (add-poly p1 p2))))
  (put 'sub '(polynomial polynomial)
       (lambda (p1 p2) (tag (sub-poly p1 p2))))
  (put 'mul '(polynomial polynomial)
       (lambda (p1 p2) (tag (mul-poly p1 p2))))
  (put 'div '(polynomial polynomial)
       (lambda (p1 p2) (tag (div-poly p1 p2))))
  (put 'greatest-common-divisor '(polynomial polynomial)
       (lambda (p1 p2) (tag (gcd-poly p1 p2))))
  (put 'reduce '(polynomial polynomial)
       (lambda (p1 p2) (reduce-poly p1 p2)))
  (put 'make 'polynomial
       (lambda (var terms) (tag (make-poly var terms))))
  'done)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;       Procedure of Creating Polynomials for Users 
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (make-polynomial var terms)
  ((get 'make 'polynomial) var terms))

