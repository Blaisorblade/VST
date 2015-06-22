Require Recdef.
Require Import Coqlib.
Require Import Integers.
Require Import Coq.Strings.String.
Require Import Coq.Strings.Ascii.
Require Import Integers.
Require Import List.
Require Import msl.Coqlib2.

Lemma power_nat_one_divede_other: forall n m : nat,
  (two_power_nat n | two_power_nat m) \/ (two_power_nat m | two_power_nat n).
Proof.
  intros.
  pose proof Zle_0_nat n.
  pose proof Zle_0_nat m.
  rewrite !two_power_nat_two_p.
  destruct (zle (Z.of_nat n) (Z.of_nat m)).
  + left.
    exists (two_p (Z.of_nat m - Z.of_nat n)).
    rewrite <- two_p_is_exp by omega.
    f_equal.
    omega.
  + right.
    exists (two_p (Z.of_nat n - Z.of_nat m)).
    rewrite <- two_p_is_exp by omega.
    f_equal.
    omega.
Qed.

Lemma multiple_divide_mod: forall a b c, b > 0 -> ((a | b) \/ (b | a)) -> (a | (c * a mod b)).
Proof.
  intros.
  destruct H0.
  + apply Z.divide_add_cancel_r with (b * (c * a / b))%Z.
    apply Z.divide_mul_l; auto.
    rewrite <- Z_div_mod_eq; auto.
    apply Z.divide_mul_r, Z.divide_refl.
  + destruct H0.
    subst.
    rewrite Z.mul_assoc, Z_mod_mult.
    apply Z.divide_0_r.
Qed.

Lemma divide_align: forall x y: Z, x > 0 -> Zdivide x y -> align y x = y.
Proof.
  intros.
  unfold align.
  destruct H0.
  rewrite H0.
  pose proof Zdiv_unique (x0 * x + x - 1) x x0 (x - 1).
  assert (x0 * x + x - 1 = x0 * x + (x - 1)) by omega.
  assert (0 <= x - 1 < x) by omega.
  rewrite (H1 H2 H3).
  reflexivity.
Qed.

Lemma Z2Nat_neg: forall i, i < 0 -> Z.to_nat i = 0%nat.
Proof.
  intros.
  destruct i; try reflexivity.
  pose proof Zgt_pos_0 p; omega.
Qed.

Lemma Int_unsigned_repr_le: forall a, 0 <= a -> Int.unsigned (Int.repr a) <= a.
Proof.
  intros.
  rewrite Int.unsigned_repr_eq.
  apply Z.mod_le; auto.
  cbv.
  auto.
Qed.

Lemma arith_aux00: forall a b, b <= a -> 0%nat = nat_of_Z (a - b) -> a - b = 0.
Proof.
  intros.
  pose proof Z2Nat.id (a - b).
  unfold nat_of_Z in H0.
  rewrite <- H0 in H1.
  simpl Z.of_nat in H1.
  omega.
Qed.

Lemma arith_aux01: forall a b n, S n = nat_of_Z (a - b) -> b < a.
Proof.
  intros.
  destruct (zlt a b); auto.
  + rewrite Z2Nat_neg in H by omega.
    inversion H.
  + pose proof Z2Nat.id (a - b).
    unfold nat_of_Z in H; rewrite <- H in H0.
    spec H0; [omega |].
    rewrite Nat2Z.inj_succ in H0.
    omega.
Qed.

Lemma arith_aux02: forall n a b, S n = nat_of_Z (a - b) -> n = nat_of_Z (a - Z.succ b).
Proof.
  intros.
  pose proof arith_aux01 _ _ _ H.
  unfold nat_of_Z in *.
  pose proof Z2Nat.id (a - b).
  spec H1; [omega |].
  rewrite <- H in H1.
  replace (a - Z.succ b) with (a - b - 1) by omega.
  rewrite <- H1.
  rewrite Nat2Z.inj_succ.
  replace (Z.succ (Z.of_nat n) - 1) with (Z.of_nat n) by omega.
  rewrite Nat2Z.id.
  auto.
Qed.

Lemma arith_aux03: forall a b c,
  0 <= b ->
  0 <= a + b * c ->
  0 <= a + b * Z.succ c.
Proof.
  intros.
  assert (b * c <= b * Z.succ c) by (apply Zmult_le_compat_l; omega).
  omega.
Qed.

Lemma arith_aux04: forall a b c,
  0 <= b <= c ->
  (a | b) ->
  (a | b mod c).
Proof.
  intros.
  destruct (zlt b c).
  + rewrite Zmod_small by omega.
    auto.
  + assert (b = c) by omega.
    subst.
    rewrite Z_mod_same_full.
    apply Z.divide_0_r.
Qed.

Lemma arith_aux05: forall lo hi, 0 <= lo -> 0 <= hi ->
  0 <= Z.max 0 (hi - lo) <= hi.
Proof.
  intros.
  destruct (zle lo hi).
  + rewrite Z.max_r by omega.
    omega.
  + rewrite Z.max_l by omega.
    omega.
Qed.

Lemma arith_aux06: forall lo hi n, 0 <= lo <= n -> 0 <= hi <= n -> 0 <= lo + Z.max 0 (hi - lo) <= n.
Proof.
  intros.
  destruct (zle lo hi).
  + rewrite Z.max_r by omega.
    omega.
  + rewrite Z.max_l by omega.
    omega.
Qed.

Ltac inv_int i :=
  let ofs := fresh "ofs" in
  let H := fresh "H" in
  let H0 := fresh "H" in
  let H1 := fresh "H" in
  pose proof Int.repr_unsigned i as H;
  pose proof Int.unsigned_range i as H0;
  remember (Int.unsigned i) as ofs eqn:H1;
  rewrite <- H in *;
  clear H H1; try clear i.

(**************************************************

Solve_mod_modulus

**************************************************)

Definition modm x := x mod Int.modulus.

Lemma modm_mod_eq: forall x y, Int.eqmod Int.modulus x y -> x mod Int.modulus = modm y.
Proof.
  intros.
  apply Int.eqmod_mod_eq; auto.
  apply Int.modulus_pos.
Qed.

Lemma modm_mod_elim: forall x y, Int.eqmod Int.modulus x y -> Int.eqmod Int.modulus (x mod Int.modulus) y.
Proof.
  intros.
  eapply Int.eqmod_trans; eauto.
  apply Int.eqmod_sym, Int.eqmod_mod.
  apply Int.modulus_pos.
Qed.

Definition reprm := Int.repr.

Lemma modm_repr_eq: forall x y, Int.eqmod Int.modulus x y -> Int.repr x = reprm y.
Proof.
  intros.
  apply Int.eqm_samerepr; auto.
Qed.

Ltac simpl_mod A H :=
  let H0 := fresh "H" in
  let H1 := fresh "H" in
  match A with
  | (?B + ?C)%Z =>
    simpl_mod B H0; simpl_mod C H1;
    pose proof Int.eqmod_add Int.modulus _ _ _ _ H0 H1 as H;
    clear H1 H0
  | (?B - ?C)%Z =>
    simpl_mod B H0; simpl_mod C H1;
    pose proof Int.eqmod_sub Int.modulus _ _ _ _ H0 H1 as H;
    clear H1 H0
  | (?B * ?C)%Z =>
    simpl_mod B H0; simpl_mod C H1;
    pose proof Int.eqmod_mult Int.modulus _ _ _ _ H0 H1 as H;
    clear H1 H0
  | (- ?B)%Z =>
    simpl_mod B H0;
    pose proof Int.eqmod_neg Int.modulus _ _ H0 as H;
    clear H0
  | ?B mod Int.modulus =>
    simpl_mod B H0;
    pose proof modm_mod_elim B _ H0 as H;
    clear H0
  | modm ?B =>
    simpl_mod B H0;
    pose proof modm_mod_elim B _ H0 as H;
    clear H0
  | _ =>
    pose proof Int.eqmod_refl Int.modulus A as H
  end.

Ltac solve_mod_modulus :=
  try unfold Int.add; try rewrite !Int.unsigned_repr_eq;
  repeat
  match goal with
  | |- context [?A mod Int.modulus] =>
         let H := fresh "H" in simpl_mod A H;
         rewrite (modm_mod_eq A _ H);
         clear H
  | |- context [Int.repr ?A] =>
         let H := fresh "H" in simpl_mod A H;
         rewrite (modm_repr_eq A _ H);
         clear H
  end;
  try unfold modm in *;
  try unfold reprm in *.

(**************************************************

List lemmas

**************************************************)

Lemma firstn_app:
 forall {A} n m (al: list A), firstn n al ++ firstn m (skipn n al) =
  firstn (n+m) al.
Proof. induction n; destruct al; intros; simpl; auto.
destruct m; reflexivity.
f_equal; auto.
Qed.

Lemma nth_skipn:
  forall {A} i n data (d:A),
       nth i (skipn n data) d = nth (i+n) data d.
Proof.
intros.
revert i data; induction n; simpl; intros.
f_equal; omega.
destruct data; auto.
destruct i; simpl; auto.
rewrite IHn.
replace (i + S n)%nat with (S (i + n))%nat by omega; auto.
Qed.

Lemma skipn_skipn: forall {A} n m (xs: list A),
  skipn n (skipn m xs) = skipn (m + n) xs.
Proof.
  intros.
  revert xs; induction m; intros.
  + reflexivity.
  + simpl.
    destruct xs.
    - destruct n; reflexivity.
    - apply IHm.
Qed.

Lemma firstn_exact_length: forall {A} (xs: list A), firstn (length xs) xs = xs.
Proof.
  intros.
  induction xs.
  + reflexivity.
  + simpl.
    rewrite IHxs.
    reflexivity.
Qed.

Lemma skipn_exact_length: forall {A} (xs: list A), skipn (length xs) xs = nil.
Proof.
  intros.
  induction xs.
  + reflexivity.
  + simpl.
    rewrite IHxs.
    reflexivity.
Qed.

Lemma len_le_1_rev: forall {A} (contents: list A),
  (length contents <= 1)%nat ->
  contents = rev contents.
Proof.
  intros.
  destruct contents.
  + reflexivity.
  + destruct contents.
    - reflexivity.
    - simpl in H. omega.
Qed.

Lemma firstn_firstn: forall {A} (contents: list A) n m,
  (n <= m)%nat ->
  firstn n (firstn m contents) = firstn n contents.
Proof.
  intros.
  revert n m H;
  induction contents;
  intros.
  + destruct n, m; reflexivity.
  + destruct n, m; try solve [omega].
    - simpl; reflexivity.
    - simpl; reflexivity.
    - simpl.
      rewrite IHcontents by omega.
      reflexivity.
Qed.

Lemma firstn_1_skipn: forall {A} n (ct: list A) d,
  (n < length ct)%nat ->
  nth n ct d :: nil = firstn 1 (skipn n ct).
Proof.
  intros.
  revert ct H; induction n; intros; destruct ct.
  + simpl in H; omega.
  + simpl. reflexivity.
  + simpl in H; omega.
  + simpl in H |- *.
    rewrite IHn by omega.
    reflexivity.
Qed.

Lemma skipn_length: forall {A} (contents: list A) n,
  length (skipn n contents) = (length contents - n)%nat.
Proof.
  intros.
  revert n;
  induction contents;
  intros.
  + destruct n; reflexivity.
  + destruct n; simpl.
    - reflexivity.
    - apply IHcontents.
Qed.

Lemma nth_firstn: forall {A} (contents: list A) n m d,
  (n < m)%nat ->
  nth n (firstn m contents) d = nth n contents d.
Proof.
  intros.
  revert n m H;
  induction contents;
  intros.
  + destruct n, m; reflexivity.
  + destruct n, m; try omega.
    - simpl. reflexivity.
    - simpl. apply IHcontents. omega.
Qed.

Lemma in_nth_error: forall {A} (x: A) xs, In x xs -> exists n, nth_error xs n = Some x.
Proof.
  intros.
  induction xs.
  + inversion H.
  + destruct H.
    - subst; exists 0%nat.
      reflexivity.
    - destruct (IHxs H) as [?n ?H].
      exists (S n).
      simpl.
      tauto.
Qed.

Lemma Zlength_length:
  forall A (al: list A) (n: Z),
    0 <= n ->
    (Zlength al = n <-> length al = Z.to_nat n).
Proof.
intros. rewrite Zlength_correct.
split; intro.
rewrite <- (Z2Nat.id n) in H0 by omega.
apply Nat2Z.inj in H0; auto.
rewrite H0.
apply Z2Nat.inj; try omega.
rewrite Nat2Z.id; auto.
Qed.

Lemma Zlength_app: forall T (al bl: list T),
    Zlength (al++bl) = Zlength al + Zlength bl.
Proof. induction al; intros. simpl app; rewrite Zlength_nil; omega.
 simpl app; repeat rewrite Zlength_cons; rewrite IHal; omega.
Qed.

Lemma Zlength_rev: forall T (vl: list T), Zlength (rev vl) = Zlength vl.
Proof. induction vl; simpl; auto. rewrite Zlength_cons. rewrite <- IHvl.
rewrite Zlength_app. rewrite Zlength_cons. rewrite Zlength_nil; omega.
Qed.

Lemma Zlength_map: forall A B (f: A -> B) l, Zlength (map f l) = Zlength l.
Proof. induction l; simpl; auto. repeat rewrite Zlength_cons. f_equal; auto.
Qed.

Lemma ZtoNat_Zlength: 
 forall {A} (l: list A), Z.to_nat (Zlength l) = length l.
Proof.
intros. rewrite Zlength_correct. apply Nat2Z.id.
Qed.
Hint Rewrite @ZtoNat_Zlength : norm.

Lemma Zlength_nonneg:
 forall {A} (l: list A), 0 <= Zlength l.
Proof.
intros. rewrite Zlength_correct. omega.
Qed.

Lemma skipn_length_short:
  forall {A} n (al: list A), 
    (length al <= n)%nat -> 
    (length (skipn n al) = 0)%nat.
Proof.
 induction n; destruct al; simpl; intros; auto.
 omega.
 apply IHn. omega.
Qed.

Lemma skipn_short:
   forall {A} n (al: list A), (n >= length al)%nat -> skipn n al = nil.
Proof.
intros.
pose proof (skipn_length_short n al).
spec H0; [auto | ].
destruct (skipn n al); inv H0; auto.
Qed.

Lemma nth_map':
  forall {A B} (f: A -> B) d d' i al,
  (i < length al)%nat ->
   nth i (map f al) d = f (nth i al d').
Proof.
induction i; destruct al; simpl; intros; try omega; auto.
apply IHi; omega.
Qed.

Definition Znth {X} n (xs: list X) (default: X) :=
  if (zlt n 0) then default else nth (Z.to_nat n) xs default.

Lemma Znth_map:
  forall A B i (f: A -> B) (al: list A) (d': A) (b: B),
  0 <= i < Zlength al ->
  @Znth B i (map f al) b = f (Znth i al d').
Proof.
unfold Znth.
intros.
rewrite if_false by omega.
rewrite if_false by omega.
rewrite nth_map' with (d'0 := d'); auto.
apply Nat2Z.inj_lt. rewrite Z2Nat.id by omega.
rewrite <- Zlength_correct; omega.
Qed.

Lemma Znth_succ: forall {A} i lo (v: list A), Z.succ lo <= i -> Znth (i - lo) v = Znth (i - (Z.succ lo)) (skipn 1 v).
Proof.
  intros.
  extensionality default.
  unfold Znth.
  if_tac; [omega |].
  if_tac; [omega |].
  rewrite nth_skipn.
  f_equal.
  change 1%nat with (Z.to_nat 1).
  rewrite <- Z2Nat.inj_add by omega.
  f_equal.
  omega.
Qed.

Lemma Znth_skipn: forall {A} n xs (default: A),
  0 <= n ->
  Znth 0 (skipn (nat_of_Z n) xs) default = Znth n xs default.
Proof.
  intros.
  unfold Znth.
  if_tac; [omega |].
  if_tac; [omega |].
  rewrite nth_skipn.
  reflexivity.
Qed.

Lemma split3_full_length_list: forall {A} lo mid hi (ct: list A) d,
  lo <= mid < hi ->
  Zlength ct = hi - lo ->
  ct = firstn (Z.to_nat (mid - lo)) ct ++
       (Znth (mid - lo) ct d :: nil) ++
       skipn (Z.to_nat (mid - lo + 1)) ct.
Proof.
  intros.
  rewrite <- firstn_skipn with (l := ct) (n := Z.to_nat (mid - lo)) at 1.
  f_equal.
  rewrite Z2Nat.inj_add by omega.
  rewrite <- skipn_skipn.
  replace (Znth (mid - lo) ct d :: nil) with (firstn (Z.to_nat 1) (skipn (Z.to_nat (mid - lo)) ct)).
  + rewrite firstn_skipn; reflexivity.
  + unfold Znth.
    if_tac; [omega |].
    rewrite firstn_1_skipn; [reflexivity |].
    rewrite <- (Nat2Z.id (length ct)).
    apply Z2Nat.inj_lt.
    - omega.
    - omega.
    - rewrite Zlength_correct in H0.
      omega.
Qed.

Lemma fold_right_andb: forall bl b, fold_right andb b bl = true -> forall b0, In b0 bl -> b0 = true.
Proof.
  intros.
  induction bl.
  + inversion H0.
  + destruct H0.
    - simpl in H.
      rewrite andb_true_iff in H.
      subst; tauto.
    - simpl in H.
      rewrite andb_true_iff in H.
      tauto.
Qed.

(**************************************************

Int type lemmas

**************************************************)

Lemma add_repr: forall i j, Int.add (Int.repr i) (Int.repr j) = Int.repr (i+j).
Proof. intros.
  rewrite Int.add_unsigned.
 apply Int.eqm_samerepr.
 unfold Int.eqm.
 apply Int.eqm_add; apply Int.eqm_sym; apply Int.eqm_unsigned_repr.
Qed.

Lemma mul_repr:
 forall x y, Int.mul (Int.repr x) (Int.repr y) = Int.repr (x * y).
Proof.
intros. unfold Int.mul.
apply Int.eqm_samerepr.
repeat rewrite Int.unsigned_repr_eq.
apply Int.eqm_mult; unfold Int.eqm; apply Int.eqmod_sym;
apply Int.eqmod_mod; compute; congruence.
Qed.

Lemma sub_repr: forall i j,
  Int.sub (Int.repr i) (Int.repr j) = Int.repr (i-j).
Proof.
  intros.
 unfold Int.sub.
 apply Int.eqm_samerepr.
 unfold Int.eqm.
 apply Int.eqm_sub; apply Int.eqm_sym; apply Int.eqm_unsigned_repr.
Qed.

Lemma Zland_two_p:
 forall i n, (0 <= n)%Z -> Z.land i (Z.ones n) = i mod (2 ^ n).
Proof.
intros.
rewrite Z.land_ones by auto.
reflexivity.
Qed.

Lemma and_repr
     : forall i j : Z, Int.and (Int.repr i) (Int.repr j) = Int.repr (Z.land i j).
Proof.
  intros.
  unfold Int.and.
  rewrite <- (Int.repr_unsigned (Int.repr (Z.land i j))).
  rewrite !Int.unsigned_repr_eq.
  change Int.modulus with (2 ^ 32).
  rewrite <- !Zland_two_p by omega.
  f_equal.
  rewrite <- !Z.land_assoc.
  f_equal.
  rewrite (Z.land_comm (Z.ones 32)).
  rewrite <- !Z.land_assoc.
  f_equal.
Qed.

Lemma or_repr
     : forall i j : Z, Int.or (Int.repr i) (Int.repr j) = Int.repr (Z.lor i j).
Proof.
  intros.
  unfold Int.or.
  rewrite <- (Int.repr_unsigned (Int.repr (Z.lor i j))).
  rewrite !Int.unsigned_repr_eq.
  change Int.modulus with (2 ^ 32).
  rewrite <- !Zland_two_p by omega.
  f_equal.
  rewrite <- Z.land_lor_distr_l.
  reflexivity.
Qed.

Arguments Int.unsigned n : simpl never.
Arguments Pos.to_nat !x / .

Lemma align_0: forall z, 
    z > 0 -> align 0 z = 0.
Proof. unfold align; intros. rewrite Zdiv_small; omega.
Qed.
Hint Rewrite align_0 using omega : norm.

Lemma align_1: forall n, align n 1 = n.
Proof.  intros; unfold align. rewrite Z.div_1_r. rewrite Z.mul_1_r. omega.
Qed.
Hint Rewrite align_1 using omega : norm.
