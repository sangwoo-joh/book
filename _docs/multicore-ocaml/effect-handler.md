---
layout: page
tags: [ocaml, effect-handler, wip]
title: Retrofitting Effect Handlers onto OCaml (WIP)
---

# 이팩트 핸들러 장착하기

## 2. Background: OCaml Stacks
 멀티코어 OCaml에 이펙트 핸들러를 구현하는 데 있어 가장 큰 도전은 바로
 프로그램 스택을 관리하고 바람직한 성질을 유지하는 것이다. 여기서는
 프로그램 스택과 원래 OCaml에서의 메커니즘에 대한 개요를 살펴본다.
