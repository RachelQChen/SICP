;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;                       3.3.2_Representing_Queues.scm
;;                       originated from SICP
;;                       edited by Lawrence X. Amlord(颜序, aka 颜世敏)
;;                       informlarry@gmail.com
;;                       Sept 25th, 2013
;;                       Xi'an, China

;; Copyright (C) 1984-2013 Harold Abelson and Gerald Jay Sussman
;; with Julie Sussman

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

(define (front-ptr queue) (car queue))
;Value: front-ptr

(define (rear-ptr queue) (cdr queue))
;Value: rear-ptr

(define (set-front-ptr! queue item) (set-car! queue item))
;Value: set-front-ptr!

(define (set-rear-ptr! queue item) (set-cdr! queue item))
;Value: set-rear-ptr!

(define (empty-queue? queue) (null? (front-ptr queue)))
;Value: empty-queue?

(define (make-queue) (cons '() '()))
;Value: make-queue

(define (front-queue queue)
  (if (empty-queue? queue)
      (error "FRONT called with an empty queue" queue)
      (car (front-ptr queue))))
;Value: front-queue

(define (insert-queue! queue item)
  (let ((new-pair (cons item '())))
    (cond ((empty-queue? queue)
	   (set-front-ptr! queue new-pair)
	   (set-rear-ptr! queue new-pair)
	   queue)
	  (else
	   (set-cdr! (rear-ptr queue) new-pair)
	   (set-rear-ptr! queue new-pair)
	   queue))))
;Value: insert-queue!

(define (delete-queue! queue)
  (cond ((empty-queue? queue)
	 (error "DELETE! called with an empty queue" queue))
	(else
	 (set-front-ptr! queue (cdr (front-ptr queue)))
	 queue)))
;Value: delete-queue!

(define q (make-queue))
;Value: q

(insert-queue! q 'a)
;Value 13: ((a) a)

(insert-queue! q 'b)
;Value 13: ((a b) b)

(delete-queue! q)
;Value 13: ((b) b)

(insert-queue! q 'c)
;Value 13: ((b c) c)

(insert-queue! q 'd)
;Value 13: ((b c d) d)

(delete-queue! q)
;Value 13: ((c d) d)

