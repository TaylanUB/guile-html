;;; simple.el --- HTML-specific wrapper for SXML

;; Copyright © 2015 Taylan Ulrich Bayırlı/Kammer <taylanbayirli@gmail.com>

;; Author: Taylan Ulrich Bayırlı/Kammer <taylanbayirli@gmail.com>
;; Keywords: html xhtml xml sxml

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; The SXML module makes it very nice to work with XML data, but HTML documents
;; still require some annoying boilerplate.  This module factors that out.

;;; Code:

(define-module (html simple)
  #:export (
            doctype-xhtml11
            doctype-html5
            default-doctype
            make-html-document
            make-html-document-from-body-nodes
            write-html-document
            convert-sxml-html-file
            convert-sxml-html-body-file
            ))

(use-modules (sxml simple)
             (ice-9 popen))

(define doctype-xhtml11
  "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"
\"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">")

(define doctype-html5
  "<!DOCTYPE html>")

(define default-doctype (make-parameter doctype-html5))

(define* (make-html-document
          title body #:key
          (content-type "text/html; charset=utf-8")
          (head-additions '())
          )
  "Makes an HTML document object."
  `(html
    (@ (xmlns "http://www.w3.org/1999/xhtml"))
    (head
     (title ,title)
     (meta (@ (http-equiv "Content-Type")
              (content ,content-type)))
     ,@head-additions)
    ,body))

(define* (make-html-document-from-body-nodes nodes #:key title)
  "Make a complete HTML document object from a list of body nodes."
  (let ((title (or title (sxml->string (car nodes)))))
    (make-html-document title `(body ,@nodes))))

(define (open-xmllint-pipe)
  (open-pipe* OPEN_WRITE "xmllint" "--format" "-"))

(define* (write-html-document
          document #:key
          (doctype (default-doctype))
          (pretty-print #t))
  "Writes out an HTML document object as XML.  No validation is done on the
document object."
  (define (write-it)
    (display doctype)
    (sxml->xml document))
  (if pretty-print
      (parameterize ((current-output-port (open-xmllint-pipe)))
        (write-it)
        (close-pipe (current-output-port)))
      (write-it)))

(define* (convert-sxml-html-file
          #:optional file
          #:key
          (doctype (default-doctype))
          (pretty-print #t))
  "Reads a file (or standard-input-port) containing an HTML document object in
SXML form, and writes it out as XML.  No validation is done on the document
object."
  (let ((document (if file
                      (with-input-from-file file read)
                      (read))))
    (write-html-document
     document #:doctype doctype #:pretty-print pretty-print)))

(define (read-sxml-nodes)
  (let read-nodes ((nodes '()))
    (let ((node (read)))
      (if (eof-object? node)
          (reverse nodes)
          (read-nodes (cons node nodes))))))

(define* (convert-sxml-html-body-file
          #:optional file
          #:key
          title
          (doctype (default-doctype))
          (pretty-print #t))
  "Reads a file (or standard-input-port) containing top-level SXML forms
representing the body of an HTML document, adds boilerplate to make a complete
HTML document object, then writes it out as XML."
  (let ((nodes (if file
                   (with-input-from-file file read-sxml-nodes)
                   (read-sxml-nodes))))
    (write-html-document
     (make-html-document-from-body-nodes nodes #:title title)
     #:doctype doctype #:pretty-print pretty-print)))

;;; simple.scm ends here
