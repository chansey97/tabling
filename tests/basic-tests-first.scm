(load "require-first.scm")

(run* (q)
  (letrec ((arco (lambda (x y)
                   (conde
                     ((== x 'a) (== y 'b))
                     ((== x 'b) (== y 'c))
                     ((== x 'c) (== y 'b)))))
           (patho-tabled (tabled ((x y) p)
                           (conde
                             ((arco x y)
                              (== p `(,x ,y)))
                             ((fresh (z q)
                                (arco x z)
                                ((patho-tabled z y) q)
                                (== p `(,x . ,q))
                                ))))))
    (fresh (x)
      ((patho-tabled 'a x) q))))
;; ((a b) (a b c))


;; The `first` mode fixed the `nt`'s problem. 
(run* (q)
  (letrec ((arco (lambda (x y)
                   (conde
                     ((== x 'a) (== y 'b))
                     ((== x 'b) (== y 'c))
                     ((== x 'c) (== y 'b)))))
           (patho-tabled (tabled ((x y) p)
                           (conde
                             ((arco x y)
                              (== p `(,x ,y)))
                             ((fresh (z q)
                                (arco x z)
                                ((patho-tabled z y) q)
                                (== p `(,x . ,q))
                                ))))))
    (fresh (x y p)
      ((patho-tabled x y) p)
      (== `(,x ,y ,p) q)
      )))
;; ((a b (a b))
;;  (b c (b c))
;;  (c b (c b))
;;  (a c (a b c))
;;  (c c (c b c))
;;  (b b (b c b))) ; Now is OK

(run* (q)
  (letrec ((testo-tabled (tabled ((x) p)
                           (conde
                             ((== x 'a)
                              (== p 'a))
                             ((fresh (y q)
                                ((testo-tabled y) p)
                                (== x 'b)
                                ))))))
    (fresh (x p)
      ((testo-tabled x) p)
      (== `(,x ,p) q)
      )))
;; ((a a) (b a))


;; Another problem:
;; When `p` is ground, the result is no longer relational.

;; For the same tabled answer, a `first` argument can only have one unique ground value,
;; which be unified once, even if in different branches. So `first` arguments should be
;; as output arguments and never be tested.

(define *table* '())

(define-syntax tabled
  (syntax-rules ()
    ((_ ((x ...) y ...) g g* ...)
     (lambda (x ...)
       (lambda (y ...)
         (let ((argv (list x ...))
               (argw (list y ...)))
           (lambdag@ (s)
             (let ((key (reify argv s)))
               (cond
                 ((assoc key *table*)
                  => (lambda (key.cache) (reuse argv argw (cdr key.cache) s)))
                 (else (let ((cache (make-cache '() '())))
                         (set! *table* (cons `(,key . ,cache) *table*))                         
                         ((fresh () g g* ... (master argv argw cache)) s))))))))))))

(run* (q)
  (lambdag@ (s) (begin (set! *table* '()) s))
  (letrec ((arco (lambda (x y)
                   (conde
                     ((== x 'a) (== y 'b))
                     ((== x 'b) (== y 'c))
                     ((== x 'c) (== y 'b)))))
           (patho-tabled (tabled ((x y) p)
                           (conde
                             ((arco x y)
                              (== p `(,x ,y)))
                             ((fresh (z q)
                                (arco x z)
                                ((patho-tabled z y) q)
                                (== p `(,x . ,q))
                                ))))))
    ((patho-tabled 'a 'b) q)))
;; ((a b))

(run* (q)
  (lambdag@ (s) (begin (set! *table* '()) s))
  (letrec ((arco (lambda (x y)
                   (conde
                     ((== x 'a) (== y 'b))
                     ((== x 'b) (== y 'c))
                     ((== x 'c) (== y 'b)))))
           (patho-tabled (tabled ((x y) p)
                           (conde
                             ((arco x y)
                              (== p `(,x ,y)))
                             ((fresh (z q)
                                (arco x z)
                                ((patho-tabled z y) q)
                                (== p `(,x . ,q))
                                ))))))
    ((patho-tabled 'a 'b) '(a b))))
;; (_.0)

;; *table*
;; (((c b) . #(cache ((c b)) ((c b))))
;;  ((b b) . #(cache ((b b)) ((b c b))))
;;  ((a b) . #(cache ((a b)) ((a b)))))

(run* (q)
  (lambdag@ (s) (begin (set! *table* '()) s))
  (letrec ((arco (lambda (x y)
                   (conde
                     ((== x 'a) (== y 'b))
                     ((== x 'b) (== y 'c))
                     ((== x 'c) (== y 'b)))))
           (patho-tabled (tabled ((x y) p)
                           (conde
                             ((arco x y)
                              (== p `(,x ,y)))
                             ((fresh (z q)
                                (arco x z)
                                ((patho-tabled z y) q)
                                (== p `(,x . ,q))
                                ))))))
    ((patho-tabled 'a 'b) '(a b c b))))
;; (_.0)

;; *table*
;; (((c b) . #(cache ((c b)) ((c b))))
;;  ((b b) . #(cache ((b b)) ((b c b))))
;;  ((a b) . #(cache ((a b)) ((a b c b)))))

(run* (q)
  (lambdag@ (s) (begin (set! *table* '()) s))
  (letrec ((arco (lambda (x y)
                   (conde
                     ((== x 'a) (== y 'b))
                     ((== x 'b) (== y 'c))
                     ((== x 'c) (== y 'b)))))
           (patho-tabled (tabled ((x y) p)
                           (fresh ()
                             (trace-vars (_) (x y p)
                                         (printf "((patho-tabled ~a ~a) ~a)\n" x y p))
                             (conde
                               ((arco x y)
                                (trace-vars (_) (x y p)
                                            (printf "((patho-tabled ~a ~a) ~a), 1 (arco ~a ~a)\n" x y p x y)
                                            (printf "((patho-tabled ~a ~a) ~a), 1 p = ~a = (~a ~a)\n" x y p p x y))
                                (== p `(,x ,y)))
                               ((fresh (z q)
                                  (arco x z)
                                  (trace-vars (_) (x y z p)
                                            (printf "((patho-tabled ~a ~a) ~a), 2 (arco ~a ~a)\n" x y p x z)
                                            (printf "((patho-tabled ~a ~a) ~a), 2 call (patho-tabled ~a ~a)\n" x y p z y))
                                  ((patho-tabled z y) q)
                                  (trace-vars (_) (x y z p q)
                                            (printf "((patho-tabled ~a ~a) ~a), 2 return from (patho-tabled ~a ~a) q=~a\n" x y p z y q)
                                            (printf "((patho-tabled ~a ~a) ~a), 2 return from (patho-tabled ~a ~a) p = ~a = ~a\n" x y p z y p `(,x . ,q)))
                                  (== p `(,x . ,q))
                                  )))))))
    ((patho-tabled 'a 'b) '(a b c b c b))))
;; ((patho-tabled a b) (a b c b c b))
;; ((patho-tabled a b) (a b c b c b)), 1 (arco a b)
;; ((patho-tabled a b) (a b c b c b)), 1 p = (a b c b c b) = (a b)
;; ((patho-tabled a b) (a b c b c b)), 2 (arco a b)
;; ((patho-tabled a b) (a b c b c b)), 2 call (patho-tabled b b)
;; ((patho-tabled b b) #(q))
;; ((patho-tabled b b) #(q))         , 2 (arco b c)
;; ((patho-tabled b b) #(q))         , 2 call (patho-tabled c b)
;; ((patho-tabled c b) #(q))
;; ((patho-tabled c b) #(q))         , 1 (arco c b)
;; ((patho-tabled c b) #(q))         , 1 p = #(q) = (c b)
;; ((patho-tabled b b) #(q))         , 2 return from (patho-tabled c b) q=(c b)
;; ((patho-tabled b b) #(q))         , 2 return from (patho-tabled c b) p = #(q) = (b c b)
;; ((patho-tabled a b) (a b c b c b)), 2 return from (patho-tabled b b) q=(b c b)
;; ((patho-tabled a b) (a b c b c b)), 2 return from (patho-tabled b b) p = (a b c b c b) = (a b c b)
;; ((patho-tabled c b) #(q))         , 2 (arco c b)
;; ((patho-tabled c b) #(q))         , 2 call (patho-tabled b b)
;; ((patho-tabled c b) #(q))         , 2 return from (patho-tabled b b) q=(b c b)
;; ((patho-tabled c b) #(q))         , 2 return from (patho-tabled b b) p = #(q) = (c b c b)
;; ()

;; *table*
;; (((c b) . #(cache ((c b)) ((c b))))
;;  ((b b) . #(cache ((b b)) ((b c b))))
;;  ((a b) . #(cache () ())))


;; ((patho-tabled 'a 'b) '(a b)) => (_.0)
;; ((patho-tabled 'a 'b) '(a b c b)) => (_.0)
;; ((patho-tabled 'a 'b) '(a b c b c b)) => ()
;; Wrong!


