(require 'test-simple)
(load-file "../realgud/debugger/pdb/pdb.el")

(declare-function pdb-parse-cmd-args 'realgud:pdb)

(test-simple-start)

(note "pdb-parse-cmd-args")
(assert-equal '(nil ("pdb") ("foo") nil)
	      (pdb-parse-cmd-args '("pdb" "foo")))
(assert-equal '(nil ("pdb") ("program.py" "foo") nil)
	      (pdb-parse-cmd-args
	       '("pdb" "program.py" "foo")))
(end-tests)
