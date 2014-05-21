Require Import floyd.proofauto.
Require Import progs.revarray.

Local Open Scope logic.

Definition flip {T} (n: Z) (f: Z -> T) (i: Z) := f (n-1-i).

Lemma flip_flip:  forall {T} n (f: Z -> T), flip n (flip n f) = f.
Proof. intros; extensionality i; unfold flip; f_equal; omega.
Qed.

Definition reverse_spec :=
 DECLARE _reverse
  WITH a0: val, sh : share, contents : Z -> val, size: Z
  PRE [ _a OF (tptr tint), _n OF tint ]
          PROP (0 <= size <= Int.max_signed; writable_share sh;
                    forall i, 0 <= i < size -> is_int (contents i))
          LOCAL (`(eq a0) (eval_id _a);
                      `(eq (Vint (Int.repr size))) (eval_id _n);
                      `isptr (eval_id _a))
          SEP (`(array_at tint sh contents 0 size) (eval_id _a))
  POST [ tvoid ]  `(array_at tint sh (flip size contents) 0 size a0).

Definition main_spec :=
 DECLARE _main
  WITH u : unit
  PRE  [] main_pre prog u
  POST [ tint ] main_post prog u.

Definition Vprog : varspecs := (_four, Tarray tint 4 noattr)::nil.

Definition Gprog : funspecs := 
    reverse_spec :: main_spec::nil.
 
Definition flip_between {T} (n: Z)(lo hi: Z) (f: Z -> T) (i: Z) := 
   f (if zlt i lo then n-1-i
      else if zlt i hi then i
             else n-1-i).

Definition reverse_Inv a0 sh contents size := 
 EX j:Z,
  (PROP  (0 <= j; j <= size-j; isptr a0)
   LOCAL  (`(eq a0) (eval_id _a);
                `(eq (Vint (Int.repr j))) (eval_id _lo);
                `(eq (Vint (Int.repr (size-j)))) (eval_id _hi))
   SEP (`(array_at tint sh (flip_between size j (size-j) contents) 0 size a0))).

Lemma body_reverse: semax_body Vprog Gprog f_reverse reverse_spec.
Proof.
start_function.
name a _a.
name n _n.
name lo' _lo.
name hi' _hi.
name s _s.
name t _t.
forward.  (* lo = 0; *) 
forward.  (* hi = n; *)
rename H1 into POP.
forward_while (reverse_Inv a0 sh contents size)
    (PROP  (isptr a0)
   LOCAL  (`(eq a0) (eval_id _a))
   SEP (`(array_at tint sh (flip size contents) 0 size a0))).
(* Prove that current precondition implies loop invariant *)
unfold reverse_Inv.
apply exp_right with 0.
entailer!; try omega.
f_equal; omega.
apply derives_refl'.
apply equal_f.
apply array_at_ext.
intros.
unfold flip_between.
rewrite if_false by omega.
rewrite if_true by omega.
auto.
(* Prove that loop invariant implies typechecking condition *)
entailer!.
(* Prove that invariant && not loop-cond implies postcondition *)
entailer!.
rename H3 into H5.
rewrite Int.sub_signed in H5.
normalize in H5.
simpl_compare.
apply derives_refl'.
apply equal_f.
apply array_at_ext.
intros. unfold flip_between, flip.
f_equal.
if_tac; auto.
if_tac; auto.
f_equal.
assert (j+j >= size-1) by omega; clear H3.
assert (j+j <= size) by omega; clear H1.
assert (j+j=size \/ j+j=size-1) by omega.
destruct H1; try omega.
(* Prove that loop body preserves invariant *)
forward.  (* t = a[lo]; *)
entailer.
rewrite Int.sub_signed in H3.
normalize in H3.
simpl_compare.
apply prop_right; split; [ | omega].
apply POP.
rewrite if_false by omega.
rewrite if_true by omega. omega.
forward.  (* s = a[hi]; *)
entailer. apply prop_right.
rewrite Int.sub_signed in H4.
normalize in H4.
simpl_compare.
split.
apply POP.
rewrite if_false by omega. rewrite if_true by omega.
omega. omega.
normalize. simpl typeof.
forward. (*  a[hi-1] = t ; *)
entailer; apply prop_right.
rewrite Int.sub_signed in H4, H6.
normalize in H4. normalize in H6.
simpl_compare.
split.
symmetry; apply H5.  omega.
normalize.
forward. (*  a[lo] = s; *) 
entailer. apply prop_right.
rewrite Int.sub_signed in H4, H6.
normalize in H4. normalize in H6.
simpl_compare.
split.
symmetry; apply H4. omega.
normalize.
forward. (* lo++; *)
forward. (* hi--; *)
(* Prove postcondition of loop body implies loop invariant *)
unfold reverse_Inv.
apply exp_right with (Zsucc j).
entailer.
repeat rewrite (Int.signed_repr)  by repable_signed.
 simpl in H6,H8. rewrite Int.sub_signed in H6,H8.
 rewrite (Int.signed_repr 1) in H6,H8 by repable_signed.
 rewrite (Int.signed_repr (size-j)) in H6,H8 by repable_signed.
 rewrite (Int.signed_repr) in H6 by repable_signed.
 simpl_compare.
 apply andp_right.
 apply prop_right.
 normalize. repeat split; try omega.
 f_equal; omega.
 apply derives_refl'.
 apply equal_f.
 apply array_at_ext; intros.
 unfold upd. if_tac. subst.
 normalize.
 unfold flip_between.
 rewrite (Int.signed_repr (size-i)) by repable_signed.
 rewrite (Int.signed_repr 1)  by repable_signed.
 rewrite Int.signed_repr by repable_signed.
 rewrite if_false by omega.
 rewrite if_true by omega.
 rewrite if_true by omega.
 assert (is_int (contents (size-1-i))).
 apply POP; omega.
 replace (size-i-1) with (size-1-i) by omega.
 reflexivity.
 if_tac.
 unfold flip_between. rewrite if_false by omega.
 if_tac; try omega. if_tac; try omega. if_tac; try omega.
 f_equal; omega.
 unfold flip_between.
 repeat (if_tac; try omega); auto.
(* After the loop *)
forward. (* return; *)
Qed.

Definition four_contents := (ZnthV tint
           (map Vint (map Int.repr (1::2::3::4::nil)))).

Lemma body_main:  semax_body Vprog Gprog f_main main_spec.
Proof.
start_function.
eapply (remember_value (eval_var _four (tarray tint 4))); intro a.
forward_call  (*  revarray(four,4); *)
  (a,Ews,four_contents,4).
entailer!.
intros. apply ZnthV_map_Vint_is_int.
rewrite Zlength_correct; simpl; auto.
after_call.
forward_call  (*  revarray(four,4); *)
    (a,Ews, flip 4 four_contents,4).
entailer!.
intros. unfold flip, four_contents.
apply ZnthV_map_Vint_is_int.
 rewrite Zlength_correct; simpl length. change (Z.of_nat 4) with 4. omega.
after_call.
rewrite flip_flip.
 forward. (* return s; *)
 unfold main_post. entailer.
Qed.

Existing Instance NullExtension.Espec.

Lemma all_funcs_correct:
  semax_func Vprog Gprog (prog_funct prog) Gprog.
Proof.
unfold Gprog, prog, prog_funct; simpl.
semax_func_skipn.
semax_func_cons body_reverse.
semax_func_cons body_main.
apply semax_func_nil.
Qed.

