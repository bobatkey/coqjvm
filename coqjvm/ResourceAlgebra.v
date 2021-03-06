Require Import BasicMachineTypes.
Require Import Setoid.
Require List.

(* Definition for expressing resources in annotations. An RA will
   have a function to convert this to a resource, a logic will have
   a function to convert this to a formula. *)
Definition res_expr (R:Set) : Set := List.list (bool * R).


Module Type RESOURCE_ALGEBRA
  (RA_B : BASICS).

Parameter res : Type.

Parameter eq : res -> res -> Prop.
Notation "e1 [=] e2" := (eq e1 e2) (at level 70, no associativity).

Hypothesis eq_refl : forall r, r [=] r.
Hypothesis eq_symm : forall r1 r2, r1 [=] r2 -> r2 [=] r1.
Hypothesis eq_trans : forall r1 r2 r3, r1 [=] r2 -> r2 [=] r3 -> r1 [=] r3.

Add Relation res eq
 reflexivity proved by eq_refl
 symmetry proved by eq_symm
 transitivity proved by eq_trans as ra_eq_rel.


Parameter leq : res -> res -> Prop.
Notation "e1 <: e2" := (leq e1 e2) (at level 75, no associativity).

Hypothesis leq_refl     : forall r1 r2, r1 [=] r2 -> r1 <: r2.
Hypothesis leq_antisymm : forall r1 r2, r1 <: r2 -> r2 <: r1 -> r1 [=] r2.
Hypothesis leq_trans    : forall r1 r2 r3, r1 <: r2 -> r2 <: r3 -> r1 <: r3.

Add Relation res leq
 reflexivity proved by leq_refl2
 transitivity proved by leq_trans as ra_leq_rel.

Add Morphism leq with signature eq ==> eq ==> iff as leq_morphism.


Parameter combine : res -> res -> res.
Notation "e1 :*: e2" := (combine e1 e2) (at level 40, left associativity).

Parameter e : res.

Hypothesis e_bottom : forall r, e <: r.
Hypothesis e_combine_r : forall r, e :*: r [=] r.
Hypothesis r_combine_e : forall r, r :*: e [=] r.
Hypothesis combine_assoc : forall r1 r2 r3, r1 :*: (r2 :*: r3) [=] (r1 :*: r2) :*: r3.
Hypothesis combine_symm  : forall r1 r2, r1 :*: r2 [=] r2 :*: r1.

Add Morphism combine with signature  eq ==>  eq ==>  eq as combine_morphism.
Add Morphism combine with signature leq ++> leq ++> leq as combine_order.


Parameter bang : res -> res.
Notation "! e" := (bang e) (at level 35, right associativity).

Hypothesis bang_unit : forall r, r <: !r.
Hypothesis bang_mult : forall r, !!r <: !r.
Hypothesis bang_codup : forall r, !r :*: !r <: !r.
Hypothesis bang_e : !e [=] e.
Hypothesis bang_combine : forall r1 r2, !(r1 :*: r2) [=] !r1 :*: !r2.

Parameter r_new : RA_B.Classname.t -> option res.

Add Morphism bang with signature  eq ==>  eq as bang_morphism.
Add Morphism bang with signature leq ++> leq as bang_order.


Fixpoint res_parse (expr:res_expr RA_B.Classname.t) :=
  match expr with
    | List.nil => e
    | (List.cons (true,c) t) => match r_new c with None => res_parse t | Some r => (!r) :*: (res_parse t) end
    | (List.cons (false,c) t) => match r_new c with None => res_parse t | Some r => r :*: (res_parse t) end
  end.

End RESOURCE_ALGEBRA.
