# Definir variáveis
CC = gcc                    # Compilador C (gcc)
CFLAGS = -Wall -Wextra       # Flags de compilação (avisos)

# Arquivos fontes e objetos
SRCS = app.c knn.c list.c
OBJS = $(SRCS:.c=.o)         # Converte .c para .o (arquivos objetos)
EXEC = app              # Nome do executável final

# Regra padrão (a primeira regra é executada por padrão)
all: $(EXEC)

# Como criar o executável
$(EXEC): $(OBJS)
	$(CC) $(OBJS) -o $(EXEC)

# Como compilar os arquivos .c para .o
%.o: %.c list.h ML.h
	$(CC) $(CFLAGS) -c $< -o $@

# Limpar arquivos temporários (arquivos objetos e executável)
clean:
	rm -f $(OBJS) $(EXEC)

# Recompilar tudo do zero
rebuild: clean all
