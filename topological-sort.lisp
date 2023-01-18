(defparameter *edge-list* '((1 . 7)
                            (1 . 2)
                            (1 . 4)
                            (2 . 8)
                            (2 . 5)
                            (6 . 8)
                            (2 . 6)
                            (3 . 6)
                            (7 . 8)
                            (4 . 8)
                            (5 . 6)))

(defun t-sort (edge-list)
  (let ((indeg (make-hash-table))
        (possible-roots (union (remove-duplicates (mapcar #'car edge-list))
                               (remove-duplicates (mapcar #'cdr edge-list))))
        (sorted-nodes nil)
        (found-root nil))
    (loop for (from . to) in edge-list do
      (let ((i (gethash to indeg 0)))
        (setf (gethash to indeg) (1+ i))))
    (setf found-root t)
    (do ()
        ((or (null possible-roots)
             (not found-root))
         (if (not found-root)
             nil
             (reverse sorted-nodes)))
      (setf found-root nil)
      (loop for node in possible-roots do
        ;(format t "~a~%" (reverse sorted-nodes))
        (when (= (gethash node indeg 0) 0)
            (progn (push node sorted-nodes)
                   (setf possible-roots (remove node possible-roots))
                   (setf found-root t)
                   (loop for (from . to) in edge-list do
                     (when (= from node)
                       (let ((i (gethash to indeg)))
                         (setf (gethash to indeg) (1- i)))))))))))