---
layout: page
title: C++ Template
---

# Template

## Basic

-   `template <class T>` 는 `template <typename T>` 와 같지만 되도록 `typename` 권장

```c++
template <typename T>
class Vector {
  T* data;
  int capacity, length;

  public:
    Vector(int n = 256) : data(new T[n]), capacity(n), length(0) {  }
    ~Vector() {
      if (data) delete[] data;
    }

    void push_back(T s) {
      if (capacity <= length) {
        T* temp = new T[capacity * 2];
        for (int i = 0; i < length; i++) {
          temp[i] = data[i];
        }
        delete[] data;
        data = temp;
        capacity *= 2;
      }
      data[length++] = s;
    }

    T operator[](int index) { return data[index]; }

    void remove(int index) {
      for (int i = index + 1; i < length; i++) {
        data[i - 1] = data[i];
      }
      length--;
    }

    const int size() { return length; }
}
```

## Function Object, or Functor

-   `operator ()` 를 오버라이딩해서 함수인 것처럼 동작하게 한다.

```c++
struct Less {
  bool operator()(int x, int y) { return x < y; }
}
```

## Variadic Template

-   `typename` *뒤* 에 붙는 `...` 을 **템플릿 파라미터 팩** 이라고 한다. 0 개 이상의 인자를 뜻한다.
-   함수 인자 *앞* 에 붙는 `...` 을 **함수 파라미터 팩** 이라고 하고 역시 0 개 이상의 인자를 뜻한다.
-   재귀함수라고 생각하면 된다. 따라서 함수 인자가 하나만 있을 때 동작할 베이스 케이스도 작성해줘야 한다. 이때 주의할 점은 가변인자 함수보다 베이스 케이스 함수가 더 먼저 정의되어야 한다.

```c++
size_t GetStringSize(const char* s) { return strlen(s); }
size_t GetStringSize(const std::string& s) { return s.size(); }

template <typename String, typename...Strings>
size_t GetStringSize(const String& s, Strings... strs) {
  return GetStringSize(s) + GetStringSize(strs...);
}

void AppendToString(std::string* str) { }

template <typename String, typename... Strings>
void AppendToString(std::string* str, const String& s, Strings... strs) {
  str->append(s);
  AppendToString(str, strs...);
}

template <typename String, typename... Strings>
std::string StrCat(const String& s, Strings... strs) {
  // calcuate the length of the concatenated string
  size_t totalSize = GetStringSize(s, strs...);

  // allocate space in advance
  std::string res;
  res.reverse(totalSize);

  res = s; // initial string
  AppendToString(&res, strs...);

  return res;
}
```

## Fold Expression

-   C++17에서 도입된 기능(?). 걍 OCaml 폴드다..

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-left">문법</td>
<td class="org-left">이름</td>
<td class="org-left">풀리는 형태</td>
</tr>

<tr>
<td class="org-left"><code>(E op ...)</code></td>
<td class="org-left">Unary Fold Right</td>
<td class="org-left"><code>(E1 op (... op (EN-1 op EN)))</code></td>
</tr>

<tr>
<td class="org-left"><code>(... op E)</code></td>
<td class="org-left">Unary Fold Left</td>
<td class="org-left"><code>(((E1 op E2) op ...) op EN)</code></td>
</tr>

<tr>
<td class="org-left"><code>(E op ... op I)</code></td>
<td class="org-left">Binary Fold Right</td>
<td class="org-left"><code>(E1 op (... op (EN-1 op (EN op I))))</code></td>
</tr>

<tr>
<td class="org-left"><code>(I op ... op E)</code></td>
<td class="org-left">Binary Fold Left</td>
<td class="org-left"><code>((((I op E1) op E2) op ...) op EN)</code></td>
</tr>
</tbody>
</table>
