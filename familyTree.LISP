;;;; -*- Mode: Lisp; -*-
;;;; Team Members: Rahul Thapa, Alexis Norcross, Madison Landes
;;;;
;;;;
;;;; Submission Deadline: Sunday, December 8, 11:59:59pm
;;;; Report Deadline: Monday, December 9, 11:59:59pm


;;;-------------------------------
;;;PROJECT CODE STARTS HERE.
;;;-------------------------------

(DEFSTRUCT (person
   (:print-function print-person))
  "Makes a person struct with name of the person, its 2 parents, and childrens"
  (parent1 NIL)
  (parent2 NIL)
  (name NIL)
  (children NIL)) 


(DEFUN print-person (item stream depth)
  "A helper function for Lispworks to be able to show you what is
in a person structure concisely."
    (DECLARE (IGNORE depth))
    (FORMAT stream "#<P name:~S p1:~S p2:~S>"
            (person-name item) (person-parent1 item) (person-parent2 item) (person-children item))
    item)



;;;NOTE: This function is complete. No need to change it.
(DEFUN lookup-person (name tree)
  "Returns a PERSON structure corresponding to the key NAME in the hashtable TREE.
NAME must be a STRING or a SYMBOL. If there is no one in the tree with the name
in NAME, returns NIL."
  (GETHASH name tree nil))


;;;NOTE: This function is complete. No need to change it.
(DEFUN person-exists (name tree)
  "Returns T when the key NAME has an actual person struct stored in TREE.
Returns NIL (false) otherwise."
  (WHEN (lookup-person name tree)
    t))


;;;NOTE: This function is complete. No need to change it.
(DEFUN getAncestorsList (name tree)
  "Returns a list of names (strings or symbols) of all the ancestors of NAME in TREE.
Does dynamic type checking to see whether all the arguments are of the correct types."
  (WHEN (NOT (OR (SYMBOLP name) (STRINGP name)))
    (ERROR "ANCESTORS called with NAME (~A) that is not a SYMBOL or STRING." name))
  (WHEN (NOT (HASH-TABLE-P tree))
    (ERROR "ANCESTORS called with TREE (~A) that is not a HASH-TABLE." tree))
  (WHEN (person-exists name tree)
  ;  (SETF ancestorList (LIST))
    (ancestorsb name tree)))

(DEFUN ancestorsb (name tree)
  "A helper function for the ANCESTORS function. 
Returns a list of names (strings or symbols) of all the ancestors of NAME in TREE. 
Does not remove any duplicated names! Does not sort names! Does not check if NAME 
exists as a person in the TREE!"
  (LET* ((p (lookup-person name tree))
         (parent1 (person-parent1 p))
         (parent2 (person-parent2 p)))
    (when parent1
      (append (list parent1 parent2)
              (ancestorsb parent1 tree)
              (ancestorsb parent2 tree)))))
       




(DEFUN add-person (name struct tree)
  "This should enter the person structure in STRUCT into
the hashtable in TREE with the key in NAME."
  (WHEN (NOT (HASH-TABLE-P tree))
    (ERROR "STORE-PERSON called with TREE (~A) that is not a HASH-TABLE." tree))
  (WHEN (NOT (person-p struct))
    (ERROR "STORE-PERSON called with STRUCT (~A) that is not a PERSON structure." struct))
  (WHEN (NOT (OR (SYMBOLP name) (STRINGP name)))
    (ERROR "STORE-PERSON called with NAME (~A) that is not a SYMBOL or a STRING." name))
  ;; NOTE1: TEAMS NEED TO WRITE THE NEXT LINE.
  ;;        Hint: a "setf" expression.
  (SETF (GETHASH name tree) struct)
  (add-child name tree)
  name
  )


(DEFUN printlist (personlist)
  "A helper function for printing out lists. Removes duplicates and sorts before
printing."
  (FORMAT T "~{~a~%~}" (SORT (REMOVE-DUPLICATES personlist :test #'equal) #'string-lessp))
  )


(DEFUN getChildrenList (name tree)
  "Returns a list of the children of NAME in TREE."
  (LET* ((p (lookup-person name tree)))
    (person-children p)
    )
  )


(DEFUN getSiblingsList (name tree)
  (LET* ((p (lookup-person name tree))
         (siblings nil))
    (WHEN (person-parent1 p)
      (SETF siblings (APPEND siblings (getChildrenList (person-parent1 p) tree) (getChildrenList (person-parent2 p) tree))))
    (SETF siblings (REMOVE name siblings :test #'equal))
    siblings))

(DEFUN hasCommonAncestor (person1 person2 tree)
  (LET* ((ancestor1 (getAncestorsList person1 tree))
         (ancestor2 (getAncestorsList person2 tree)))
    (intersection ancestor1 ancestor2 :test #'equal)))

(DEFUN isUnrelated (person1 person2 tree)
  (IF (or (member person1 (getAncestorsList person2 tree) :test #'equal) (member person2 (getAncestorsList person1 tree) :test #'equal))
      nil
    (not (hasCommonAncestor person1 person2 tree))))



(DEFUN allpeople (tree)
  "Returns a list of all people in the tree."
  (LET* ((people (LIST)))
    (maphash #'(lambda (k v) (DECLARE (IGNORE v)) (SETF people (APPEND people (LIST k)))) tree)
    people
    )
  )


(DEFUN getUnrelatedList (name tree)
  (LET* ((people (allPeople tree))
         (unrelated nil))
    (LOOP for person in people do
          (WHEN (isUnrelated name person tree)
              (SETF unrelated (APPEND unrelated (list person)))))
    unrelated))

;-------------------------------------

(DEFSTRUCT ancestorGen 
  (name nil)
  (generation 0))

(DEFUN add-ancestor (name struct ancestorTree)
  (SETF (GETHASH name ancestorTree) struct))


(DEFUN getAncestorWeight (ancestorTree p gen)
  (COND ((and (person-exists p tree)
              (person-parent1 (lookup-person p tree)))
         (add-ancestor (person-parent1 p tree) (make-ancestorGen :name (person-parent1 (lookup-person p tree)) :generation (+ gen 1)) ancestorTree)
         (add-ancestor (person-parent2 (lookup-person p tree)) (make-ancestorGen :name (person-parent2 (lookup-person p tree)) :generation (+ gen 1)) ancestorTree)
         (getAncestorWeight ancestorTree (person-parent1 (lookup-person p tree)) (+ gen 1))
         (getAncestorWeight ancestorTree (person-parent2 (lookup-person p tree)) (+ gen 1))
         ancestorTree)))


(DEFUN smallest (l)
; takes a list 
; return the smallest element
  (apply 'min l)
)


(DEFUN hasCousinRelation(personA cousinNum personB tree)
  (IF (string= personA personB)
      nil)
  (IF (or (member personA (person-children (lookup-person personB tree)))(member personB (person-children (lookup-person personA tree))))
      nil)
  (LET ((ancestorTree1 (MAKE-HASH-TABLE :size 1000 :test #'equal))
        (ancestorTree2 (MAKE-HASH-TABLE :size 1000 :test #'equal))
        (ancestorWeight1 (getAncestorWeight ancestorTree1 personA 0))
        (ancestorWeight2 (getAncestorWeight ancestorTree2 personB 0))
        (minGen nil))
    (LOOP for keyA being the hash-keys of ancestorWeight1 doing 
          (if (GETHASH keyA ancestorWeight2) 
              (cons (min (ancestorGen-generation (lookup-person keyA ancestorWeight1)) (ancestorGen-generation (lookup-person keyA ancestorWeight2))) minGen))) 
    (and (> (list-length minGen) 0) (= (- (smallest minGen) 1) cousinNum))))
      
         


(DEFUN getCousinsList(personA cousinNum tree)
  "Gets the list of all cousin of certain degree of personA"
  (sort (remove nil (loop for tempPerson being the hash-values of tree collecting
                          (if (hasCousinRelation personA cousinNum tempPerson tree) (tempPerson)))) #'equal<)) 
  

;---------------------------------


(DEFUN add-child (name tree)
  (LET* ((p (lookup-person name tree)))
    (IF (person-parent1 p)
        (SETF (person-children (lookup-person (person-parent1 p) tree))
              (APPEND (person-children (lookup-person (person-parent1 p) tree)) (LIST name))))
    (IF (person-parent2 p)
        (SETF (person-children (lookup-person (person-parent2 p) tree))
              (APPEND (person-children (lookup-person (person-parent2 p) tree)) (LIST name))))))

  
(DEFUN handle-E (linelist tree)
  (IF (not (person-exists (nth 0 linelist) tree))
      (add-person (nth 0 linelist) (make-person :name (nth 0 linelist) :parent1 nil :parent2 nil) tree))
  (IF (not (person-exists (nth 1 linelist) tree))
      (add-person (nth 1 linelist) (make-person :name (nth 1 linelist) :parent1 nil :parent2 nil) tree))
  (IF (= (LIST-LENGTH linelist) 3)
      (add-person (nth 2 linelist) (make-person :name (nth 2 linelist) :parent1 (nth 0 linelist) :parent2 (nth 1 linelist)) tree)))


(DEFUN handle-X (linelist tree)
  "LINELIST is a LIST of strings. TREE is a hash-table."
  (FORMAT T "X ~{~a ~}~%" linelist)

  (IF (STRING= (nth 1 linelist) "child")
    (IF (person-exists (nth 2 linelist) tree)
      (IF (MEMBER (nth 0 linelist) (getChildrenList (nth 2 linelist) tree) :test #'equal)
        (FORMAT T "Yes~%")
        (FORMAT T "No~%"))
      (FORMAT T "~a does not exist in the family tree.~%" (nth 2 linelist))))

  (IF (STRING= (nth 1 linelist) "sibling")
    (IF (person-exists (nth 2 linelist) tree)
      (IF (MEMBER (nth 0 linelist) (getSiblingsList (nth 2 linelist) tree) :test #'equal)
        (FORMAT T "Yes~%")
        (FORMAT T "No~%"))
      (FORMAT T "~a does not exist in the family tree.~%" (nth 2 linelist))))

  (IF (STRING= (nth 1 linelist) "ancestor")
    (IF (person-exists (nth 2 linelist) tree)
      (IF (MEMBER (nth 0 linelist) (getAncestorsList (nth 2 linelist) tree) :test #'equal)
        (FORMAT T "Yes~%")
        (FORMAT T "No~%"))
      (FORMAT T "~a does not exist in the family tree.~%" (nth 2 linelist))))

  (IF (STRING= (nth 1 linelist) "cousin")
    (IF (person-exists (nth 3 linelist) tree)
        (IF (hasCousinRelation (nth 0 linelist) (nth 2 linelist) (nth 3 linelist) tree)
;      (IF (MEMBER (nth 0 linelist) (getCousinsList (nth 3 linelist) (nth 2 linelist) tree) :test #'equal)
        (FORMAT T "Yes~%")
        (FORMAT T "No~%"))
      (FORMAT T "~a does not exist in the family tree.~%" (nth 2 linelist))))

  (IF (STRING= (nth 1 linelist) "unrelated")
    (IF (person-exists (nth 2 linelist) tree)
      (IF (MEMBER (nth 0 linelist) (getUnrelatedList (nth 2 linelist) tree) :test #'equal)
        (FORMAT T "Yes~%")
        (FORMAT T "No~%"))
      (FORMAT T "~a does not exist in the family tree.~%" (nth 2 linelist))))
  (TERPRI))


;;NOTE: This function needs to be defined by team
(DEFUN handle-W (linelist tree)
  "LINELIST is a LIST of strings. TREE is a hash-table."
  (FORMAT T "W ~{~a ~}~%" linelist)

  (IF (STRING= (nth 0 linelist) "child")
    (IF (person-exists (nth 1 linelist) tree)
      (printlist (getChildrenList (nth 1 linelist) tree))
      (FORMAT T "~a does not exist in the family tree.~%" (nth 1 linelist))))

  (IF (STRING= (nth 0 linelist) "sibling")
    (IF (person-exists (nth 1 linelist) tree)
      (printlist (getSiblingsList (nth 1 linelist) tree))
      (FORMAT T "~a does not exist in the family tree.~%" (nth 1 linelist))))

  (IF (STRING= (nth 0 linelist) "ancestor")
    (IF (person-exists (nth 1 linelist) tree)
      (printlist (getAncestorsList (nth 1 linelist) tree))
      (FORMAT T "~a does not exist in the family tree.~%" (nth 1 linelist))))

  (IF (STRING= (nth 0 linelist) "cousin")
    (IF (person-exists (nth 2 linelist) tree)
      (printlist (getCousinsList (nth 2 linelist) (nth 1 linelist) tree))
      (FORMAT T "~a does not exist in the family tree.~%" (nth 2 linelist))))

  (IF (STRING= (nth 0 linelist) "unrelated")
    (IF (person-exists (nth 1 linelist) tree)
      (printlist (getUnrelatedList (nth 1 linelist) tree))
      (FORMAT T "~a does not exist in the family tree.~%" (nth 1 linelist))))
  (TERPRI))

;;NOTE: This function is complete.
(DEFUN family (stream)
  "This is the top-level function for the whole Lisp program. Reads
each line from the file opened in STREAM."
  (LET ((tree (MAKE-HASH-TABLE :size 1000 :test #'equal))
        (line-items (SPLIT-SEQUENCE " " (READ-LINE stream nil "") :test #'equal)))
  (LOOP
    (COND
      ((STRING= (nth 0 line-items) "E")
        (handle-E (REST line-items) tree))
      ((STRING= (nth 0 line-items) "W")
        (handle-W (REST line-items) tree))
      ((STRING= (nth 0 line-items) "X")
        (handle-X (REST line-items) tree))
      (t
        (RETURN nil)))
    (SETF line-items (SPLIT-SEQUENCE " " (READ-LINE stream nil "") :test #'equal)))))


;;;A helpful tester function for debugging your tree.
(DEFUN test-tree ()
  (LET ((tree (MAKE-HASH-TABLE :size 1000 :test #'equal)))
    (handle-E '("John" "Mary" "Bill") tree)
    (handle-E '("John" "Mary" "Pete") tree)
    (handle-E '("John" "Mary" "Fred") tree)
    (handle-E '("John" "Jean" "Rebecca") tree)
    (handle-E '("Rebecca" "Bill" "Andrew") tree)
    (handle-E '("Pete" "Carol" "Jim") tree)
    (handle-E '("Karen" "Bill" "Alex") tree)
    (handle-W '("ancestor" "Andrew") tree)
    )
  )

