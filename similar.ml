open SimUtil

let ngram_n = 4

(* Define the function that lower-cases and filters out non-alphabetic characters *)
let filter_chars s = 
  String.map (fun ch -> if ('a' <= ch && ch <= 'z') then ch   (* check if ch is in range *)
                        else ' ') (String.lowercase_ascii s)  (* make lowercase *)

(* step for filter_chars
1. make lowercase using String.lowercase_ascii
    String.lowercase_ascii : string -> string
      Return a copy of the argument, with all uppercase letters translated 
      to lowercase, using the US-ASCII character set.
2. check if ch is in the range and return the string
    String.map : (char -> char) -> string -> string
      String.map f s applies function f in turn to all the characters of s 
      (in increasing index order) and stores the results in a new string that 
      is returned.
3. Expected output
    filter_chars "abc123" 
      -> "abc   " 
    filter_chars "SAD!!!!!!!" 
      -> "sad       " 
*)

(* extract a list of n-grams from a string, naively *)
let ngrams n s = 
  let ngr = (String.length s) - (n - 1) in      (* get ngrams using a formula *)
     List.init ngr (fun x -> String.sub s x n)

(* step for ngrams
1. Get a formula for ngrams
    Ngram = x - (n - 1)
      x   = number of words in a given sentence
2. List.init len f is f 0; f 1; ...; f (len-1), evaluated left to right.
      utop # List.init;;
      - : int -> (int -> 'a) -> 'a list = <fun>
3. String.sub s start len returns a fresh string of length len, containing 
   the substring of s that starts at position start and has length len.
      utop # String.sub;;
      - : string -> int -> int -> string = <fun>
4. Expected output
    ngrams 2 "hallo!" 
      -> ["ha"; "al"; "ll"; "lo"; "o!"]
    ngrams 3 "shirtballs" 
      -> ["shi"; "hir"; "irt"; "rtb"; "tba"; "bal"; "all"; "lls"]
*)

(* Define the function that converts a string into a list of "normalized" n-grams *)
let n_grams s = 
  let ans = ngrams ngram_n (filter_chars s) in              (* call ngrams and filter_chars to get answer *)
    List.filter (fun x -> not (String.contains x ' ')) ans  (* use filter to sort if there is space *)

(* step for n_grams
1. String.contains : string -> char -> bool
    String.contains s c tests if character c appears in the string s. 
2. Expected output
    n_grams "DRESS BENCH!" 
      -> ["dres"; "ress"; "benc"; "ench"]
    n_grams "I continued to use almond milk in my coffee" 
      -> ["cont"; "onti"; "ntin"; "tinu"; "inue"; "nued"; "almo"; 
          "lmon"; "mond"; "milk"; "coff"; "offe"; "ffee"]
*)

(* Define a function to convert a list into a bag *)
let bag_of_list lst =       (* bag_of_list : 'a list -> ('a*int) list *)
  let sortList = List.sort compare lst in                   (* sort the list *)
    List.fold_left (fun acc e -> match acc with
                    | [] -> [(e, 1)]                        (* if acc is [] then retrun the element *)
                    | ((e', num) :: t) ->                   
                      if e = e' then ((e', num+1) :: t)     (* if you find same element in acc, then increment num *)
                      else ((e, 1) :: acc)) [] sortList ;;  (* if you find new element, then return the element and num with 1 *)

(* step for bag_of_list
1. sort the list using List.sort before processing it
2. Expected output
    bag_of_list ["a"; "b"; "a" ; "b"]
      -> [("b",2); ("a",2)]
    bag_of_list ["a"; "a"; "b"; "c"; "b"; "a"]
      -> [("c",1); ("b",2); ("a", 3)]
*)

(* Bag utility functions *)

(* multiplicity of e in bag b - 0 if not in the bag *)
let multiplicity e b =    (* multiplicity : ('a * int) list -> int  *)
  List.fold_left (fun acc (k, v) -> if k = e then v else acc) 0 b

(* step for multiplicity
1. return max of its multiplicities in b
2. Expected output
    multiplicity "a" [("a",1); ("c",1)]
      -> 1
    multiplicity "b" [("a",1); ("b",2); ("a",1)];;
      -> 2
    multiplicity "b" [("a",1); ("b",2); ("b",3)];;
      -> 3
*)

(* size of a bag is the sum of the multiplicities of its elements *)
let size b =      (* size : ('a * int) list -> int *)
  List.fold_left (fun acc (k, v) -> v + acc) 0 b    (* return acc which is sum of v *)

(* step for size
1. return acc which is sum of v
2. Expected output
    size [("c",1); ("b",2); ("a", 3)];;
      -> 6
    size [("b",2); ("a",2)];;
      -> 4
*)

(* Define the similarity function between two sets: size of intersection / size of union *)
(* intersection_size : ('a * int) list -> ('a * int) list -> int *)
let intersection_size s1 s2 = 
  List.fold_left (fun acc (k, v) -> let mult = multiplicity k s2 in     (* check if k is in s2 *)
                                      let mini = min v mult in          (* get min between v and mult *)
                                        if mult > 0 then acc + mini     (* add mini to acc *)
                                            else acc) 0 s1  
(* step for intersection_size
1. check if k is in s2
2. get min between v and mult
3. if mult greater than 0, then add mini to acc
3. Expected output
    intersection_size [("a",2); ("b",1)] [("a",1); ("c",1)] 
    -> 1
*)

let union_size s1 s2 =                                (* union_size : ('a * int) list -> ('a * int) list -> int *)
  size s1 + size s2  - (intersection_size s1 s2)      (* count s1, s2 and intersection size both and calculate*)
  
(* step for union_size
1. count size for s1 using size function
2. count size for s2 using size function
3. add two size and subtract the intersection size
4. Expected output
    union_size [("a",2); ("b",1)] [("a",1); ("c",1)]
      -> 4 *)

let similarity s1 s2 =    (* similarity : ('a * int) list -> ('a * int) list -> float *)
  let interSize = float_of_int (intersection_size s1 s2) in   (* convert to float the intersection_size *)
    let unionSize = float_of_int (union_size s1 s2) in        (* convert to float the union_size *)
      interSize /. unionSize                                  (* return result *)

(* step for similarity
1. convert to floats before the division
2. divide two size
3. Expected output
    similarity [("a",2); ("b",1)] [("a",1); ("c",1)]
      -> 0.25
*)

(* Find the most similar representative file *)
let find_max repsims repnames =
  let combineList = List.combine repsims repnames in    (* combine two list *)
    match combineList with
    | [] -> failwith "fail"
    | (fl',str') :: t ->  (* go through every element in the combineList to check which one is max *)
      List.fold_left (fun acc (fl, str) -> max acc (fl, str)) (fl', str') combineList

(* step for find_max
1. use List.combine to combine two list
    List.combine : 'a list -> 'b list -> ('a * 'b) list
      Transform a pair of lists into a list of pairs: combine [a1; ...; an] 
      [b1; ...; bn] is [(a1,b1); ...; (an,bn)]. Raise Invalid_argument if the 
      two lists have different lengths. Not tail-recursive.
2. use max to get maximum value
    max : 'a -> 'a -> 'a
      Return the greater of the two arguments. The result is unspecified 
      if one of the arguments contains the float value nan.
3. Expected output
    find_max [0.;0.2;0.1] ["a";"b";"c"]
      -> (0.2,"b")
*)

let main all replist_name target_name =
  (* Read the list of representative text files *)
  let repfile_list = file_lines replist_name in
  (* Get the contents of the repfiles and the target file as strings *)
  let rep_contents = List.map file_as_string repfile_list in
  let target_contents = file_as_string target_name in
  (* Compute the list of normalized n-grams from each representative *)
  let rep_ngrams = List.map n_grams rep_contents in
  (* Convert the target text file into a list of normalized n-grams *)
  let target_ngrams = n_grams target_contents in
  (* Convert all of the stem lists into stem sets *)
  let rep_bags = List.map bag_of_list rep_ngrams in
  let target_bag = bag_of_list target_ngrams in
  (* Compute the similarities of each rep set with the target set *)
  let repsims = List.map (fun x -> similarity x target_bag) rep_bags in
  let (sim,best_rep) = find_max repsims repfile_list in
  let () = 
    if all then
      let () = (* print out similarities to all representative files *)
        Printf.printf "File\t\t\tSimilarity\n"; 
        List.iter2 (fun s f -> Printf.printf "%s\t%f\n" s f)repfile_list repsims in () 
    else 
      begin
        let () = (* Print out the winner and similarity *)
          Printf.printf "The most similar file to %s was %s\n" target_name best_rep in
          Printf.printf "Similarity: %f\n" sim 
      end in
  (* this last line just makes sure the output prints before the program exits *)
  flush stdout
