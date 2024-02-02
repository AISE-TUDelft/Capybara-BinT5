# Capybara-BinT5

![Static Badge](https://img.shields.io/badge/%F0%9F%A4%97HuggingFace-%F0%9F%A4%96BinT5-orange?style=for-the-badge&link=https%3A%2F%2Fhuggingface.co%2Fcollections%2FAISE-TUDelft%2Fbint5-65bd006a8c90bd5c97485244)
![Static Badge](https://img.shields.io/badge/%F0%9F%A4%97HuggingFace-%F0%9F%A6%ABCapybara-orange?style=for-the-badge&link=https%3A%2F%2Fhuggingface.co%2Fdatasets%2FAISE-TUDelft%2FCapybara)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/aalkaswan/bint5/latest?style=for-the-badge)
[![arXiv](https://img.shields.io/badge/arXiv-2301.01701-b31b1b.svg?style=for-the-badge)](https://arxiv.org/abs/2301.01701)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=for-the-badge)](https://opensource.org/licenses/Apache-2.0)


Replication package for the SANER 2023 paper titled ["Extending Source Code Pre-Trained Language Models to Summarise Decompiled Binaries"](https://arxiv.org/abs/2301.01701). 

For questions about the content of this repo, please use the issues board. If you have any questions about the paper, please email the first author.

## HuggingFace 🤗

The [models](https://huggingface.co/collections/AISE-TUDelft/bint5-65bd006a8c90bd5c97485244) and [dataset](https://huggingface.co/datasets/AISE-TUDelft/Capybara) are both also available on the HF Hub. 

To replicate the experimental setup of the paper follow the following steps:

## Docker Image
It is recommended to use the provided Docker image, which has the correct Cuda version and all of the required dependencies installed. 
Pull the image, create a container, and mount this folder as a volume:

``` bash
docker pull aalkaswan/bint5
docker run -i -t --name {containerName} --gpus all -v $(pwd):/data aalkaswan/bint5 /bin/bash
```

This should spawn a shell, which allows you to use the container. Change to the mounted volume:
```bash
cd mnt/data/
```

All of the following commands should then be run from within the Docker container. You can respawn the shell using:

```bash
docker exec -it {containerName} /bin/bash
```

If you wish to run without using docker, we also provide a `requirements.txt` file.

## Setup 
First, clone the CodeT5 repo into this directory:

```bash
git clone https://github.com/salesforce/CodeT5.git
```

Run the following command to set the correct working directory in the training script:

```bash
wdir=\WORKDIR=\"`pwd`/'CodeT5'\" && sed '1 s#^.*$#'$wdir'#' CodeT5/sh/exp_with_args.sh
```

Now that the model is set up we need to download the data, use the following commands to download and unpack the data:
```bash
wget https://zenodo.org/record/7229809/files/Capybara.zip
unzip Capybara.zip
rm Capybara.zip
```
Similarly to download the pretrained BinT5 checkpoints:
```bash
wget https://zenodo.org/records/7229913/files/BinT5.zip?download=1
unzip BinT5.zip
rm Capybara.zip
```

## Finetune Models 
To use this data in BinT5, setup the data folders in the CodeT5 project:
```bash
mkdir -p CodeT5\data\summarize\{C,decomC,demiStripped,strippedDecomC}
```
Now you can simply move the data of your choice from `\Capybara\training_data\{lan}\{dup/dedup}` to `CodeT5\data\summarize\{lan}`. 
Finally, edit the `language` variable in the `job.sh` file and start training in detached mode:

```bash
docker exec -d {containerName} /bin/bash "/data/job.sh"
``` 

You can view the progress and results of the finetuning in the: `\CodeT5\sh\log.txt` file, the resulting model and training outputs are also present in the same folder.

## Use Finetuned BinT5 Checkpoints
For each of the models, a `pytorch.bin` file is provided in its respective folder. 
These models can be loaded into CodeT5 and used for inference or further training.

To utilise the models, download the reference CodeT5-base model from HuggingFace:
bash
```
GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/Salesforce/codet5-base
```

- This will pull the repo but skip the `pytorch_model.bin` file, which will be replaced in the next step. 
- Select the model that you wish to use from the respective directory. Copy this file and replace the `pytorch_model.bin` in the local `codet5-base` directory downloaded in the previous step. 
- Instead of loading in the model through HuggingFace, load in a local model. To load a local model, change line 66 in the `sh/exp_with_args.sh` file to the path of your local `codet5-base` model which you downloaded and configured in the previous step. The tokenizer does not need to be replaced. 
- The model can now be run by executing `sh/run_exp.py`
