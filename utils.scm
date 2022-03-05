(define-syntax trace-vars
  (syntax-rules ()
    ((_ (s) (x ...) e ...)  
     (lambdag@ (s)
               (let ((x (walk* x s)) ...)
                 e ...
                 s)))))
