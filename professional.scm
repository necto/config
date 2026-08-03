(load "common.scm")

;; The corporate CloudFlare TLS-inspection proxy re-signs some hosts (e.g. the
;; Azure blob storage that GitHub artifact downloads redirect to) with a private
;; CA. gh (Go) and other tools obey SSL_CERT_FILE and ignore the system
;; /etc/ssl/certs, so fold that CA into the bundle we point SSL_CERT_FILE at.
;; nss-certs ships individual PEMs (the single bundle is a profile hook), so
;; concatenate every *.pem plus the corp cert. The corp cert is read from the
;; system store at reconfigure time -- it is not committed to this repo.
(define %ca-certificates-with-corp
  (let ((corp-cert
         (local-file "/etc/ssl/certs/Sonar-CloudFlare-Inspection-Cert.pem")))
    (computed-file
     "ca-certificates-with-corp.crt"
     #~(begin
         (use-modules (ice-9 ftw)
                      (ice-9 textual-ports)
                      (srfi srfi-13))
         (define (append-file out f)
           (call-with-input-file f
             (lambda (in)
               (put-string out (get-string-all in))
               (put-char out #\newline))))
         (let ((certs-dir (string-append #$nss-certs "/etc/ssl/certs")))
           (call-with-output-file #$output
             (lambda (out)
               (for-each
                (lambda (name)
                  (append-file out (string-append certs-dir "/" name)))
                (sort (scandir certs-dir
                               (lambda (n) (string-suffix? ".pem" n)))
                      string<?))
               (append-file out #$corp-cert))))))))

(home-env "professional" '("/home/arseniy/.sonar/bin/")
          #:ssl-cert-file %ca-certificates-with-corp)
