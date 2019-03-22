# similar

*Created by Hyunjin*

*March 6, 2019*

**You only need to see 'similar.ml' file which is what I made.

### Reading the file list

Your program should read the list of names of representative files from a file
whose name is passed in as the first command line argument.  For
instance, if we call your program from the command line as
`findsim replist.txt example.txt` then the file `replist.txt`
should contain a list of representative text files, one on each line.
The file `simUtil.ml` contains definitions for the two I/O functions
you'll need for this assignment; `file_lines : string -> string list`
takes as input a file name and returns a list of lines in the file.

Modify the first line of `main` -- `let repfile_list = [""]` -- to bind `repfile_list` to the list of file names stored in the file named by the argument `replist_name`.


### Reading the representative files, and the document

The other I/O function defined in `simUtil.ml` is `file_as_string :
string -> string`: given a file name, it returns the entire
contents of the file as a string.  Still working in the `main` function at the bottom of `similar.ml`, modify the next two lines so that using `file_as_string` and an appropriate list function, `target_contents` is bound to the contents of the target file (passed as a name in `target_name`), and `rep_contents` is bound to a list of strings, containing the string contents of each representative file.

### Splitting into n-grams

Our distance mechanism treats text documents as *bags* of *n-grams*.  We'll describe bags, also called multisets, below.  *n-grams* are sequences of n consecutive letters from a string, so for example, in the string "Bazinga", the 3-grams are "Baz", "azi", "zin", "ing", and "nga".  (We'll use n=4, which we've declared at the top of `similar.ml`, for this assignment) We'll build a function to extract "normalized" n-grams from a string in three steps:

1. First, fill in the definition for the "naive" n-gram function `ngrams : int -> string -> string list`.  The `List.init` function (which takes as input an integer `n` and a function `f : int -> 'a` and produces the list `[(f 0); (f 1); ... (f (n-1)]`) and `String.sub` will be useful here. Some example evaluations: `ngrams 2 "hallo!"` should evaluate to `["ha"; "al"; "ll"; "lo"; "o!"]` and `ngrams 3 "shirtballs"` should evaluate to `["shi"; "hir"; "irt"; "rtb"; "tba"; "bal"; "all"; "lls"]`.

    > Note: `List.init` is not in the "default" version of ocaml on CSELabs machines.  To change your path to run a sufficiently recent version of utop and ocamlc, open a terminal and type `module initadd soft/ocaml/4.06.0` at the prompt.  If you then run `utop` you should see the message `Welcome to utop version 2.1.0 (using OCaml version 4.06.0)!`.

2.  Second, Punctuation, capitalization, stray digits and other non-alphabetic characters are not as important for the similarity of documents, so we should remove them from our strings. We can handle this by "preprocessing" the string using `String.lowercase_ascii` and `String.map` to turn any non-alphabetic character into a space, `' '`.  Fill in the function `filter_chars` to accomplish this goal.  Some example evaluations: `filter_chars "abc123"` should evaluate to `"abc   "` and `filter_chars "SAD!!!!!!!"` should evaluate to `"sad       "`.

3. Finally, the `string list` returned by `ngrams` will include some strings that
   are only or primarily made up of space characters.  We can remove these from the
   result of `ngrams` using a `List` higher-order function; `String.contains s c` will tell us if string `s` contains character `c`.  

Define a function, `n_grams : string -> string list` that combines the
preprocessing in step 2 with a call to `ngrams ngram_n` and the
postprocessing (removing whitespace strings) in step 3 into a single
function. Some examples: `n_grams "I continued to use almond milk in my coffee"` should
evaluate to `["cont"; "onti"; "ntin"; "tinu"; "inue"; "nued"; "almo"; "lmon"; "mond";
 "milk"; "coff"; "offe"; "ffee"]` and `n_grams "DRESS BENCH!"` should evaluate to `["dres"; "ress"; "benc"; "ench"]`.  Remember, use `let`
and `List` and `String` functions only, no explicit recursion!

Once you've got `n_grams` working, modify the next two let bindings in main so that:

+ `rep_ngrams` is bound to a list of lists of n-grams, one list for each representative text file
+ `target_ngrams` is bound to a list of the n-grams in the target text file

### Converting to bags

We'll represent each document as a *bag of n-grams*.  A *bag* is an unordered mathematical object like a set, except that all elements have a non-negative *multiplicity* associated with them: an element that is not in the bag has multiplicity 0, an element that appears once has multiplicity 1, and so on.  We'll represent a bag as an associative list pairing each n-gram in the bag with its multiplicity.  Add a definition  (using `let`, not `let rec`) for the function `bag_of_list : 'a list -> ('a*int) list` using an appropriate `List` higher-order function (you may find it useful to separately define the argument to your higher-order function, and to sort the list before processing it.) Some examples: `bag_of_list ["a"; "b"; "a" ; "b"]` should evaluate to (a permutation of) `[("b",2); ("a",2)]` and `bag_of_list ["a"; "a"; "b"; "c"; "b"; "a"]` should evaluate to (a permutation of) `[("c",1); ("b",2); ("a", 3)]`.

Modify the next two let bindings to convert the list of lists of n-grams (`rep_ngrams`) into a list of bags of n-grams (`rep_bags`) from the representative documents, and convert the list of n-grams from the target document (`target_ngrams`) into a bag of n-grams (`target_bag`).

### Define the similarity function

We define the similarity between two documents to be the ratio of the size of the intersection of their n-gram bags to the size of the union of their n-gram bags.  The intersection of two bags is the bag in which each element has multiplicity the minimum of its multiplicities in the two bags, and the union is the bag in which each element has multiplicity the maximum of its multiplicities in the two bags. The size of a bag is the sum of the multiplicities of all of the elements in the bag.  Add function definitions that use `List` functions to compute `intersection_size : ('a * int) list -> ('a * int) list -> int`, the intersection size of two bags represented by associative lists (you may find it useful to define a helper function `multiplicity : ('a * int) list -> int`);
`union_size : ('a * int) list -> ('a * int) list -> int`, the size of the union of two bags represented by associative lists; and `similarity : ('a * int) list -> ('a * int) list -> float`.  (Don't forget to convert to floats before the division!)
Some examples: `intersection_size [("a",2); ("b",1)] [("a",1); ("c",1)]` should evaluate to
`1`, `union_size [("a",2); ("b",1)] [("a",1); ("c",1)]` should evaluate to `4` and
`similarity [("a",2); ("b",1)] [("a",1); ("c",1)]` should evaluate to `0.25`.

Modify the next let binding to compute `repsims`, the list of similarities between each representative document and the target file.

### Compute the closest document

Now that we have stem sets for all of the representative files and the target
file, and the similarities of each representative file to the target file, we
can compute which representative file is most simliar to the target text file,
and its similarity to the target file.  Fill in the definition of the function
`find_max : float list -> string list -> float*string` which finds the name and
similarity of the file closest to the target document.  If two or more representative
files have the same similarity, your function should return the file name that is
lexicographically greatest, and if the input lists are empty, it should return `(0.,"")`.
A few hints:

+ The list function `List.combine` is the same as the `zip` function
we have seen in class before

+ The built-in function `max` on tuples orders its arguments by the first element of the tuples, then the second, and so on.

An example evaluation: `find_max [0.;0.2;0.1] ["a";"b";"c"]` should evaluate to `(0.2,"b")`.  Once you've defined `find_max`, modify the next `let` binding in `main`
so that `best_rep` is the name of the most similar representative file and `sim` is its
similarity to the target file.

### Print out the result(s)

Finally, now that you have the result, modify `main` so that:

- if the "all" parameter is true, we print out a header line in the format `"File\tSimilarity"`, and then the similarity and file name of each representative
file to the target file are printed, in the order they appear in the repfile_list,
one per line, in the format `"<repfile name>\t<score>"`.  You may find the function `List.iter2` helpful for this case.

- Otherwise, print out two lines telling us the best result.  On the first line,
you should print `"The most similar file to <target file name> was <representative file name>"`, and on the second line, print `"Similarity: <score>"`.

Testing it out: compiling the entire application requires a specific sequence of
arguments to `ocamlc`, because the OCaml compiler does not resolve
"dependencies" automatically - it can't figure out which source files reference other
source files or libraries, requiring those to be built or linked first.  So we'll need
to list them in the right order.  Here's what we know:

+ The source file `findsim.ml` is the command-line driver that calls `main` in
`similar.ml` with the command-line arguments.  So it needs to be compiled after
`similar.ml`

+ `similar.ml` should call functions in `simUtil.ml`, so it needs
to be compiled after that file;

+ `simUtil.ml` does not call any other module.  So the first thing we need to tell `ocamlc` to include is `simUtil.ml`.

Putting these all together, we can compile our application with the command:

```
% ocamlopt -o findsim simUtil.ml similar.ml findsim.ml
```

Once we've built the executable file, we can test it out.  The directory
`authors` contains a set of 9 text files taken from Project Gutenberg, and the directory `targets` contains text files with the beginnings of 9 other novels by the same authors.  The file `authorlist` simply lists the 10 labelled author files. If we run `findsim` with this representative list against
various target files, we should see the following output:

```
(repo-user1234/hw3/ ) % ./findsim authorlist targets/alices-adventures-in-wonderland.txt
File	Similarity
./authors/austen.txt	0.300095780612
./authors/carroll.txt	0.531395512911
./authors/christie.txt	0.361078512752
./authors/conrad.txt	0.363124793115
./authors/dickens.txt	0.344264066341
./authors/doyle.txt	0.331630308437
./authors/dubois.txt	0.348046676814
./authors/shelley.txt	0.275700934579
./authors/stoker.txt	0.343395363462
(repo-user1234/hw3/ ) % ./findsim authorlist targets/heart-of-darkness.txt
File	Similarity
./authors/austen.txt	0.372157515252
./authors/carroll.txt	0.37344643914
./authors/christie.txt	0.408208378832
./authors/conrad.txt	0.525968052187
./authors/dickens.txt	0.444893248702
./authors/doyle.txt	0.423731024049
./authors/dubois.txt	0.42080359291
./authors/shelley.txt	0.398048378895
./authors/stoker.txt	0.428009935311
(repo-user1234/hw3/ ) % ./findsim authorlist targets/dracula.txt
File	Similarity
./authors/austen.txt	0.354479825949
./authors/carroll.txt	0.370513008967
./authors/christie.txt	0.39055394225
./authors/conrad.txt	0.433061002179
./authors/dickens.txt	0.42309862182
./authors/doyle.txt	0.404889412521
./authors/dubois.txt	0.394126485453
./authors/shelley.txt	0.371553977413
./authors/stoker.txt	0.443872415082
```
(Note: implementing intersection_size and union_size using only List higher order functions is somewhat inefficient, and due to the large size of these files, running these comparisons may take 50-100 seconds to complete, depending on the hardware you're using.)
