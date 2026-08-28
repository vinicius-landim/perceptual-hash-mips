# Perceptual Hash - A MIPS Assembly and Python Implementation

This repository contains the final project developed for the **Computer Architecture and Organization** course (2024/2).

The project implements an image authenticity/similarity pipeline using **Perceptual Hash (pHash)** and **Normalized Hamming Distance**:

- Python performs image preprocessing and DCT feature extraction.
- MIPS Assembly builds a 64-bit perceptual hash and computes the similarity score.

## Project Goal

The objective is to compare two images and estimate how similar they are, helping detect potential unauthorized use or manipulation of visual artworks.

The implemented workflow is based on four main stages:

1. Preprocessing (grayscale conversion + resize)
2. Feature extraction (2D DCT)
3. 64-bit pHash generation
4. Similarity measurement (Normalized Hamming Distance)

Typical interpretation of the normalized distance:

- Values close to `0.0`: very similar images
- Values around `0.5`: likely unrelated images

## Repository Structure

```text
perceptual-hash-mips/
├── README.md
├── docs/
└── src/
	├── get_input.asm
	├── phash_DCT.py
	└── phash_64bits_hamming.asm
```

- [src/get_input.asm](src/get_input.asm): reads two image paths from user input and writes them to a text file.
- [src/phash_DCT.py](src/phash_DCT.py): reads image paths, preprocesses images, computes 8x8 low-frequency DCT coefficients, and writes two `.bin` files.
- [src/phash_64bits_hamming.asm](src/phash_64bits_hamming.asm): reads DCT vectors, computes two 64-bit pHashes (split into two 32-bit registers each), prints both hashes, Hamming distance, and normalized distance.

## How the Pipeline Works

### 1) Input stage (MIPS)

`get_input.asm` asks for two image file paths (separated by space) and stores them in a text file.

### 2) DCT stage (Python)

`phash_DCT.py`:

- Opens both images
- Converts to grayscale (`L` mode)
- Resizes to `32x32` (for default `dct_matrix_size=8`, using factor `4`)
- Applies 2D DCT (Type II, orthonormal)
- Takes the top-left `8x8` block (low-frequency coefficients)
- Flattens to 64 floats
- Writes binary arrays to `dctArrayImg1.bin` and `dctArrayImg2.bin`

### 3) pHash + similarity stage (MIPS)

`phash_64bits_hamming.asm`:

- Loads both DCT arrays
- Sorts coefficients (Bubble Sort) to compute median
- Generates hash bits by comparing each coefficient to median
- Stores 64-bit hash as two 32-bit values (MSB/LSB)
- Computes Hamming distance via XOR + bit counting
- Computes normalized distance: 

$$
	{Normalized Hamming} = \frac{\text{Hamming Distance}}{64}
$$

## Prerequisites

### Python

- Python 3.x
- `numpy`
- `Pillow`
- `scipy`

Install dependencies:

```bash
pip install numpy pillow scipy
```

### MIPS Simulator

Use a MIPS simulator compatible with syscalls used by the code (for example, **MARS**).

## Configuration Notes

The current source files contain **absolute Windows paths** (for input/output files). If you run this project on another machine/OS, update these paths first:

- [src/get_input.asm](src/get_input.asm)
- [src/phash_DCT.py](src/phash_DCT.py)
- [src/phash_64bits_hamming.asm](src/phash_64bits_hamming.asm)

Also ensure both assembly files and Python script point to the same text/binary files.

## Running the Project

1. Run [src/get_input.asm](src/get_input.asm) in your MIPS simulator.
2. Enter two image paths separated by space.
3. Run [src/phash_DCT.py](src/phash_DCT.py) to generate DCT `.bin` files.
4. Run [src/phash_64bits_hamming.asm](src/phash_64bits_hamming.asm) to:
	- print both binary pHashes
	- print Hamming Distance
	- print Normalized Hamming Distance

## Expected Output Example

The final assembly stage prints output in this format:

```text
Hash (em binario) da Imagem 1: <64-bit binary>
Hash (em binario) da Imagem 2: <64-bit binary>

Distancia de Hamming: <integer>
Distancia de Hamming Normalizada: <float>
```