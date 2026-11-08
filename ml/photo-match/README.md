# Photo match (siamese network)

A small TensorFlow / Keras experiment from MaWaRoute: a siamese network that
scores how likely two photos show the same place. The idea was to check a
visitor's photo-task picture against the shop's reference photo.

Note: the visitor app in this repository does **not** use this model. It
compares photos with Google Cloud Vision labels and text, via the
`AnnotateImageV2` Cloud Function (see `apps/visitor/BACKEND.md`). This folder
is kept as the training code for that experiment. No trained weights or
training photos are included.

## How it works

- `helper/siamese_network.py`: a shared feature extractor (two
  Conv2D/MaxPool/Dropout blocks, global average pooling, 48-d embedding).
- `helper/utils.py`: `DistanceLayer` (Euclidean distance between the two
  embeddings) and the pair builder. Each training image is paired with a
  random image of the same class (label 1) and of another class (label 0).
- The model is `sigmoid(Dense(distance))`, trained with binary cross-entropy
  on 512x512 grayscale images (`helper/config.py`).

## Setup

Python 3.10-3.13.

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

For GPU training follow TensorFlow's install guide for your platform
(https://www.tensorflow.org/install/pip); on Linux with an NVIDIA GPU,
`pip install "tensorflow[and-cuda]"` installs the CUDA libraries.

## Data

Bring your own photos; none are committed, and the data folders are
gitignored. Photos of real places can show people and private property, so
keep them out of the repository.

1. Put all source photos in one folder, named `<anything>_<number>.<ext>`
   (`.jpg`, `.jpeg`, `.png`, `.bmp`, `.gif`). Every 10 consecutive numbers are
   one place: `photo_1` ... `photo_10` are place 1, `photo_11` ... `photo_20`
   are place 2, and so on.
2. Convert them into one folder per place:

   ```sh
   python training_processor.py -i training_images
   ```

   This writes grayscale 512x512 copies to
   `training_input_folder/<place>/`. Options: `--type original|gray|black_and_white`
   and `--size N` (keep `gray` and 512 unless you also change
   `helper/config.py`).

Folder names under `training_input_folder/` must be integers; they are the
class labels.

## Train

```sh
python train_siamese_network.py --input training_input_folder
```

Uses 80% of the images for training and 20% for validation, for
`EPOCHS` (100) epochs with `BATCH_SIZE` (4). Writes
`mawaroute_output/siamese_model.keras` and `mawaroute_output/plot.png`.

## Test

Prepare a test folder the same way (images in any sub-folders), then:

```sh
python test_siamese_network.py --input testing_input_folder
```

It picks 10 random pairs and shows each pair with its similarity score
(a matplotlib window per pair).

## Export to TensorFlow Lite

```sh
python model_conversion.py
```

Writes `mawaroute_output/tf_lite_model.tflite`.

## Status

The scripts were ported from TensorFlow 2.10 / Keras 2 to Keras 3 (TensorFlow
2.20+) for this release: the private Keras dataset loader was replaced by
`helper/dataset.py`, models are saved in the `.keras` format, and the
distance layer uses TensorFlow ops. They pass a syntax check but have not
been run end to end on the new versions.
