(require 'request)

(defvar text2qr-size "200x200"
  "Specifies the size of the QR code image you want to generate in the \"[integer]x[integer]\" format.")

(defun text2qr ()
  "Generate QR code by the text.

It use QR code API to generate QR code. You can see the details in http://goqr.me/api/doc/create-qr-code/"
  (interactive)
  (let* ((text (if (region-active-p)
                   (buffer-substring-no-properties (region-beginning)
                                                   (region-end))
                 (read-string "The Text: ")))
         (width 200)
         (height 200)
         (size (format "%sx%s" width height))
         (url "https://api.qrserver.com/v1/create-qr-code/"))
    (request url
             :sync t
             :params `(("data" . ,text)
                       ("size" . ,size)
                       ("format" . "svg"))
             :parser (lambda ()
                       (let ((data (buffer-substring-no-properties (point)
                                                                   (point-max))))
                         (create-image data nil t)))
             :success (cl-function
                       (lambda (&key data &allow-other-keys)
                         (with-current-buffer (get-buffer-create "*TEXT2QR*")
                           (erase-buffer)
                           (insert text)
                           (add-text-properties (point-min)
                                                (point-max)
                                                `(display ,data)))
                         (display-buffer "*TEXT2QR*")))
             )))
