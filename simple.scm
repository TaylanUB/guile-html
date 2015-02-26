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
  "Makes an HTML page object."
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
          page #:key
          (doctype (default-doctype))
          (pretty-print #t))
  "Writes out an HTML page object as XML."
  (define (write-it)
    (display doctype)
    (sxml->xml page))
  (if pretty-print
      (parameterize ((current-output-port (open-xmllint-pipe)))
        (write-it)
        (close-pipe (current-output-port)))
      (write-it)))

;;; simple.scm ends here
