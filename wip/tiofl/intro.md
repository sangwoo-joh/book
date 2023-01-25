---
layout: page
title: Introduction
---

 [책](https://www.microsoft.com/en-us/research/publication/the-implementation-of-functional-programming-languages/)의
 머릿글에서 관심있는 부분만 발췌함

# Introduction

 This book is about implementing functional programming languages
 using *lazy graph reduction*, and it divides into three parts.

 The first part describes how to translate a high-level functional
 language into an intermediate language, called the lambda calculus,
 including detailed coverage of pattern-matching and
 type-checking. The second part begins with a simple implementation of
 the lambda calculus, based on graph reduction, and then develops a
 number of refinements and alternatives, such as super-combinators,
 full laziness and SK combinators. Finally, the third part describes
 the G-machine, a sophisticated implemenation of graph reduction,
 which provides a dramatic increase in performance over the
 implementations described earlier.

 One of the agreed advantages of functional languages is their
 semantic simplicity. This simplicity has considerable payoffs in the
 book. Over and over again we are able to make semi-formal arguments
 for the correctness of the compilation algorithms, and the whole book
 has a distinctly mathematical flavor - an unusual feature in a book
 about implementations.

 Most of the material to be presented has appeared in the published
 literature in some form (though some has not), but mainly in the form
 of conference proceedings and isolated papers. References to this
 work appear at the end of each chapter.

## Part 1: Compiling High-level Functional Languages

 It has been widely observed that most functional languages are quite
 similar to each other, and differ more in their syntax than their
 semantics. In order to simplify our thinking about implementations,
 the first part of this book shows how to translate a high-level
 functional program into an *intermediate language* which has a very
 simple syntax and semantics. Then, in the second and thrid parts of
 the book, we will show how to implement this intermediate language
 using graph reduction. Proceeding in this way allows us to describe
 graph reduction in considerable detail, but in a way that is not
 specific to any particular high-level language.

 The intermediate language into which we will translate the high-level
 functional program is the notation of the *lambda calculus*. The
 lambda calculus is an extremely well-studied language, and we give an
 introduction to it in Chapter 2.

 The lambda calculus is not only simple, it is also sufficiently
 expressive to allow us to translate any high-level functional
 language into it. However, translating some high-level language
 constructs into the lambda notation is less straightforward than it
 at first appears, and the rest of Part 1 is concerned with this
 translation.

 Part 1 is organized as follows. First of all, in Chapter 3, we define
 a language which is a superset of the lambda calculus, which we call
 the *enriched lambda calculus*. The extra constructs provided by the
 enriched lambda calculus are specifically designed to allow a
 straightforward translation of a Miranda program into an expression
 in the enriched lambda calculus, and Chapter 3 shows how to perform
 this translation for simple Miranda programs.

 After a brief introduction to pattern-matching, Chapter 4 then
 extends the translation algorithm to cover more complex Miranda
 programs, and gives a formal semantics for
 pattern-matching. Subsequently, Chapter 7 rounds out the picture, by
 showing how Miranda's ZF expressions can also be translated in the
 same way. (Various advanced features of Miranda are not covered, such
 as algebraic types with laws, abstract data types, and modules.)

 Much of the rest of Part 1 concerns the transformation of enriched
 lambda calculus expressions into the ordinary lambda calculus subset,
 a process which is quite independent of Miranda. This
 language-independence was one of the reasons for defining the
 enriched lambda calculus language in the first place. Chapter 5 shows
 how expressions involving pattern-matching constructs may be
 transformed to use case-expressions, with a considerable gain in
 efficiency. Then Chapter 6 shows how all the constructs of the
 enriched lambda calculus, including case-expressions, may be
 transformed into the ordinary lambda calculus.

 Part 1 concludes with Capter 8 which discusses type-checking in
 general, and Chapter 9 in which a type-checker is constructed in
 Miranda.

## Part 2: Graph Reduction

 The rest of the book describes how the lambda calculus may be
 implemented using a technique called *graph redudcion*. It is largely
 independent of the later chapters in Part 1, Chapters 2-4 being the
 essential prerequisites.

 1. *Executing* a functional program consistes of *evaluating* an
    expression.
 2. A functional program has a natural representation as a *tree* (or,
    more generally, a *graph*).
 3. Evaluation proceeds by means of a sequence of simple steps, called
    *reductions*. Each reduction performs a local transformation of
    the graph (hence the term *graph reduction*).
 4. Reductionss may safely take place in a variety of orders, or
    indeed in parallel, since they cannot interfere with each other.
 5. Evaluation is complete when there are no further reducible
    expressions.

 Graph reduction gives an appealingly simple and elegant model for the
 execution of a functional program, and one that is radically
 different from the execution model of a conventional imperatvie
 language.

 We begin in Chapter 10 by discussing the representation of a
 functional program as a graph. The next two chapters form a pair
 which discusses first the question of deciding which reduction to
 perform next (Chapter 11), and then the act of performing the
 reduction (Chapter 12).

 Chapter 13 and 14 introduce the powerful technique of
 *supercombinators*, which is the key to the remainder of the
 book. This is followed in Chatper 15 with a discussion of *full
 laziness*, an aspect of lazy evaluation; this chapter can be omitted
 on first reading since later material does not depend on it.

 Chapter 16 then presents *SK combinators*, an alternative
 implementation technique to supercombinators. Hence, this chapter can
 be understood independently of Chapters 13-15. Thereafter, however,
 we concentrate on supercombinator-based implementations.

 Part 2 concludes with a chapter on *garbage collection*

## Part 3: Advanced Graph Reduction

 It may seem at first that graph reduction is inherently less
 efficient than more conventional execution models, at least for
 conventional von Neumann machines. The bulk of Part 3 is devoted to
 an extended discussion of the G-machine, which shows how graph
 reduction can be compiled to a form that is suitable for *direct
 execution* by ordinary sequential computers.

 In view of the radical difference between graph reduction on the one
 hand, and the linear sequence of instructions executed by
 conventional machines on the other, this may seem a somewhat
 surprising achievement. This (fairly recent) development is
 responsible for a dramatic improvement in the speed of functional
 language implementations.

 Chapter 18 and 19 introduce the main concepts of the G-machine, while
 Chatpers 20 and 21 are devoted entirely to optimizations of the
 approach.

 The book concludes with three chapters that fill in some gaps, and
 offer some pointers to the future.

 Chapter 22 introduces *stricness analysis*, a compile-time program
 analysis method which has been the subject of much recent work, and
 which is crucial to many of the optimizations of the G-machines.

 Perhaps the major shortcoming of functional programming languages,
 from the point of view of the programmer, is the difficulty of
 estimating the space and time complexity of the program. This
 question is intimately bound up with the implementation, and we
 discuss the matter in Chapter 23.

 Finally, the book concludes with a chapter on parallel
 implementations of graph reduction.


## 노트

 - 파트 1이 가장 재밌어보이고 파트 2, 3은 (내가 그다지 관심없는) lazy
   evaluation에 관한 글이니 스킵해도 될듯 (과연 찾아보니 원저자이신
   [Simon Peyton Jones](https://simon.peytonjones.org/)는 하스켈
   구현에 참여하신 분인듯.. 놀랍게도 MSR에서 24년? 지금은 에픽 게임즈
   펠로우로? 대단한 이력...)
 - 챕터 2는 람다 칼큘러스 소개
 - 챕터 3은 함수형 언어를 람다 칼큘러스로 변환하는 방법 (미란다?)
 - 챕터 4에서 드디어 타입 얘기가 나오긴 한데, 주로 패턴 매칭 관련
 - 챕터 5는 아예 패턴 매칭을 효과적으로 컴파일하는 방법에 집중. 패턴
   매칭이 그렇게 중요한 거였구만
 - 챕터 6(책에는 오타가 있음)은 "강화된(enriched)" 람다 칼큘러스 관련
 - 챕터 7은 리스트 컴프리헨션 (뜬금없이??)
 - 챕터 8에서 드디어 다형 타입 체킹
 - 챕터 9에서 타입 체커 구현
 - 챕터 17은 (파트 2이긴 하지만) 가비지 콜렉션 얘기..를 고작 10
   페이지에?!

## ZINC

 OCaml의 아버지 Xavier Leroy는 해답을 알고 있다. [The ZINC experiment:
 an economical implementation of the ML
 language](https://xavierleroy.org/bibrefs/Leroy-ZINC.html)의
 Motivation 섹션에에 아예 이런 문장이 있다:

> ... One of the best ways to really understand a language is to look
> at an actual implementation. While, for instance, toy
> implementations of Pascal abound in the literature, there is no work
> describing in detail an actual implementation of ML. Peyton-Jone's
> book [The Implementation of Functional Programming Languages] is an
> excellent introductory text, but **not totally relevant to ML**,
> since it uses Miranda, not ML, as its source language, and **it
> focuses on lazy evaluation through graph reduction**, while ML
> usually has strict semantics. A few papers on the Standard ML of New
> Jersey implementation have been published, but they are fairly
> high-level -- they don't show much of the code! And regarding the
> CAML system, nothing has been published yet, Ascander Suarez's
> thesis is still forthcoming, and in the meantime the curious mind is
> left with 70,000 lines of very sparesly commented source code.

그러니까 정확히 내가 원하는 것은 ZINC 시스템에 있다. ZINC는 "ZINC Is
Not Caml"의 recursive acronym이고 이게 바로 OCaml의 근간이 된다.
