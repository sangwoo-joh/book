---
layout: page
tags: [problem-solving, theory, python, tips, recursion]
title: Powerset
---

{: .no_toc }
## Table of Contents
{: .no_toc .text-delta }
- TOC
{:toc}

# Powerset

``` python
def powerset(nums):
    """
    e.g. nums = [1,2] then returns
    [[1,2],
     [1],
     [2],
     []
    ]
    """
    result = []
    partial = []

    def recurse(idx):
        if idx == len(nums):
            # finish
            result.append(partial[:])  # must be copied
            return

        partial.append(nums[idx])  # pick this item
        recurse(idx + 1)
        partial.pop()  # not pick this item
        recurse(idx + 1)

    recurse(0)
    return result
```

 - Simply use `seq[:]` to deepcopy a sequence.
