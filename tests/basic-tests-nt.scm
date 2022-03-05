(load "require-nt.scm")

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

;; A problem:
;; randomly return fresh variable e.g. _.0
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
;;  (c c (c . _.0))
;;  (b b (b c b)))

;; Wrong!
;; In `nt` mode, tabling doesn't record `p`, so when a slave call with a fresh `p`,
;; the answer of that slave call will be still fresh, even if the master call is ground.

;; More simple case, just demonstrate the problem
(run* (q)
  (letrec ((testo-tabled (tabled ((x) p)
                           (conde
                             ((== x 'a)
                              (== p 'a))
                             ((fresh (y q)
                                ((testo-tabled y) p) ; p can't get value 'a
                                (== x 'b) ; x = 'b, so this branch doesn't fail, but p is still fresh.
                                ))))))
    (fresh (x p)
      ((testo-tabled x) p)
      (== `(,x ,p) q)
      )))
;; ((a a) (b _.0))

;; So try mode `first`...


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
