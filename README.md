**English on the bottom section**
# 血液型の代数の実装 Implementation of blood type algebra.

AB型とO型の子供は必ずA型かB型であるという話がある。
これは個人の血液型が2つの遺伝型によってきめられ、
子供の遺伝型はその親二人が持つ双方の遺伝型を１つずつ選択する事により決定されるからである。  
  
上記の例では2里の親は双方以下の遺伝型を持つ：
血液型AB型 -> 遺伝型A型とB型  
血液型O型の親は -> 遺伝型O型とO型  
  
この二人の子供の遺伝型を双方1つずつ組み合わせはAOとBOのみであり、
それぞれ血液型はA型とB型である。故に子供は血液型A型かB型のみ生まれる。

このプログラムは上記の子供の遺伝型(血液型)決定のプロセスを以下の様に表せる様に遺伝型の加算演算子`|+|`を定義した。  
簡単に書くと上記の例に対し以下の用法で使えるものである。  
子供の遺伝型の可能性として考えられるものを列挙して出力している。
```
[A, B] |+| [O, O] = [[A, O], [B, O]]
```

この中身は直積であり大したことは無い。  
この加算に対し、遺伝型の減算演算子`|-|`も定義した。遺伝型不明の親の遺伝型の可能性を上げるものである。
子供がAB型であり父親がAA型だとすると、母親はAB型かBB型かBO型であるということが分かる。
```
[A, B] |-| [A, A] = [[A, B], [B, B], [B, O]]
```

これは先述の演算子`|+|`を利用して定義している。つまり、ありえる母親の遺伝型をすべて試してしまうのである。  

`|+|`と`|-|`は単純な定義であるが、これを利用して少々面白いことができる。
2人の兄弟がAA型、OO型であり、
父型の祖父祖母がAA型、AO型、  
母型の祖父がAA型とする。 
このとき父型の祖母の遺伝型何であろうか？実数のように以下のように方程式を利用して解くことができるだろうか？
```
(AA |+| AO)  |+|  (AA |+| ??) = [AA, OO]
?? = ([AA, OO]  |-|  (AA |+| AO))  |-|  AA
```
この`([AA, OO]  |-|  (AA |+| AO))  |-|  AA`を実行すると実際に正解である`[AA, AO, BO]`を回答する。

この挙動は以下の点で大変興味深い。
- 遺伝型が実数と同様な代数として扱えている。
- 定義した演算子は実数のように単純な演算ではなく、その裏に直積や総当りの処理を行っている。しかし利用においては実数の演算子と同様に平意に認識できる。

また実装においても以下の面白さがあった。
- Haskellの特にListモナドが効果的に利用できた。
- all, anyの利用が効果的であり、その量化の概念が遺伝型の型にも必要となった。

コードを見てみると分かるが上記で述べているようには各演算子の定義は簡単ではない。  
この代数がなぜこのコードを要したのかを考えることも大変おもしろい。
以後はこの代数系(と言ってしまって良いのかわからないが)に理論的な破れはないのか数学的に追求していきたい。  
もちろん他にも有用な演算子があれば追加したい。

There is a theory that the children of parents with blood types AB and O will always have blood type A or B. This is because an individual's blood type is determined by two genotypes, and a child's genotype is determined by selecting one genotype from each parent.

In the above example, the two parents have the following genotypes:
Blood type AB -> Genotypes A and B
Blood type O -> Genotypes O and O
The possible combinations of genotypes for their child are AO and BO, which correspond to blood types A and B, respectively. Therefore, the child will only have blood type A or B.

This program defines a genotype addition operator `|+|` to represent the process of determining the child's genotype (blood type) as described above. In simple terms, it can be used as follows to enumerate and output the possible genotypes for the child:

```
[A, B] |+| [O, O] = [[A, O], [B, O]]
```
This is essentially a Cartesian product. Additionally, a genotype subtraction operator `|-|` is defined to determine the possible genotypes of an unknown parent. For example, if the child is of blood type AB and the father is of genotype AA, the mother could be of genotype AB, BB, or BO.

```
[A, B] |-| [A, A] = [[A, B], [B, B], [B, O]]
```
This is defined using the previously mentioned `|+|` operator by trying all possible genotypes for the mother.

Although the definitions of `|+|` and `|-|` are simple, they can be used to solve interesting problems. For instance, if two siblings have genotypes AA and OO, the paternal grandparents have genotypes AA and AO, and the maternal grandfather has genotype AA, what is the genotype of the paternal grandmother? This can be solved using the following equations:

```
(AA |+| AO)  |+|  (AA |+| ??) = [AA, OO]
?? = ([AA, OO]  |-|  (AA |+| AO))  |-|  AA
```
Executing `([AA, OO] |-| (AA |+| AO)) |-| AA` correctly answers `[AA, AO, BO]`.

This behavior is intriguing because:
- Genotypes can be treated as an algebra similar to real numbers.
- The defined operators perform complex operations like Cartesian products and exhaustive searches behind the scenes, but can be understood as simple arithmetic operators.

The implementation is also interesting because:
- Haskell's List Monad was used effectively.
- The use of all and any was efficient, and the concept of quantification was necessary for the genotypes' types.

As you can see from the code, the definitions of these operators are not simple. Understanding why this algebra requires such code is fascinating. Going forward, I aim to explore mathematically whether there are any theoretical flaws in this algebra (if I can call it that). I also plan to add any other useful operators if discovered.
