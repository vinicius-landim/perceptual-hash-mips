import numpy as np
from PIL import Image
from scipy.fftpack import dct
import struct


def phash_dct(image_path, dct_matrix_size=8):
    # Abrir a imagem e converter para tons de cinza
    image = Image.open(image_path).convert("L")

    # Reduzir a imagem para (dct_matrix_size * 4, dct_matrix_size * 4)
    resized_image = image.resize(
        (dct_matrix_size * 4, dct_matrix_size * 4), Image.LANCZOS)

    # Converter a imagem para um array NumPy
    pixel_matrix = np.array(resized_image, dtype=np.float32)

    # Aplicar a Transformada Discreta de Cosseno (DCT) Tipo II
    dct_matrix = dct(dct(pixel_matrix, axis=0, type=2,
                     norm='ortho'), axis=1, type=2, norm='ortho')

    # Selecionar a região de frequência (dct_matrix_size x dct_matrix_size)
    dct_freq = dct_matrix[:dct_matrix_size, :dct_matrix_size]

    return dct_freq


# Abre o arquivo txt contendo o caminho até as imagens e faz a leitura
with open(r"C:/Users/lvini/Desktop/Programacao/AOC/saida.txt", "r", encoding="utf-8") as f:
    linha = f.readline().strip()

# Quebra o conteudo do arquivo por espaço em branco e armazena os caminhos em image_path
dados = linha.split()
if len(dados) >= 2:
    image_path1, image_path2 = dados[:2]
else:
    raise ValueError(
        "Erro: O arquivo não contém pelo menos dois caminhos de imagem!")

# Processar ambas as imagens
dct_8x8_img1 = phash_dct(image_path1)
dct_8x8_img2 = phash_dct(image_path2)

# Achatar os arrays
flattened_img1 = dct_8x8_img1.flatten()
flattened_img2 = dct_8x8_img2.flatten()

# Salvar os arrays em um arquivo binário
with open("dctArrayImg1.bin", "wb") as f:
    f.write(struct.pack("64f", *flattened_img1))

with open("dctArrayImg2.bin", "wb") as f:
    f.write(struct.pack("64f", *flattened_img2))

# Exibir os arrays formatados para conferência
dct_8x8_str_img1 = ", ".join([f"{x:.6f}" for x in flattened_img1])
dct_8x8_str_img2 = ", ".join([f"{x:.6f}" for x in flattened_img2])
print(f"DCT Array 8x8 (Imagem 1):\n{dct_8x8_str_img1}")
print(f"DCT Array 8x8 (Imagem 2):\n{dct_8x8_str_img2}")
