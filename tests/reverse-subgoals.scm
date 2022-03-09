(load "require.scm")

;; A funny observation:
;; You should typically reverse the order of subgoals,
;; because it can make recursive variant calls more abstraction and thus you build fewer tables.

;; On the surface,
;; it breaks tail recursion, but the underlying scheduling mechanism is completely different.

(define *table* '())

(define-syntax tabled
  (syntax-rules ()
    ((_ (x ...) g g* ...)
     (lambda (x ...)
       (let ((argv (list x ...)))
         (lambdag@ (s)
           (let ((key (reify argv s)))
             (cond
               ((assoc key *table*)
                => (lambda (key.cache) (reuse argv (cdr key.cache) s)))
               (else (let ((cache (make-cache '())))
                       (set! *table* (cons `(,key . ,cache) *table*))                         
                       ((fresh () g g* ... (master argv cache)) s)))))))))))

(run* (q)
  (lambdag@ (s) (begin (set! *table* '()) s))
  (letrec ((arco (lambda (x y)
                   (conde
                     ((== x 'a) (== y 'b))
                     ((== x 'b) (== y 'c))
                     ((== x 'c) (== y 'b)))))
           (patho-tabled (tabled (x y)
                           (fresh ()
                             (conde
                               ((arco x y))
                               ((fresh (z q)
                                  (arco x z)
                                  (patho-tabled z y)
                                  )))))))
    (fresh (x y)
      (patho-tabled x y))))
;; (_.0 _.0 _.0 _.0 _.0 _.0)

*table*
;; (((c _.0) . #(cache ((c c) (c b))))
;;  ((b _.0) . #(cache ((b b) (b c))))
;;  ((_.0 _.1) . #(cache ((b b) (c c) (a c) (c b) (b c) (a b)))))

(run* (q)
  (lambdag@ (s) (begin (set! *table* '()) s))
  (letrec ((arco (lambda (x y)
                   (conde
                     ((== x 'a) (== y 'b))
                     ((== x 'b) (== y 'c))
                     ((== x 'c) (== y 'b)))))
           (patho-tabled (tabled (x y)
                           (fresh ()
                             (conde
                               ((arco x y))
                               ((fresh (z q)
                                  (patho-tabled z y)
                                  (arco x z)
                                  )))))))
    (fresh (x y)
      (patho-tabled x y))))
;; (_.0 _.0 _.0 _.0 _.0 _.0)

*table*
;; (((_.0 _.1)
;;    .
;;    #(cache ((c c) (a c) (b b) (c b) (b c) (a b)))))

