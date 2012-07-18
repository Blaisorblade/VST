Require Import veric.base.
Require Import msl.normalize.
Require Import veric.Address.
Require Import msl.rmaps.
Require Import msl.rmaps_lemmas.
Require Import veric.compcert_rmaps.
Import Mem.
Require Import msl.msl_standard.
Require Import veric.juicy_mem veric.juicy_mem_lemmas veric.juicy_mem_ops.
Require Import veric.res_predicates.
Require Import veric.seplog.
Require Import veric.assert_lemmas.
Require Import veric.Clight_new.
Require Import veric.extspec.
Require Import veric.step_lemmas.
Require Import veric.juicy_extspec.
Require Import veric.expr.
Require Import veric.semax.
Require Import veric.semax_lemmas.
Require Import veric.Clight_lemmas.

Open Local Scope pred.
Open Local Scope nat_scope.

Section extensions.
Context {Z} (Hspec : juicy_ext_spec Z).

Lemma seq_assoc1:  
   forall Delta G P s1 s2 s3 R,
        semax Hspec Delta G P (Ssequence s1 (Ssequence s2 s3)) R ->
        semax Hspec Delta G P (Ssequence (Ssequence s1 s2) s3) R.
Proof.
rewrite semax_unfold; intros.
destruct H as [TC H]; split.
admit. (* typechecking proof *)
intros.
specialize (H psi w Prog_OK k F).
spec H.
intros ? ? ?. apply H0.
intro i; destruct (H2 i); intuition.
clear - H3; left. simpl in *. unfold modified2 in *; intuition.
spec H; [solve [auto] |].
clear - H.
intros rho ? ? ? ? ?.
specialize (H rho y H0 a' H1 H2).
clear - H.
intros ora jm H2; specialize (H ora jm H2).
forget (ve_of rho) as ve.
forget (te_of rho) as te.
clear - H.
destruct (@level rmap ag_rmap a'); simpl in *; auto.
destruct H as [st' [m' [? ?]]].
destruct (corestep_preservation_lemma Hspec psi 
                     (Kseq (Ssequence s2 s3) :: k)
                     (Kseq s2 :: Kseq s3 :: k)
                     ora ve te jm n (Kseq s1) nil st' m')
       as [c2 [m2 [? ?]]]; simpl; auto.
intros. apply control_suffix_safe; simpl; auto.
clear.
intro; intros.
eapply convergent_controls_safe; try apply H0; simpl; auto.
intros.
destruct H1 as [H1 [H1a H1b]]; split3; auto.  inv H1; auto.
clear.
hnf; intros.
eapply convergent_controls_safe; try apply H0; simpl; auto.
clear; intros.
destruct H as [H1 [H1a H1b]]; split3; auto.  inv H1; auto.
destruct H as [H1 [H1a H1b]]; split3; auto.  inv H1; auto.
do 2 econstructor; split; try apply H2.
destruct H1 as [H1 [H1a H1b]]; split3; auto.
constructor; constructor; auto.
Qed.

Lemma seq_assoc2:  
   forall Delta G P s1 s2 s3 R,
        semax Hspec Delta G P (Ssequence (Ssequence s1 s2) s3) R ->
        semax Hspec Delta G P (Ssequence s1 (Ssequence s2 s3)) R.
Proof.
rewrite semax_unfold; intros.
destruct H as [TC H]; split.
admit. (* typechecking proof *)
intros.
specialize (H psi w Prog_OK k F).
spec H.
intros ? ? ?. apply H0.
intro i; destruct (H2 i); intuition.
clear - H3; left. simpl in *. unfold modified2 in *; intuition.
spec H; [solve [auto] |].
clear - H.
intros rho ? ? ? ? ?.
specialize (H rho y H0 a' H1 H2).
clear - H.
intros ora jm H2; specialize (H ora jm H2).
forget (ve_of rho) as ve.
forget (te_of rho) as te.
clear - H.
destruct (@level rmap ag_rmap a'); simpl in *; auto.
destruct H as [st' [m' [? ?]]].
destruct (corestep_preservation_lemma Hspec psi 
                     (Kseq s2 :: Kseq s3 :: k)
                     (Kseq (Ssequence s2 s3) :: k)
                     ora ve te jm n (Kseq s1) nil st' m')
       as [c2 [m2 [? ?]]]; simpl; auto.
intros. apply control_suffix_safe; simpl; auto.
clear.
intro; intros.
eapply convergent_controls_safe; try apply H0; simpl; auto.
intros.
destruct H1 as [H1 [H1a H1b]]; split3; auto.
constructor; auto.
clear.
hnf; intros.
eapply convergent_controls_safe; try apply H0; simpl; auto.
clear; intros.
destruct H as [H1 [H1a H1b]]; split3; auto.
constructor; auto.
destruct H as [H1 [H1a H1b]]; split3; auto.
inv H1. inv H9; auto.
do 2 econstructor; split; try apply H2.
destruct H1 as [H1 [H1a H1b]]; split3; auto.
constructor. auto.
Qed. 

Lemma seq_assoc:  
   forall Delta G P s1 s2 s3 R,
        semax Hspec Delta G P (Ssequence s1 (Ssequence s2 s3)) R <->
        semax Hspec Delta G P (Ssequence (Ssequence s1 s2) s3) R.
Proof.
intros.
split; intro.
apply seq_assoc1; auto.
apply seq_assoc2; auto.
Qed.

Lemma semax_Sseq:
forall Delta G (R: ret_assert) P Q h t, 
    semax Hspec Delta G P h (overridePost Q R) -> 
    semax Hspec Delta G Q t R -> 
    semax Hspec Delta G P (Clight.Ssequence h t) R.
Proof.
intros.
rewrite semax_unfold in H,H0|-*.
destruct H as [TC H].
destruct H0 as [TC0 H0].
split.
admit. (* typechecking proof *)
intros.
specialize (H psi w Prog_OK).
specialize (H0 psi w Prog_OK).
clear Prog_OK.
assert ((guard Hspec psi Delta G (fun rho : environ => F rho * P rho)%pred
   (Kseq h :: Kseq t :: k)) w).
Focus 2.
   eapply guard_safe_adj; try apply H3;
   intros until n; apply convergent_controls_safe; simpl; auto;
   intros; destruct q'.
   destruct H4 as [? [? ?]]; split3; auto. constructor; auto.
   destruct H4 as [? [? ?]]; split3; auto. constructor; auto.
(* End Focus 2 *)

eapply H; eauto.
repeat intro; apply H1. simpl. unfold modified2. intro i; destruct (H3 i); intuition.

clear - TC0 H0 H1 H2.
intros ek vl.
intro rho.
unfold overridePost.
if_tac.
subst.
unfold exit_cont.
unfold guard in H0.
rewrite <- andp_assoc.
assert (app_pred
  (!!(typecheck_environ rho Delta = true /\ filter_genv psi = ge_of rho) &&
   (F rho * (Q rho)) && funassert G rho >=>
   assert_safe Hspec psi (Kseq t :: k) rho) w).
apply H0; auto.
repeat intro; apply H1. simpl. unfold modified2. intro i; destruct (H i); intuition.
eapply subp_trans; try apply H.
apply derives_subp. apply andp_derives; auto. apply andp_derives; auto.
normalize.
replace (exit_cont ek vl (Kseq t :: k)) with (exit_cont ek vl k)
  by (destruct ek; simpl; congruence).
apply H2.
Qed.

Lemma semax_for : 
forall Delta G Q Q' test incr body R
     (TC_expr: typecheck_expr Delta test = tc_TT)
     (BT: bool_type (Clight.typeof test) = true) 
         (* Joey:  if it turns out you don't end up needing the BT premise,
                                  then delete it from this rule, and from the semax_while
                              and semax_dowhile rules. *)
     (POST: forall rho,  assert_expr (Cnot test) rho && Q rho |-- R EK_normal nil rho),
     semax Hspec Delta G 
                (fun rho => assert_expr test rho && Q rho) body (for1_ret_assert Q' R) ->
     semax Hspec Delta G Q' incr (for2_ret_assert Q R) ->
     semax Hspec Delta G Q (Sfor' test incr body) R.
Proof.
intros.
rewrite semax_unfold.
intros.
split.
destruct H as [? _]. destruct H0 as [? _]. 
admit.  (* typechecking proof *)
intros until 2.
rename H1 into H2.
assert (CLO_body: closed_wrt_modvars body F).
  clear - H2. intros rho te ?. apply (H2 rho te). simpl.  unfold modified2; intro; destruct (H i); auto.
assert (CLO_incr:  closed_wrt_modvars incr F).
  clear - H2. intros rho te ?. apply (H2 rho te). simpl.  unfold modified2; intro; destruct (H i); auto.
revert Prog_OK; induction w using (well_founded_induction lt_wf); intros.
intro rho.
intros ? ? ? ? [[? ?] ?]. hnf in H6.
apply assert_safe_last; intros a2 LEVa2.
assert (NEC2: necR w (level a2)).
  apply age_level in LEVa2. apply necR_nat in H5. apply nec_nat in H5. 
  change w with (level w) in H4|-*. apply nec_nat. clear - H4 H5 LEVa2.  omega.
assert (LT: level a2 < level w).
  apply age_level in LEVa2. apply necR_nat in H5. 
 clear - H4 H5 LEVa2.
   change w with (level w) in H4.
  change R.rmap with rmap in *.  rewrite LEVa2 in *.  clear LEVa2. 
  apply nec_nat in H5. omega.
destruct H6 as [H6 Hge].
assert (Prog_OK2: (believe Hspec G psi G) (level a2)) 
  by (apply pred_nec_hereditary with w; auto).
generalize (pred_nec_hereditary _ _ _ NEC2 H3); intro H3'.
assert (exists b, bool_val (eval_expr rho test) (typeof test) = Some b).
clear - H6 TC_expr BT.
admit.  (* typechecking proof *)
destruct H9 as [b ?].
intros ora jm H11.
rename Hge into H10.
replace (level a') with (S (level a2)) 
 by (apply age_level in LEVa2;  rewrite LEVa2; apply minus_n_O).
subst a'.
destruct (can_age1_juicy_mem _ _ LEVa2) as [jm' LEVa2'].
unfold age in LEVa2.
assert (a2 = m_phi jm').
  generalize (age_jm_phi LEVa2'); unfold age; change R.rmap with rmap; 
           change R.ag_rmap with ag_rmap;  rewrite LEVa2; intro Hx; inv Hx; auto.
subst a2.
clear LEVa2; rename LEVa2' into LEVa2.
apply safe_corestep_backward
 with (State (ve_of rho) (te_of rho) (if b then Kseq body :: Kseq Scontinue :: Kfor2 test incr body :: k else k))
        jm'.
split3.
rewrite (age_jm_dry LEVa2); econstructor; eauto.
admit.  (* maybe need typechecking here *)
apply age1_resource_decay; auto.
apply age_level; auto.
assert (w >= level (m_phi jm)).
apply necR_nat in H5. apply nec_nat in H5. 
 change R.rmap with rmap in *; omega. 
clear y H5 H4. rename H11 into H5. pose (H4:=True).
destruct b.
(* Case 1: expr evaluates to true *)
Focus 1.
generalize H; rewrite semax_unfold; intros [_ H'].
specialize (H' psi (level jm') Prog_OK2 (Kseq Scontinue :: Kfor2 test incr body :: k) F CLO_body).
spec H'.
intros ek vl.
destruct ek.
simpl exit_cont.
rewrite semax_unfold in H0.
destruct H0 as [_ H0].
specialize (H0 psi (level jm') Prog_OK2 (Kfor3 test incr body :: k) F CLO_incr).
spec H0.
intros ek2 vl2 rho2; unfold for2_ret_assert.
destruct ek2.
unfold exit_cont.
apply (assert_safe_adj' Hspec) with (k:=Kseq (Sfor' test incr body) :: k); auto.
repeat intro. eapply convergent_controls_safe; try apply H12; simpl; auto.
  intros q' m' [? [? ?]]; split3; auto. inv H13; econstructor; eauto.
 eapply subp_trans; [ |  eapply (H1 _ LT Prog_OK2 H3' rho2)].
 apply derives_subp.
rewrite andp_assoc.
apply andp_derives; auto.
simpl exit_cont.
 normalize. normalize.
change (exit_cont EK_return vl2 (Kfor3 test incr body :: k))
  with (exit_cont EK_return vl2 k).
eapply subp_trans; [ | apply H3'].
auto.
intro rho2.
apply (assert_safe_adj' Hspec) with (k:= Kseq incr :: Kfor3 test incr body :: k); auto.
intros ? ? ? ? ? ? ?.
eapply convergent_controls_safe; simpl; eauto.
intros q' m' [? [? ?]]; split3; auto. constructor. simpl. auto.
eapply subp_trans; try apply H0.
apply derives_subp.
rewrite andp_assoc.
apply andp_derives; auto.
simpl exit_cont.
unfold for1_ret_assert.
intro rho3.
eapply subp_trans; [ | apply (H3' EK_normal nil rho3)].
apply derives_subp.
apply andp_derives; auto.
unfold exit_cont. simpl continue_cont.
unfold for1_ret_assert.
rewrite semax_unfold in H0.
destruct H0 as [_ H0].
intro rho2.
eapply subp_trans; [ | apply (H0 _ _ Prog_OK2 (Kfor3 test incr body :: k) F CLO_incr)].
apply derives_subp.
rewrite andp_assoc.
apply andp_derives; auto.
clear rho2.
intros ek2 vl2 rho2.
destruct ek2.
unfold exit_cont.
apply (assert_safe_adj' Hspec) with (k:=Kseq (Sfor' test incr body) :: k); auto.
intros ? ? ? ? ? ? ?.
eapply convergent_controls_safe; simpl; eauto.
intros q' m' [? [? ?]]; split3; auto. inv H12; econstructor; eauto.
eapply subp_trans; [ | eapply H1; eauto].
apply derives_subp.
rewrite andp_assoc.
apply andp_derives; auto.
unfold exit_cont, for2_ret_assert; normalize.
unfold exit_cont, for2_ret_assert; normalize.
 change (exit_cont EK_return vl2 (Kfor3 test incr body :: k))
  with (exit_cont EK_return vl2 k).
 apply H3'.
change (exit_cont EK_return vl (Kseq Scontinue :: Kfor2 test incr body :: k))
    with (exit_cont EK_return vl k).
intro rho4.
eapply subp_trans; [ | eapply H3'; eauto].
unfold for1_ret_assert.
auto.
apply (H' rho _ (le_refl _) (m_phi jm') (necR_refl _)); auto.
apply pred_hereditary with (m_phi jm); auto.
apply age_jm_phi; auto.
split; auto.
split; auto.
split; auto.
unfold assert_expr.
rewrite prop_true_andp; auto.

(* Case 2: expr evaluates to false *)
apply (H3' EK_normal nil rho _ (le_refl _) _ (necR_refl _)); auto.
rewrite prop_true_andp by auto.
apply pred_hereditary with (m_phi jm); auto.
apply age_jm_phi; auto.
split; auto.
eapply sepcon_derives; try apply H7; auto.
eapply derives_trans; try apply POST.
apply andp_right; auto.
intros ? ?.
hnf.

clear - BT H9.
 change true with (negb false);
 apply bool_val_Cnot; auto.
Qed.


Lemma semax_while : 
forall Delta G Q test body R
     (TC_expr: typecheck_expr Delta test = tc_TT)
     (BT: bool_type (Clight.typeof test) = true) 
     (POST: forall rho,  assert_expr (Cnot test) rho && Q rho |-- R EK_normal nil rho),
     semax Hspec Delta G 
                (fun rho => assert_expr test rho && Q rho) body (for1_ret_assert Q R) ->
     semax Hspec Delta G Q (Swhile test body) R.
Proof.
intros.
assert (semax Hspec Delta G Q Sskip (for2_ret_assert Q R)).
eapply semax_post; try apply semax_Sskip.
destruct ek; unfold normal_ret_assert, for2_ret_assert; intros; normalize; inv H0.
pose proof (semax_for Delta G Q Q test Sskip body R TC_expr BT POST H H0).
clear H H0.
rewrite semax_unfold in H1|-*.
destruct H1; split; auto.
admit.  (* typechecking proof *)
intros.
assert (closed_wrt_modvars (Sfor' test Sskip body) F).
hnf; intros; apply H1.
intro i; destruct (H3 i); [left | right]; auto.
clear - H4.
destruct H4; auto.
contradiction H.
specialize (H0 _ _ Prog_OK k F H3 H2).
clear - H0.
eapply guard_safe_adj; try eassumption.
clear; intros.
destruct n; simpl in *; auto.
destruct H as [c' [m' [? ?]]]; exists c'; exists m'; split; auto.
destruct H.
split.
constructor. auto.
auto.
Qed.

Lemma semax_dowhile : 
forall Delta G P Q test body R
     (TC_expr: typecheck_expr Delta test = tc_TT)
     (BT: bool_type (Clight.typeof test) = true) 
     (POST: forall rho,  assert_expr (Cnot test) rho && Q rho |-- R EK_normal nil rho),
     semax Hspec Delta G P body (for1_ret_assert Q R) ->
     semax Hspec Delta G 
                (fun rho => assert_expr test rho && Q rho) body (for1_ret_assert Q R) ->
     semax Hspec Delta G Q (Sdowhile test body) R.
Proof.
intros.
assert (semax Hspec Delta G Q Sskip (for2_ret_assert Q R)).
eapply semax_post; try apply semax_Sskip.
destruct ek; unfold normal_ret_assert, for2_ret_assert; intros; normalize; inv H1.
pose proof (semax_for Delta G Q Q test Sskip body R TC_expr BT POST H0 H1).
clear H0 H1.
rewrite semax_unfold in H,H2|-*.
destruct H, H2; split.
admit.  (* typechecking proof *)
intros.
specialize (H0 _ _ Prog_OK (Kseq Scontinue :: Kfor2 test Sskip body :: k) F).
specialize (H2 _ _ Prog_OK k F).
spec H0.
hnf; intros; apply H3.
intro i; destruct (H5 i); [left | right]; auto.
spec H2.
hnf; intros; apply H3.
intro i; destruct (H5 i); [left | right]; auto.
destruct H6; auto.
contradiction H6.
specialize (H2 H4).
spec H0.
intros ek vl rho.
destruct ek.
unfold for1_ret_assert, exit_cont.
clear H0 H2.
intros ? ? ? ? ?.
eapply assert_safe_adj with (Kseq Sskip :: Kfor3 test Sskip body :: k).
intros n ?; intros.
eapply convergent_controls_safe.
Focus 4.
intros.
destruct H8; split; [ | eassumption].
constructor.
simpl.
apply H8.
reflexivity.
simpl.
unfold cl_after_external; intros; simpl; auto.
simpl; auto.
auto.
Admitted.  (* probably good from here *)

End extensions.
