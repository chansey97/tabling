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

;; IMO, the mode variable should be
;; either a fresh variable (always as an output variable and dont' test it),
;; or a readonly variable.

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
    ((patho-tabled 'a 'b) q)))
;; ((a b))

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
    ((patho-tabled 'a 'b) '(a b))))
;; (_.0)

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
    ((patho-tabled 'a 'b) '(a b c b))))
;; (_.0)

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
    ((patho-tabled 'a 'b) '(a b c b c b))))
;; ()

;; ((patho-tabled 'a 'b) '(a b)) => (_.0)
;; ((patho-tabled 'a 'b) '(a b c b)) => (_.0)
;; ((patho-tabled 'a 'b) '(a b c b c b)) => ()
;; Wrong!
