(load "require-nt.scm")

;; a -> b -> c -> a

(define edge
  (lambda (in-node out-node)
    (conde
      [(== 'a in-node)
       (== 'b out-node)]
      [(== 'b in-node)
       (== 'c out-node)]
      [(== 'c in-node)
       (== 'a out-node)]
      )))

(define tabled-path
  (tabled ((in out) p)
    (conde
      [(== in out) (== '() p)]
      [(fresh (node p^)
         (== (cons (list in node) p^) p)
         (edge in node)
         ((tabled-path node out) p^))])))

;; (run* (p)
;;   ((tabled-path 'a 'c) p))
;; The 1st call is (((a b) (b c)))
;; The second call is (_.0)
;; That because the 2nd call resue tabled answer, but p is not tabled.

;; Use letrec to rescue
(run* (p)
  (letrec ((tabled-path (tabled ((in out) p)
                          (conde
                            [(== in out) (== '() p)]
                            [(fresh (node p^)
                               (== (cons (list in node) p^) p)
                               (edge in node)
                               ((tabled-path node out) p^))]))))
    ((tabled-path 'a 'c) p)))
;; (((a b) (b c)))


