#lang racket/base
(require (for-syntax racket/base
                     syntax/parse/pre
                     "class-parse.rkt")
         "parse.rkt"
         (only-in "binding.rkt" raise-binding-failure))

(provide (for-syntax build-added-field-arg-definitions))

(define-for-syntax (build-added-field-arg-definitions added-fields)
  (for/list ([added (in-list added-fields)])
    (with-syntax ([id (added-field-id added)]
                  [tmp-id (added-field-arg-id added)]
                  [rhs (let ([blk (added-field-arg-blk added)])
                         (syntax-parse blk
                           #:datum-literals (block)
                           [(block . _) #`(rhombus-body-at . #,blk)]
                           [_ #`(rhombus-expression #,blk)]))]
                  [converter (added-field-converter added)]
                  [annotation-str (added-field-annotation-str added)]
                  [form-id (added-field-form-id added)])
      #`(define tmp-id (lambda ()
                         (let ([id rhs])
                           #,(if (syntax-e #'converter)
                                 #`(converter id
                                              'form-id
                                              (lambda (who val)
                                                (raise-binding-failure who "value" val 'annotation-str)))
                                 #'id)))))))
