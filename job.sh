cd /data/CodeT5/CodeT5/sh/

lang=decomC #programming language
model=codet5_base

touch log.txt

python3 run_exp.py --model_tag $model --task summarize --sub_task $lang |& tee log.txt
