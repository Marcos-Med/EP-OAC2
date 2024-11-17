def convert(file):
    with open(file, "r", encoding="ascii") as f:
        conteudo = f.read()

    # Escrever o conteúdo como UTF-8
    with open(file, "w", encoding="utf-8") as f:
        f.write(conteudo)

convert("y_pred.txt")
convert("y_test.txt")