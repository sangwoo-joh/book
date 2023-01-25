---
layout: page
tags: [wip, theory]
title: A Unified Approach to Global Program Optimization
---

# A Unified Approach to Global Program Optimization

 by [Gray
 A. Kildall](http://static.aminer.org/pdf/PDF/000/546/451/a_unified_approach_to_global_program_optimization.pdf),
 1972

## Abstract

 A technique is presented for global analysis of program structure in
 order to perform compile time optimization of object code generated
 for expressions. The global expression optimization presented
 includes constant propagation, common subexpression elimination,
 elimination of redundant register load operations, and live
 expression analysis. A general purpose program flow analysis
 algorithm is developed which depends upon the existence of an
 "optimizing function." The algorithm is defined formally using a
 directed graph model of program flow structure, and is shown to be
 correct. Several optimizing functions are defined which, when used in
 conjunction with the flow analysis algorithm, provide the various
 forms of code optimization. The flow analysis algorithm is
 sufficiently general that additional functions can easily be defined
 for other forms of global code optimization.

## Introduction

 A number of techniques have evolved for the compile-time analysis of
 program structure in order to locate redundant computations, perform
 constant computations, and reduce the number of store-load sequences
 between memory and high-speed registers. Some of these techniques
 provide analysis of only straight-line sequences of instructions,
 while others take the program branching structure into account. The
 purpose here is to describe a single program flow analysis algorithm
 which extends all of these straight-line optimizing techniques to
 include branching structure. The algorithm is presented formally and
 is shown to be correct. Implementation of the flow analysis algorithm
 in a practical compiler is also discussed.

 The methods used here are motivated in the section which follows.

## A Global Analysis Algorithm

 Based upon these observations, it is possible to informally state a
 global analysis algorithm.

 1. Start with an entry node in the program graph, along with a given
    entry pool corresponding to this entry node. Normally, there is
    only one entry node, and the entry pool is empty.
 2. Process the entry node, and produce optimizing information which
    is sent to all immediate successors of the entry node.
 3. Intersect the incoming optimizing pools with that already
    established at the successor nodes (if this is the first time the
    node is encountered, assume the incoming pool as the first
    approximation and continue processing).
 4. Considering each successor node, if the amount of optimizing
    information is reduced by this intersection (or if the node has
    been encountered for the first time) then process the successor in
    the same manner as the initial entry node (the order in which the
    successor nodes are processed is unimportant).

 In order to generalize the above notions, it is useful to define an
 "optimizing function" `f` which maps an "input" pool, along with a
 particular node, to a new "output" pool. Given a particular set of
 propagated constants, for example, it is possible to examine the
 operation at a particular node and determine the set of propagated
 constants which can be assumed after the node is executed. In the
 case of constant propagation, the function can be informally stated
 as follows. Let `V` be a set of variables, let `C` be a set of
 constants, and let `N` be the set of nodes in the graph being
 analyzed. The set $$ U = V \times C $$ represents ordered pairs which
 may appear in any constant pool. In fact, all constant pools are
 elements of the power set of `U` (i.e., the set of all subsets of
 `U`), denoted by $$ \mathcal{P}(U) $$. Thus, $$ f: N \times
 \mathcal{P}(U) \mapsto \mathcal{P}(U) $$, where $$ (v, c) \in f(N, P)
 $$

 1. $$ (v, c) \in P $$ and the operation at node `N` does not assign a
    new value to the variable `v`, or
 2. the operation at node `N` assigns an expression to the variable
    `v`, and the expression evaluates to the constant `c`, based upon
    the constans in `P`.
