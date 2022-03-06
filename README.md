# Tabling with answer aggregation

This repository adds *answer aggregation*.

> The  term *answer subsumption* is used by XSB and *mode directed  tabling* by YAP and B-Prolog. The idea is that some arguments are  considered‘outputs', where multiple values for the same‘input'  are combined. Possibly *answer aggregation* would have been a  better name.

See https://www.swi-prolog.org/pldoc/man?section=tabling-mode-directed



## Modes

Currently only support `nt` and `first`.

`first` denotes that it is not tabled in the subgoal frame and only the first answer will be recorded;

`nt` denotes that it is not tabled in the subgoal frame and no answer will be recorded;

N.B. In [Mode-Directed Tabling for Dynamic Programming, Machine Learning, and Constraint Solving](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.225.4784), the authors mentioned `nt`, but I'm not sure if they are the `nt` here. They also said the `nt` is useful in some cases.



## Limitation

1. Other modes e.g. `last`, `po`, `lattice`, etc are not supported. This is because the current tabling lacks a true *Aggregate* process. We need a `findall`-like mechanism to wait for all answers related with a master call. It is something like a nested `run`. In addition, we have to coordinate execution between those nested `run`s, because miniKanren uses interleaved search, which is different from DFS in Prolog.

2. None of the modes is sound, for example,

   ```
   ((patho-tabled 'a 'b) q)              => (a b)
   ((patho-tabled 'a 'b) '(a b))         => (_.0)
   ((patho-tabled 'a 'b) '(a b c b))     => (_.0)
   ((patho-tabled 'a 'b) '(a b c b c b)) => ()
   ```

   N.B. Most of *mode directed tabling* in Prolog are unsound as well, although the sound implementation exists,  see [Tabling with Sound Answer Subsumption](https://arxiv.org/abs/1608.00787). Also, it is difficult to predict the result of *mode directed tabling* , because they are very dependent on the scheduling strategy. For the same query, different scheduling strategy (e.g. *batched scheduling* vs *local scheduling*) may yield different answers, see [Dynamic Mixed-Strategy Evaluation of Tabled Logic Programs](https://link.springer.com/chapter/10.1007/11562931_20). BTW, SWI-Prolog implements *local scheduling*, see https://swi-prolog.discourse.group/t/tabling-the-wolf-sheep-cabbage/1893/21.

   

## TODO

Further explore answer aggregation in miniKanren.



# Original `tabling`'s README

Tabling in miniKanren, similar or identical to the implementation described in Part IV of my dissertation: https://github.com/webyrd/dissertation-single-spaced

This code was designed my Ramana Kumar and myself at Indiana University, while working with Dan Friedman.  Ramana implemented the design, which we debugged together.

Please see Section 12.2 of my dissertation for references on tabling.

This implementation has several important (and severe!) limitations:

* the only constraint handled is `==`.  Other constraints, such as `=/=`, `symbolo`, and `absento`, are not supported.

* free logic variables within a tabled goal are not allowed

* the tabling implementation is slow

* the tabling implementation is stateful

* violating any assumption of the tabling implementation is likely to result in incorrect behavior without an error message

Please see my dissertation for more about these limitations, and for a description of the implementation.


You can see the tabling code in use in this miniKanren uncourse hangout, in which we write the code in `konigsberg.scm` and `graph.scm`:

https://www.youtube.com/edit?video_id=AVhDlIFCS0s&video_referrer=watch


To run the tabling tests in Vicare Scheme, please type the following commands at the terminal:

```
> (load "vanilla-r5-minimal.scm")
> (load "tabling-tests.scm")
> (load "tabling-only-tests.scm")
```
