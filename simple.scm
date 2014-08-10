(define-module (html simple)
  #:export (
            doctype-xhtml11
            doctype-html5
            default-doctype
            make-html-page
            write-html-page
            ))

(use-modules (sxml simple)
             (ice-9 popen))

(define doctype-xhtml11
  "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"
\"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">")

(define doctype-html5
  "<!DOCTYPE html>")

(define default-doctype (make-parameter doctype-html5))

(define* (make-html-page
          title body #:key
          (content-type "text/html; charset=utf-8")
          (head-additions '())
          )
  `(*TOP*
    (html
     (@ (xmlns "http://www.w3.org/1999/xhtml"))
     (head
      (title ,title)
      (meta (@ (http-equiv "Content-Type")
               (content ,content-type)))
      ,@head-additions)
     ,body)))

(define (open-xmllint-pipe)
  (open-pipe* OPEN_WRITE "xmllint" "--format" "-"))

(define* (write-html-page
          title body #:key
          (doctype (default-doctype))
          (pretty-print #t))
  (define (write-it)
    (display doctype)
    (sxml->xml (make-html-page title body)))
  (if pretty-print
      (parameterize ((current-output-port (open-xmllint-pipe)))
        (write-it)
        (close-pipe (current-output-port)))
      (write-it)))
