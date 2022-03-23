#!/usr/bin/env sh

# Generate the `_CoqProject` file
echo "# !!!" > _CoqProject
echo "# Generated by configure.sh" >> _CoqProject
echo "# !!!" >> _CoqProject

echo "-arg -impredicative-set" >> _CoqProject
echo "-arg -w" >> _CoqProject
echo "-arg -notation-overridden,-unexpected-implicit-declaration" >> _CoqProject
echo >> _CoqProject

# Generate the Makefile
coq_makefile -f _CoqProject -o Makefile